//
//  FoodSearchViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 22/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "FoodSearchViewController.h"
#import "AddServingViewController.h"
#import "SearchHit.h" 
#import "FoodSearchTableViewCell.h"
#import "AddFoodViewController.h"
#import "AddRecipeViewController.h"
#import "WebQuery.h" 
#import "Utils.h"
#import "BarcodeScanViewController.h"
#import "UIViewController+Starlet.h"

#import "SWNinePatchImageFactory.h"

@implementation FoodSearchViewController

static NSMutableArray* topFoods = nil;

@synthesize resultsTable;
//@synthesize searchBar;
@synthesize results; 
@synthesize diaryVC;
BOOL isKeyboardVisible = FALSE;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { 
       // nada
    }
    return self;
}

- (void)didReceiveMemoryWarning {
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (isKeyboardVisible == YES) {
//        [self.searchbar resignFirstResponder];
//        return;
//    }
   if ([results count] >  [indexPath row]) {
      SearchHit *hit = [results objectAtIndex: [indexPath row]];
      if (hit != nil) {
//         AddServingViewController *aViewController = [[AddServingViewController alloc] initWithNibName:@"AddServingViewController" bundle:[NSBundle mainBundle]];
          AddServingViewController* addServingVC = (AddServingViewController*) [Utils newViewControllerWithId:@"addServingVC" In: @"Main1"];

         addServingVC.diaryVC = diaryVC;
          addServingVC.foodSearchVC = self;
          addServingVC.addRecipeVC = self.addRecipeVC;
         addServingVC.serving = [[Serving alloc] init];
         [addServingVC setFood: hit.foodId];
         [self.navigationController pushViewController: addServingVC animated:YES];
      }
   }
 }
- (void) delTopFood: (long) foodid {
    if (!topFoods || [topFoods count] <= 0) {
        return;
    }
    
    for (SearchHit* item in topFoods) {
        if (item.foodId == foodid) {
            [topFoods removeObject: item];
            break;
        }
    }
    
}
- (void) loadTopFoods {
   if (!topFoods) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          NSArray* tempArr = [[WebQuery singleton] topFoods];
         
         if (tempArr != nil) {
             topFoods = [NSMutableArray arrayWithArray: tempArr];
            dispatch_async(dispatch_get_main_queue(), ^{
               [self loadTopFoods];
            });
         }
      });
   } else if (!self.results) {
      self.results = [topFoods copy];
      [self.resultsTable reloadData];   
   }
} 

#pragma mark - View lifecycle

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
   [searchBar becomeFirstResponder];
    
    if ([[WebQuery singleton] getIntPref:@"barcode" defaultTo:0] == 1) {
        self.barcodeButtonWidth.constant = 58;
    } else {
        self.barcodeButtonWidth.constant = 0;
    }
    if (isNewFoodOrRecipeAdded) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//            
//                
//            });
//        });
        dispatch_async(dispatch_get_main_queue(), ^{
            
            AddServingViewController* addServingVC = (AddServingViewController*) [Utils newViewControllerWithId:@"addServingVC" In: @"Main1"];
            addServingVC.foodSearchVC = self;
            addServingVC.diaryVC = self.diaryVC;
            addServingVC.addRecipeVC = nil;
            addServingVC.serving = [[Serving alloc] init];
            [addServingVC setFood: newFoodId];
            [self.navigationController pushViewController: addServingVC animated:YES];
            
        });
        
        isNewFoodOrRecipeAdded = NO;
    }
}
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
   // Do any additional setup after loading the view from its nib.
    
    [super viewDidLoad];
   [self loadTopFoods];
    isNewFoodOrRecipeAdded = NO;
   
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[WebQuery singleton] warmCaches];
   });
   
    if (self.isFromRecipe == NO) {
   // Add New Food Button
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addNewFood:)];
        [self.navigationItem setRightBarButtonItems: [NSArray arrayWithObjects: addBtn, nil] animated:NO];
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
    }
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.tapView addGestureRecognizer:tap];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidShow:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidHide:)
//                                                 name:UIKeyboardDidHideNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        id _obj = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect _keyboardFrame = CGRectNull;
        if ([_obj respondsToSelector:@selector(getValue:)]) [_obj getValue:&_keyboardFrame];
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.resultsTable setContentInset:UIEdgeInsetsMake(0.f, 0.f, _keyboardFrame.size.height, 0.f)];
        } completion:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.resultsTable setContentInset:UIEdgeInsetsZero];
        } completion:nil];
    }];
