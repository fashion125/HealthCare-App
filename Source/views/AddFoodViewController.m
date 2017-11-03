//
//  AddFoodViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 2014-05-04.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import "AddFoodViewController.h"
#import "AddFoodTableViewCell.h"
#import "EditNutrientViewController.h"
#import "WebQuery.h"
#import "Toolbox.h"
#import "Formatter.h"
#import "Utils.h"
#import "AddServingViewController.h"
#import "UIViewController+Starlet.h"

@interface AddFoodViewController()
@property (strong, nonatomic) IBOutlet UIView *tapView;
@property (readwrite) long defaultMeasureId;
@end
@implementation AddFoodViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
//      self.categories = [[NSMutableDictionary alloc] init];
//      self.amounts = [[NSMutableDictionary alloc] init];
   }
   return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    if (self.isEditing) {
        self.title = @"Edit Food";
        if (self.food != nil) {
            [self.nameField setText: [self.food name]];
            self.defaultMeasureId = self.food.prefMeasureId;
            Measure* mm = [self.food measure: self.defaultMeasureId];
            [self.measureNameField setText: [mm description]];
            [self.amountField setText: [NSString stringWithFormat: @"%.1f", mm.grams]];
            
            
        } else {
//            self.food = [[Food alloc] init];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Options" style:UIBarButtonItemStylePlain target:self action:@selector(onClickOptions:)];
    } else {
//        self.food = [[Food alloc] init];
        self.title= @"Add New Food";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.tapView addGestureRecognizer: tap];

   
   // make sure nutrients are loaded, then refresh table view
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[WebQuery singleton] loadNutrients];
      dispatch_async(dispatch_get_main_queue(), ^{
         [self loadData];
      });
   });   
}
- (IBAction)onClickOptions:(id)sender {
    self.sheetSender = sender;
    [self.sheetSender setEnabled: FALSE];
    UIActionSheet *asheet = [[UIActionSheet alloc] initWithTitle:@"Select an Option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle: nil
                                               otherButtonTitles:  @"Save Changes",  @"Delete Food",  nil];
    
    [asheet showFromBarButtonItem:sender animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self.sheetSender setEnabled:TRUE];
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        NSString *item =[actionSheet buttonTitleAtIndex:buttonIndex];
        if ([item isEqualToString:@"Save Changes"]) {
            [self saveFood];
            
        } else if ([item isEqualToString:@"Delete Food"]) {
//            [self deleteFood];
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
                            message1 = [NSString stringWithFormat: @"WARNING: This item is used in %ld servings in your diary.\nAll of these servings will be deleted from the record if you delete this food.\n", servings];
                        }
                        if (ingredients > 0) {
                            message2 = [NSString stringWithFormat: @"WARNING: This item is used as an ingredient in %ld recipes.\nIt will be removed from those recipes if you delete this food.", ingredients];
                        }
                        message = [NSString stringWithFormat: @"%@%@\nAre you sure you want to delete the food '%@'", message1, message2, self.food.name];
                        [self showConfirmationAlertForDeleteFood:message];
                        
                        
                    } else {
                        [self.navigationItem.rightBarButtonItem setEnabled:YES];
                        [self.navigationItem.leftBarButtonItem setEnabled:YES];
                        [Toolbox showMessage:@"An unexpected error ocurred when we tried to delete the food" withTitle:@"Server Error"];
                    }
                });
            });
        }
    }
}
- (void) showConfirmationAlertForDeleteFood:(NSString*)msg
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
        [self deleteFood];
    } else {
        [self hideProgressView];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
}
- (void) saveFood {
    if (self.nameField.text.length < 1) {
        [Toolbox showMessage:@"Please enter a name for this food" withTitle:@"Validation Error"];
        return;
    }
    
    if (self.measureNameField.text.length < 1) {
        [Toolbox showMessage:@"Please enter a name for this food's serving size" withTitle:@"Validation Error"];
        return;
    }
    
    Food *f = self.isEditing ? self.food : [[Food alloc] init];
    f.name = self.nameField.text;
    Measure* m = nil;
    if (self.isEditing) {
        m = [f measure: f.prefMeasureId];
    } else {
        m = [[Measure alloc] init];
        m.amount = 1.0;
    }
    m.name = self.measureNameField.text;
    NSNumber *val = [Formatter numberFromString: self.amountField.text];
    if (val && val.doubleValue > 0) {
        m.grams = val.doubleValue;
    } else {
        [Toolbox showMessage:@"Please enter the weight for this food's serving size" withTitle:@"Validation Error"];
        return;
    }
    if (self.isEditing) {
        [f putMeasure: m];
    } else {
        [f addMeasure: m];
    }
    
    if (self.barcode != nil) {
        f.barcode = self.barcode;
    } else {
        f.barcode = @"";
    }
    
    
    // Adjust all nutrients for the serving size, as they must be recorded as per 100g
    for (NSNumber *key in self.dictAmounts/*self.food.nutrients*/) {
        double val = [self.dictAmounts[key] doubleValue];//[self.food.nutrients[key] doubleValue];
        val *= 100.0 / m.grams;
        f.nutrients[key] = @(val);
    }
    
    // SAVE TO SERVER
    [self showProgressView];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long foodId = [[WebQuery singleton] addFood:f];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
            [self hideProgressView];
            if (foodId != 0) {
                //             if (f.barcode == nil || [f.barcode isEqualToString:@""]) {
                //                [Toolbox showMessage:@"Your new food has been added" withTitle:@"New Food Added"];
                //                 [self.foodSearchVC gotoAddServingVC: foodId];
                //                [self.navigationController popViewControllerAnimated:YES];
                //             } else {
                //                 AddServingViewController* addServingVC = (AddServingViewController*) [Utils newViewControllerWithId:@"addServingVC" In: @"Main1"];
                //
                //                 addServingVC.diary = self.diary;
                //                 addServingVC.addRecipe = nil;
                //                 addServingVC.serving = [[Serving alloc] init];
                //                 [self.navigationController pushViewController: addServingVC animated:YES];
                //                 [addServingVC setFood: foodId];
                if (self.isEditing) {
                    if (self.foodSearchVC != nil) {
                        [self.foodSearchVC gotoAddServingVC: foodId];
                        [self.navigationController popToViewController:self.foodSearchVC animated:NO];
                    } else {
                        [self.navigationController popToViewController:self.diaryVC animated:YES];
                    }
                    
                } else {
                    [self.foodSearchVC gotoAddServingVC: foodId];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                //             }
            } else {
                [Toolbox showMessage:@"An unexpected error ocurred when we tried to add/edit the food" withTitle:@"Server Error"];
            }
        });
    });
}

