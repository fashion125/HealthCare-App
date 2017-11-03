//
//  AddRecipeViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 7/10/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "AddRecipeViewController.h"
#import "AddFoodTableViewCell.h"
#import "FoodSearchViewController.h"
#import "IngredientTableViewCell.h"
#import "CustomTableSectionView.h"
#import "Utils.h"
#import "UIViewController+Starlet.h"

@implementation AddRecipeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isEditing) {
        self.title = @"Edit Recipe";
        self.ingredients = [NSMutableArray arrayWithArray:[self.food recipe]];
    } else {
        self.title= @"Add New Recipe";
        self.food = [[Food alloc] init];
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer: tap];
    
    if (self.isEditing) {
        [self.nameField setText: [self.food name]];
        Measure* fullMeasure = [self.food measureWithName: @"full recipe"];
        Measure* servingMeasure = [self.food measureWithName: @"Serving"];
        int totalServings = (int)round([fullMeasure grams] / [servingMeasure grams]);
        [self.measureNameField setText: [NSString stringWithFormat:@"%d", totalServings]];
//        UIBarButtonItem* optionButton = [[UIBarButtonItem alloc] initWithTitle: @"Options" style:UIBarButtonItemStylePlain target:self action:@selector(onClickOptions:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Options" style:UIBarButtonItemStylePlain target:self action:@selector(onClickOptions:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];

    
    // make sure nutrients are loaded, then refresh table view
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[WebQuery singleton] loadNutrients];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
        });
    });
    
    self.nutrientTable.delegate = self;
    self.nutrientTable.dataSource = self;
    
}
-(void)dismissKeyboard {
    [self.nameField resignFirstResponder];
    [self.measureNameField resignFirstResponder];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nutrientTable reloadData];
}
- (IBAction)onClickOptions:(id)sender {
    self.sheetSender = sender;
    [self.sheetSender setEnabled: FALSE];
    UIActionSheet *asheet = [[UIActionSheet alloc] initWithTitle:@"Select an Option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle: nil
                       otherButtonTitles:  @"Save Changes",  @"Delete Recipe",  nil];
    
    [asheet showFromBarButtonItem:sender animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    [self.sheetSender setEnabled:TRUE];
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        NSString *item =[actionSheet buttonTitleAtIndex:buttonIndex];
        if ([item isEqualToString:@"Save Changes"]) {
            [self saveRecipe];
            
        } else if ([item isEqualToString:@"Delete Recipe"]) {
//            [self deleteRecipe];
            if (self.food == nil) {
                return;
            }
            if ([self.food foodId] == 0) {
                return;
            }
            [self showProgressView];
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary* result = [[WebQuery singleton] foodStats:self.food.foodId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideProgressView];
                    if (result != nil) {
                        BOOL used_by_others = [[result objectForKey: @"used_by_others"] boolValue];//result.getBoolean("used_by_others");
                        long ingredients = [[result objectForKey: @"ingredients"] longValue];//result.getInt("ingredients");
                        long servings = [[result objectForKey: @"servings"] longValue];//result.getInt("servings");
                        if (used_by_others == YES) {
                            [self.navigationItem.rightBarButtonItem setEnabled:YES];
                            [self.navigationItem.leftBarButtonItem setEnabled:YES];
                            [Toolbox showMessage: @"Other people are using this item." withTitle: @"Cannot delete"];
                            return;
                        }
                        NSString* message1 = @"";
                        NSString* message2 = @"";
                        NSString* message = @"";
                        if (servings > 0) {
                            message1 = [NSString stringWithFormat: @"WARNING: This item is used in %ld servings in your diary.\nAll of these servings will be deleted from the record if you delete this recipe.\n", servings];
                        }
                        if (ingredients > 0) {
                            message2 = [NSString stringWithFormat: @"WARNING: This item is used as an ingredient in %ld recipes.\nIt will be removed from those recipes if you delete this recipe.", ingredients];
                        }
                        message = [NSString stringWithFormat: @"%@%@\nAre you sure you want to delete the recipe '%@'", message1, message2, self.food.name];
                        [self showConfirmationAlertForDeleteRecipe:message];
                        
                        
                    } else {
                        [self.navigationItem.rightBarButtonItem setEnabled:YES];
                        [self.navigationItem.leftBarButtonItem setEnabled:YES];
                        [Toolbox showMessage:@"An unexpected error ocurred when we tried to delete the recipe" withTitle:@"Server Error"];
                    }
                });
            });
        }
    }
}

