//
//  SettingViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 7/14/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UISwitch.h>


@interface SettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSInteger mNutrientTargets[7];    
}

@property (strong, nonatomic) IBOutlet UITableView *settingTableView;
@property (strong, nonatomic) IBOutlet UISwitch *swColoriesSummary;
@property (strong, nonatomic) IBOutlet UISwitch *swFullMacroNutrientBreakdown;
@property (strong, nonatomic) IBOutlet UISwitch *swHighlightedTargets;
@property (strong, nonatomic) IBOutlet UISwitch *swWeightGoal;

@property (strong, nonatomic) IBOutlet UITextField* carbs;
@property (strong, nonatomic) IBOutlet UITextField* fat;
@property (strong, nonatomic) IBOutlet UITextField* protein;

@property (strong, nonatomic) IBOutlet UITextField* customBmr;
@property (strong, readwrite) id targetSummaryViewController;
@property (readwrite) double mWeightGoal;
@property (readwrite) BOOL mShowCaloriesSummary;
@property (readwrite) BOOL mShowMacroNutrientBreakdown;
@property (readwrite) BOOL mShowHighlightedTargets;
@property (readwrite) BOOL mShowWeightGoal;
@property (readwrite) int mDietProfileIndex;
@property (readwrite) int mDietProfileCarb;
@property (readwrite) int mDietProfileFat;
@property (readwrite) int mDietProfileProtein;
@property (readwrite) double mSetBmr;
@property (readwrite) double mCustomBmr;


- (void) refreshData;
- (void) resetNutrientTarget: (long)index withValue: (long)val;
@end
