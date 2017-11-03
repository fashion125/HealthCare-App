//
//  AddServingViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 28/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoodSearchViewController.h"
#import "Serving.h"


@interface AddServingViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {
    BOOL isLoaded;
}

@property (nonatomic, strong) IBOutlet UITextField *amount;
@property (nonatomic, strong) IBOutlet UILabel *foodNameLabel; 
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel; 
@property (nonatomic, strong) IBOutlet UISlider *sliderBar;
@property (nonatomic, strong) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UILabel *proteinLabel;
@property (strong, nonatomic) IBOutlet UILabel *carbsLabel;
@property (strong, nonatomic) IBOutlet UILabel *fatLabel;
@property (nonatomic, strong) IBOutlet UITableView *measureChooser;
@property (strong, nonatomic) IBOutlet UIButton *measureButton;
@property (strong, nonatomic) IBOutlet PieChart *macroChart;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIView *dlgView;
@property (strong, nonatomic) IBOutlet UIButton *btnMoreDetails;

@property (readwrite, strong) Serving *serving;
@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (unsafe_unretained) AddRecipeViewController *addRecipeVC;
@property(readwrite) id foodSearchVC;


- (IBAction)showMeasureChooser:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender; 
- (IBAction)showNutrients:(id)sender;

- (void) setFood: (long) foodId;
- (void) updateValues;
- (void) updateValues: (BOOL)includeAmount;
- (void) updatePieChart;


@end