- (void) deleteFood {
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
                [Toolbox showMessage:@"An unexpected error ocurred when we tried to delete the food" withTitle:@"Server Error"];
            }
        });
    });
}

-(void)dismissKeyboard {
    [self.nameField resignFirstResponder];
    [self.measureNameField resignFirstResponder];
    [self.amountField resignFirstResponder];
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

#pragma mark -
#pragma mark Data


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
    self.dictAmounts = [[NSMutableDictionary alloc] init];
   
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
             self.dictAmounts[@(ni.nId)] = @(0.0);
             
         }
         [self.categories setObject:slist forKey:cat];
      }
   }
    if (self.food != nil && self.isEditing) {
        self.defaultMeasureId = self.food.prefMeasureId;
        Measure* mm = [self.food measure: self.defaultMeasureId];
        for (NSNumber *key in self.food.nutrients) {
            double val = [self.food.nutrients[key] doubleValue];
            
            val = val * mm.grams / 100.0;
            
            self.dictAmounts[key] = @(val);
        }
    }
//   self.nutrients = [[NSArray alloc] initWithArray: nutrientList];
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
    [self dismissKeyboard];
   NSMutableArray *list = [self.categories objectForKey: [self categoryName:indexPath.section]];
   if (list != nil) {
      NutrientInfo *ni = [list objectAtIndex:indexPath.row];
      if (ni != nil) {
         [self.nutrientTable deselectRowAtIndexPath: [self.nutrientTable indexPathForSelectedRow] animated:NO];

//         EditNutrientViewController *vc = [[EditNutrientViewController alloc] initWithNibName:@"EditNutrientView" bundle:[NSBundle mainBundle]];
          EditNutrientViewController* editNutrientVC = (EditNutrientViewController*) [Utils newViewControllerWithId:@"editNutrientVC" In: @"Main1"];
//         editNutrientVC.food = self.food;
          editNutrientVC.dictAmounts = self.dictAmounts;
         editNutrientVC.nutrient = ni;
         [self.navigationController pushViewController:editNutrientVC animated:YES];
      }
   }
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 6;
}

- (NSString *) categoryName: (NSInteger) section {
   switch (section) {
      case 0: return @"General";
      case 1: return @"Vitamins";
      case 2: return @"Minerals";
      case 3: return @"Carbohydrates";
      case 4: return @"Lipids";
      case 5: return @"Protein";
   }
   return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section; {
   return [self categoryName:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   if (self.categories != nil) {
      NSMutableArray *list = [self.categories objectForKey: [self categoryName:section]];
      if (list != nil) {
         return [list count];
      }
   }
   return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
      cell.accessoryType = UITableViewCellAccessoryNone;
   }

   NSMutableArray *list = [self.categories objectForKey: [self categoryName:indexPath.section]];
   if (list != nil) {
       NutrientInfo *ni = [list objectAtIndex:indexPath.row];
       [cell setNutrient: ni andAmount: [self.dictAmounts[@(ni.nId)] doubleValue]];//[cell setNutrient: ni andAmount: [self.food nutrientAmount:ni.nId]];
   }
   
   return cell;
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

#pragma mark -
#pragma mark Misc

- (IBAction)cancel:(id)sender {
    [self dismissKeyboard];
   [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    [self dismissKeyboard];
    [self saveFood];
   
}


@end
