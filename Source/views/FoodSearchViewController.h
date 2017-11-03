//
//  FoodSearchViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 22/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h> 

#import "DiaryEntry.h"
#import "DiaryViewController.h"
#import "AddRecipeViewController.h"

@interface FoodSearchViewController : UIViewController <UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate, UITableViewDelegate> {
   UISearchBar *searchBar;
   UITableView *resultsTable;
   NSArray *results;
   DiaryViewController *__unsafe_unretained diaryVC;
    NSString* barcodeStr;
    BOOL isNewFoodOrRecipeAdded;
    long newFoodId;
}

//@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *resultsTable;
@property (strong) NSArray *results;
@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (unsafe_unretained) AddRecipeViewController *addRecipeVC;
@property (nonatomic) BOOL isFromRecipe;
@property (strong, nonatomic) IBOutlet UITextField *searchbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *barcodeButtonWidth;
@property (strong, nonatomic) IBOutlet UIView *tapView;
@property (strong, nonatomic) IBOutlet UIImageView *searchbarBack;
 
- (void)scanned_result: (NSString*) barcode;
- (void) gotoAddServingVC: (long)foodId ;
- (void) delTopFood: (long) foodid;
@end