- (void) showConfirmationAlertForDeleteRecipe:(NSString*)msg
{
    // A quick and dirty popup, displayed only once
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    //    alert.tag = 1002;
    [alert show];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 = Tapped yes
    if (buttonIndex == 1)
    {
        [self deleteRecipe];
    } else {
        [self hideProgressView];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
}

- (void) deleteRecipe {
    if (self.food == nil) {
        return;
    }
    if ([self.food foodId] == 0) {
        return;
    }
    // SAVE TO SERVER
    [self showProgressView];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [[WebQuery singleton] delFood:self.food];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressView];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
            if (result == YES) {
                if (self.foodSearchVC != nil) {
                    [self.foodSearchVC delTopFood:self.food.foodId];
                    
                }
                if (self.diaryVC != nil) {
                    [self.diaryVC loadDay: self.diaryVC.currentDay];
                    [self.navigationController popToViewController: self.diaryVC animated: YES];
                }
            } else {
                [Toolbox showMessage:@"An unexpected error ocurred when we tried to delete the recipe" withTitle:@"Server Error"];
            }
        });
    });
}

- (void) saveRecipe {
    if (self.nameField.text.length < 1) {
        [Toolbox showMessage:@"Please enter a name for this recipe" withTitle:@"Validation Error"];
        return;
    }
    
    if (self.measureNameField.text.length < 1) {
        [Toolbox showMessage:@"Please enter a name for this recipe's serving size" withTitle:@"Validation Error"];
        return;
    }
    self.food.name = self.nameField.text;
    //
    // SAVE TO SERVER
    [self showProgressView];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long foodId = [[WebQuery singleton] addFood:self.food];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
            [self hideProgressView];
            if (foodId != 0) {
                //                [Toolbox showMessage:@"Your new recipe has been added" withTitle:@"New Recipe Added"];
                //                [self.navigationController popViewControllerAnimated:YES];
                if (self.isEditing) {
                    if (self.foodSearchVC != nil) {
                        [self.foodSearchVC gotoAddServingVC: foodId];
                        [self.navigationController popToViewController:self.foodSearchVC animated:NO];
                    } else {
                        [self.navigationController popToViewController:self.diaryVC animated:YES];
                    }
                    
                } else {
                    [self.foodSearchVC gotoAddServingVC: foodId];
                    [self.navigationController popToViewController:self.foodSearchVC animated:NO];
                }

            } else {
                [Toolbox showMessage:@"An unexpected error ocurred when we tried to add the recipe" withTitle:@"Server Error"];
            }
        });
    });
    //[self.navigationItem.rightBarButtonItem setEnabled:FALSE];
}

- (IBAction)save:(id)sender {
    [self saveRecipe];
}