//    [self.resultsTable addGestureRecognizer:tap];
    UIImage* resizableImage = [SWNinePatchImageFactory createResizableNinePatchImageNamed:@"searchbox1.9"];
    [self.searchbarBack setImage: resizableImage];
    [self.searchbar becomeFirstResponder];
}
- (void)keyboardDidShow: (NSNotification *) notif{
    // Do something here
    isKeyboardVisible = YES;
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    isKeyboardVisible = NO;
}
-(void)dismissKeyboard {
    [self.searchbar resignFirstResponder];
}
- (void)viewDidUnload {
//    [self setSearchBar:nil];
    [self setResultsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
- (IBAction)scanBarcode:(id)sender {
    BarcodeScanViewController* scanVC = (BarcodeScanViewController*) [Utils newViewControllerWithId:@"BarcodeScanViewController" In: @"Main1"];
    scanVC.foodSearchVC = self;
    [self.navigationController presentViewController:scanVC animated:YES completion: nil];
}

- (void)scanned_result: (NSString*) barcode {
    if (barcode != nil) {
//        [self.searchBar setText: barcode];
        [self showProgressWithComplete:^{
            long foodId = [[WebQuery singleton] searchFoodByBarcode: barcode];
            if (foodId > 0) {
                AddServingViewController* addServingVC = (AddServingViewController*) [Utils newViewControllerWithId:@"addServingVC" In: @"Main1"];
                addServingVC.foodSearchVC = self;
                addServingVC.diaryVC = diaryVC;
                addServingVC.addRecipeVC = self.addRecipeVC;
                addServingVC.serving = [[Serving alloc] init];
                [addServingVC setFood: foodId];
                [self.navigationController pushViewController: addServingVC animated:YES];
            } else if (foodId == 0) {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
//                                                               message:@"No matches found."
//                                                              delegate:nil
//                                                     cancelButtonTitle:@"OK"
//                                                     otherButtonTitles:nil];
//                [alert show];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                               message:@"No matches found. \nWould you like to create a new custom food from the nutrition label?"
                                                              delegate:self
                                                     cancelButtonTitle:@"No"
                                                     otherButtonTitles:@"Yes",nil];
                barcodeStr = barcode;
                alert.tag = 1001;
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                               message:@"An unexpected scanning error occurred"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
                [alert show];
            }           
            
        }];
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 = Tapped yes
    if (alertView.tag == 1001) {
        if (buttonIndex == 1)
        {
            AddFoodViewController* addFoodVC = (AddFoodViewController*) [Utils newViewControllerWithId:@"addFoodVC" In: @"Main1"];
//            addFoodVC.title = @"Add Food";
            addFoodVC.barcode = barcodeStr;
//            addFoodVC.diary = self.diary;
            addFoodVC.foodSearchVC = self;
            [self.navigationController pushViewController:addFoodVC animated:YES];
            
        }
    }
}
- (void) gotoAddServingVC: (long)foodId {
    isNewFoodOrRecipeAdded = YES;
    newFoodId = foodId;
}

- (IBAction)addNewFood:(id)sender {
//   AddFoodViewController *vc = [[AddFoodViewController alloc] initWithNibName:@"AddFoodView" bundle:[NSBundle mainBundle]];
    [self.searchbar resignFirstResponder];
    UIActionSheet *asheet =
    //    [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ?
    [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle: nil
                       otherButtonTitles:@"Add Food",
     @"Add Recipe",
     nil];
    
    [asheet showFromBarButtonItem:sender animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    [sheetSender setEnabled:TRUE];
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            
        } else {
            NSString *item =[actionSheet buttonTitleAtIndex:buttonIndex];
            if ([item isEqualToString:@"Add Food"]) {
                
                AddFoodViewController* addFoodVC = (AddFoodViewController*) [Utils newViewControllerWithId:@"addFoodVC" In: @"Main1"];
//                addFoodVC.title = @"Add Food";
//                addFoodVC.diary = self.diary;
                addFoodVC.foodSearchVC = self;
                [self.navigationController pushViewController:addFoodVC animated:YES];
                
            } else if ([item isEqualToString:@"Add Recipe"]) {
                AddRecipeViewController* addRecipeVC = (AddRecipeViewController*) [Utils newViewControllerWithId:@"addRecipeVC" In: @"Main1"];
                addRecipeVC.foodSearchVC = self;
                addRecipeVC.diaryVC = nil;//self.diaryVC;
                addRecipeVC.isEditing = NO;
                //addRecipeVC.title = @"Add Recipe";
                [self.navigationController pushViewController:addRecipeVC animated:YES];
            } else {
                
            }
            
        }
    }
}
#pragma mark -

- (void) search: (NSString *)str {
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSArray *res = [[WebQuery singleton] findFoods: str];
      dispatch_async(dispatch_get_main_queue(), ^{
         self.results = res;
         [self.resultsTable reloadData];
      });
   });
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSString *CellIdentifier = @"resueFoodSearchTableViewCell";////@"FoodSearchTableViewCell";
   FoodSearchTableViewCell *cell = (FoodSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

   if (cell == nil) {      
      NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil]; 
      for (id currentObject in topLevelObjects) {
         if(currentObject && [currentObject isKindOfClass:[FoodSearchTableViewCell class]]) {
            cell = (FoodSearchTableViewCell *)currentObject;
            break;
         }
      }
      cell.accessoryType = UITableViewCellAccessoryNone;
   }
   
   if (self.results != nil && self.results.count > indexPath.row) {
      SearchHit *hit = [results objectAtIndex:indexPath.row];
      cell.title.text = [hit description];
      cell.subtitle.text = [hit sourceName];
      cell.title.textColor = [hit sourceColor];
   }
   return cell;
}

#pragma mark -
#pragma mark search bar delegate calls

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
   [self.navigationController popViewControllerAnimated: YES]; 
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   if ([searchText length] >= 3) {
      [self search: searchText];
   } else {
      self.results = [NSArray array];
      [self.resultsTable reloadData];
   }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString* searchText = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([searchText length] >= 3) {
        [self search: searchText];
    } else if ([searchText length] <= 0) {
        self.results = [topFoods copy];
        [self.resultsTable reloadData];
        
    } else {
        self.results = [topFoods copy];
        [self.resultsTable reloadData];
//        self.results = [NSArray array];
//        [self.resultsTable reloadData];
    }    return YES;
}


#pragma mark -

@end
