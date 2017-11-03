//
//  AddRecipeViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 7/10/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Food.h"
#import "DiaryViewController.h"

@interface AddRecipeViewController :  UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *ingredients;
@property (nonatomic, strong) NSMutableDictionary *categories;
@property (nonatomic, strong) NSArray *nutrients;
@property (nonatomic, strong) Food *food;
@property (readwrite) double recipeWeight;
@property (readwrite) BOOL isEditing;
@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (unsafe_unretained) /*FoodSearchViewController **/ id foodSearchVC;

@property (strong, nonatomic) IBOutlet UITableView *nutrientTable;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *measureNameField;
@property (strong, nonatomic) id sheetSender;
@property (strong, readwrite) NSString* mustReturnTo;

- (void) addIngredient: (Serving*) serving;
- (void) removeIngredientAt: (NSInteger) index;

@end
