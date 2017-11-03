//
//  AddFoodViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 2014-05-04.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Food.h"
#import "DiaryViewController.h"
#import "FoodSearchViewController.h"

@interface AddFoodViewController :  UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableDictionary *categories;
@property (nonatomic, strong) NSMutableDictionary *dictAmounts;
//@property (nonatomic, strong) NSArray *nutrients;
@property (nonatomic, strong) Food *food;
@property (nonatomic, strong) NSString *barcode;


@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (unsafe_unretained) FoodSearchViewController *foodSearchVC;
@property (readwrite) BOOL isEditing;
@property (readwrite) id sheetSender;

@property (strong, nonatomic) IBOutlet UITableView *nutrientTable;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *measureNameField;
@property (strong, nonatomic) IBOutlet UITextField *amountField;
@property (strong, nonatomic) IBOutlet UIButton *measureButton;


@end