- (IBAction)pressAddIngredients:(id)sender {
    FoodSearchViewController* foodSearchVC = (FoodSearchViewController*)[Utils newViewControllerWithId:@"foodSearchVC"];
    //foodSearchVC.diary = self;
    foodSearchVC.diaryVC = nil;
    foodSearchVC.isFromRecipe = YES;
    foodSearchVC.addRecipeVC = self;
    
    [self.navigationController pushViewController:foodSearchVC animated:YES];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Data
- (void) addIngredient: (Serving*) serving {
    if (self.ingredients == nil) {
        self.ingredients = [[NSMutableArray alloc] init];
    }
    NSString* str = [self.measureNameField.text isEqualToString:@""]?self.measureNameField.placeholder:self.measureNameField.text;
    double totalServings = [str doubleValue];
    [self.ingredients addObject:serving];
    [self.food addIngredient:serving];
    self.recipeWeight= [self.food recomputeNutrients: self.nutrients totalServings:totalServings];
    [self.nutrientTable reloadData];
}

- (void) removeIngredientAt: (NSInteger) index {
    if (self.ingredients == nil) {
        return;
    }
    NSString* str = [self.measureNameField.text isEqualToString:@""]?self.measureNameField.placeholder:self.measureNameField.text;
    double totalServings = [str doubleValue];
    [self.food removeIngredient: [self.ingredients objectAtIndex: index ]];
    [self.ingredients removeObjectAtIndex:index];
    self.recipeWeight = [self.food recomputeNutrients: self.nutrients totalServings:totalServings];
    [self.nutrientTable reloadData];
}

- (void) loadData {
    NSMutableArray *nutrientList =[[NSMutableArray alloc] init];
    
    NSMutableDictionary *tempCategories = [[NSMutableDictionary alloc] init];
    
    // add each nutrient into a category list
    for (NutrientInfo *ni in [[WebQuery singleton] getNutrients]) {
        NSMutableArray *list = [tempCategories objectForKey: ni.category];
        if (list == nil) {
            list = [[NSMutableArray alloc] init];
            [tempCategories setObject:list forKey:ni.category];
        }
        if (ni.track) {
           [list addObject:ni];
        }
    }
    
    self.categories = [[NSMutableDictionary alloc] init];
    
    // sort each category list according to name, and parent/child
    for (NSString* cat in [tempCategories keyEnumerator]) {
        NSMutableArray *list = [tempCategories objectForKey: cat];
        if (list != nil) {
            // sort list alphabetically first
            [list sortUsingSelector:@selector(compare:)];
            
            NSMutableArray *slist = [[NSMutableArray alloc] init];
            for (NutrientInfo *ni in list) {
                if (ni.pId == 0) {
                    [self addNutrient: ni toList: slist withNutrients: list];
                    [nutrientList addObject: ni];
                }
            }
            [self.categories setObject:slist forKey:cat];
        }
    }
    self.nutrients = [[NSArray alloc] initWithArray: nutrientList];
    //self.food.nutrients = self.nutrients;
    if (self.isEditing) {
        NSString* str = [self.measureNameField.text isEqualToString:@""]?self.measureNameField.placeholder:self.measureNameField.text;
        double totalServings = [str doubleValue];
        self.recipeWeight= [self.food recomputeNutrients: self.nutrients totalServings:totalServings];
    }

    [self.nutrientTable reloadData];
  
}

- (void) addNutrient:(NutrientInfo*) ni toList:(NSMutableArray*)list withNutrients:(NSMutableArray*)nutrients {
    [list addObject:ni];
    for (NutrientInfo *ni2 in nutrients) {
        if (ni2.pId == ni.nId) {
            [self addNutrient: ni2 toList: list withNutrients: nutrients];
        }
    }
}

#pragma mark -
#pragma mark Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *list = [self.categories objectForKey: [self categoryName:indexPath.section]];
    if (list != nil) {
        NutrientInfo *ni = [list objectAtIndex:indexPath.row];
        if (ni != nil) {
            [self.nutrientTable deselectRowAtIndexPath: [self.nutrientTable indexPathForSelectedRow] animated:NO];
            
//            //         EditNutrientViewController *vc = [[EditNutrientViewController alloc] initWithNibName:@"EditNutrientView" bundle:[NSBundle mainBundle]];
//            EditNutrientViewController* editNutrientVC = (EditNutrientViewController*) [Utils newViewControllerWithId:@"editNutrientVC"];
//            editNutrientVC.food = self.food;
//            editNutrientVC.nutrient = ni;
//            [self.navigationController pushViewController:editNutrientVC animated:YES];
        }
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 8;
}

- (NSString *) categoryName: (NSInteger) section {
    switch (section) {
        case 0: return @"Ingredients";
        case 1: return @"Nutrition per Serving";
        case 2: return @"General";
        case 3: return @"Vitamins";
        case 4: return @"Minerals";
        case 5: return @"Carbohydrates";
        case 6: return @"Lipids";
        case 7: return @"Protein";
    }
    return @"";
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ((self.ingredients != nil && indexPath.row == [self.ingredients count]) ||
            (self.ingredients == nil && indexPath.row == 0)) {
            return 21;
        } else {
            return 56;
        }
    }
    return 36;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 36;
    } else {
        return 36;//UITableViewAutomaticDimension;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section; {
    return [self categoryName:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.ingredients count] + 1;
    } else if (section == 1) {
        return 0;
    } else {
        if (self.categories != nil) {
            NSMutableArray *list = [self.categories objectForKey: [self categoryName:section]];
            if (list != nil) {
                return [list count];
            }
        }
    }
    
    return 0;
}
- (UIView*) tableView:(UITableView*) tableView viewForHeaderInSection:(NSInteger)section {
    if (section==0 || section == 1) {
        NSString *CellIdentifier = @"CustomTableSectionView";
        CustomTableSectionView* cell = (CustomTableSectionView*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if(currentObject && [currentObject isKindOfClass:[CustomTableSectionView class]]) {
                    cell = (CustomTableSectionView *)currentObject;
                    break;
                }
            }
        }
        cell.label.text = [self categoryName: section];
        return cell;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"IngredientTableViewCell";
        IngredientTableViewCell* cell = (IngredientTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if(currentObject && [currentObject isKindOfClass:[IngredientTableViewCell class]]) {
                    cell = (IngredientTableViewCell *)currentObject;
                    break;
                }
            }
        }
        
        if (self.ingredients != nil) {
            if (indexPath.row == [self.ingredients count]) {
                [cell hideAll];
            } else {
                Serving* serving = [self.ingredients objectAtIndex:indexPath.row];
                cell.rowIndex = indexPath.row;
                cell.addRecipe = self;
                [cell setIngredient:indexPath.row serving:serving];
            }
        } else {
            [cell hideAll];
        }

        return cell;
    } else {
        
        NSString *CellIdentifier = @"AddFoodTableCell";
        AddFoodTableViewCell *cell = (AddFoodTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if(currentObject && [currentObject isKindOfClass:[AddFoodTableViewCell class]]) {
                    cell = (AddFoodTableViewCell *)currentObject;
                    break;
                }
            }
        }
        
        NSMutableArray *list = [self.categories objectForKey: [self categoryName:indexPath.section]];
        if (list != nil) {
            NutrientInfo *ni = [list objectAtIndex:indexPath.row];
            double amount = [self.food nutrientAmount: ni.nId] * self.recipeWeight / 100.0;
            [cell setNutrient: ni andAmount: amount];
        }
        
        return cell;
    }
}

- (IBAction)TotalServingsEditingDidEnd:(id)sender {
    NSString* str = [self.measureNameField.text isEqualToString:@""]?self.measureNameField.placeholder:self.measureNameField.text;
    double totalServings = [str doubleValue];
    if (totalServings < 1) {
        [Toolbox showMessage:@"Total Servings must be a value equal or greater than 1." withTitle:@"Validation Error"];
        self.measureNameField.text = @"";
        return;
    }
    if (self.ingredients == nil) {
        self.ingredients = [[NSMutableArray alloc] init];
    }
    self.recipeWeight= [self.food recomputeNutrients: self.nutrients totalServings:totalServings];
    [self.nutrientTable reloadData];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    NSInteger nextTag = theTextField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [theTextField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [theTextField resignFirstResponder];
    }
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

@end
