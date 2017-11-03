//
//  SettingViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 7/14/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "SettingViewController.h"
#import "SetWeightGoalViewController.h"
#import "SelectNutrientTargetViewController.h"
#import "SelectDietProfileViewController.h"
#import "SelectBMRViewController.h"
#import "TargetSummaryViewController.h"
#import "Utils.h"
#import "WebQuery.h"

@interface SettingViewController ()
@property (readwrite, strong) NSMutableArray* mWeightGoalValues;
@property (readwrite, strong) NSMutableArray* mWeightGoalTitles;
@property (readwrite, strong) NSMutableArray* mDietProfiles;
@property (readwrite, strong) NSMutableArray* mBMRValues;
@property (readwrite, strong) NSMutableArray* mBMRTitles;
@property (readwrite, strong) UITextField* activeTextField;
@end

@implementation SettingViewController
//#define kOFFSET_FOR_KEYBOARD 120.0
//
//-(void)keyboardWillShow {
//    // Animate the current view out of the way
//    if (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
//    else if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//    }
//}
//
//-(void)keyboardWillHide {
//    if (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
//    else if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//    }
//}
////method to move the view up/down whenever the keyboard is shown/dismissed
//-(void)setViewMovedUp:(BOOL)movedUp
//{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
//    
//    CGRect rect = self.view.frame;
//    if (movedUp)
//    {
//        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
//        // 2. increase the size of the view so that the area behind the keyboard is covered up.
//        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
//        rect.size.height += kOFFSET_FOR_KEYBOARD;
//    }
//    else
//    {
//        // revert back to the normal state.
//        rect.origin.y += kOFFSET_FOR_KEYBOARD;
//        rect.size.height -= kOFFSET_FOR_KEYBOARD;
//    }
//    self.view.frame = rect;
//    
//    [UIView commitAnimations];
//}
- (void)registerForKeyboardNotifications

{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)keyboardWasShown:(NSNotification*)aNotification

{
    if (self.activeTextField != nil) {
        NSDictionary* info = [aNotification userInfo];
        
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        
        [self.settingTableView setContentInset:contentInsets];
        
        [self.settingTableView setScrollIndicatorInsets:contentInsets];
        
        NSIndexPath *currentRowIndex = [NSIndexPath indexPathForRow:self.activeTextField.tag inSection:0];
        
        [self.settingTableView scrollToRowAtIndexPath:currentRowIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [self.settingTableView setContentInset:contentInsets];
    
    [self.settingTableView setScrollIndicatorInsets:contentInsets];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardWillShow)
    //                                                 name:UIKeyboardWillShowNotification
    //                                               object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardWillHide)
    //                                                 name:UIKeyboardWillHideNotification
    //                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:UIKeyboardWillShowNotification
    //                                                  object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:UIKeyboardWillHideNotification
    //                                                  object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"Settings";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    
    [self initWeightGoalSet];
    [self initDietProfileSet];
    [self initBMRSet];
    
    self.mWeightGoal = 0;
    self.mShowCaloriesSummary = NO;
    self.mShowMacroNutrientBreakdown = YES;
    self.mShowHighlightedTargets = YES;
    self.mShowWeightGoal = NO;
    self.mDietProfileIndex = 1;
    
    self.mSetBmr = 0.2;
    self.mCustomBmr = 0;
    
    mNutrientTargets[0] = 291;
    mNutrientTargets[1] = 303;
    mNutrientTargets[2] = 301;
    mNutrientTargets[3] = 318;
    mNutrientTargets[4] = 401;
    mNutrientTargets[5] = 418;
    mNutrientTargets[6] = 417;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mShowCaloriesSummary = [[WebQuery singleton] getBoolPref: @SHOW_CALORIES_PREF defaultTo:true] == true ? YES : NO;
        self.mShowMacroNutrientBreakdown = [[WebQuery singleton] getBoolPref: @MACROS_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
        self.mShowHighlightedTargets = [[WebQuery singleton] getBoolPref: @CIRCLES_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
        self.mShowWeightGoal = [[WebQuery singleton] getBoolPref: @USER_PREF_SHOW_GOAL defaultTo: true] == true ? YES : NO;
        self.mWeightGoal = [[WebQuery singleton] getDoublePref: @USER_PREF_WEIGHTGOAL_KEY defaultTo: 0];
        
        for (int i = 0; i < 7; i ++) {
            NSString* pref_prefix = [NSString stringWithFormat:@PREF_PREFIX"%d", i];
            mNutrientTargets[i] = [[WebQuery singleton] getIntPref: pref_prefix defaultTo:mNutrientTargets[i]];
        }
        
        self.mDietProfileIndex = (int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_INDEX_KEY defaultTo: 0];
        self.mDietProfileProtein = (int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_PROTEIN_KEY defaultTo: 0 ];
        self.mDietProfileCarb = (int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_CARBS_KEY defaultTo: 0 ];
        self.mDietProfileFat = (int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_LIPIDS_KEY defaultTo: 0 ];
        if (self.mDietProfileIndex == 6) {
            NSDictionary* oldDict = (NSDictionary*)[self.mDietProfiles objectAtIndex: self.mDietProfileIndex];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict addEntriesFromDictionary:oldDict];
            [dict setValue:@(self.mDietProfileProtein) forKey:@"protein"];
            [dict setValue:@(self.mDietProfileCarb) forKey:@"carbs"];
            [dict setValue:@(self.mDietProfileFat) forKey:@"fat"];
            [self.mDietProfiles replaceObjectAtIndex:self.mDietProfileIndex withObject:dict];

        }
        
        self.mSetBmr = [[WebQuery singleton] getDoublePref: @USER_PREF_ACTIVITY defaultTo:0.2];
        self.mCustomBmr = [[WebQuery singleton] getDoublePref: @USER_PREF_CUSTOM_ACTIVITY defaultTo: 0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.settingTableView reloadData];
        });
        
    });
    
    [self registerForKeyboardNotifications];
    
}


- (void) initWeightGoalSet {
    self.mWeightGoalValues = [[NSMutableArray alloc] init];
    self.mWeightGoalTitles = [[NSMutableArray alloc] init];
    [self.mWeightGoalValues addObject:@(-2.0)];
    [self.mWeightGoalValues addObject:@(-1.5)];
    [self.mWeightGoalValues addObject:@(-1.0)];
    [self.mWeightGoalValues addObject:@(-0.5)];
    [self.mWeightGoalValues addObject:@(0)];
    [self.mWeightGoalValues addObject:@(0.5)];
    [self.mWeightGoalValues addObject:@(1.0)];
    [self.mWeightGoalValues addObject:@(2.0)];
    
    [self.mWeightGoalTitles addObject:@"Lose Weight (-2.0 lbs / week)"];
    [self.mWeightGoalTitles addObject:@"Lose Weight (-1.5 lbs / week)"];
    [self.mWeightGoalTitles addObject:@"Lose Weight (-1.0 lbs / week)"];
    [self.mWeightGoalTitles addObject:@"Lose Weight (-0.5 lbs / week)"];
    [self.mWeightGoalTitles addObject:@"Maintain Weight"];
    [self.mWeightGoalTitles addObject:@"Gain Weight (+0.5 lbs / week)"];
    [self.mWeightGoalTitles addObject:@"Gain Weight (+1.0 lbs / week)"];
    [self.mWeightGoalTitles addObject:@"Gain Weight (+2.0 lbs / week)"];
}
- (void) initDietProfileSet {
    
    NSArray *arr = @[
                     @{@"desc": @"Default (Fixed Targets)", @"protein": @(0), @"carbs": @(0), @"fat": @(0)},
                     @{@"desc": @"Even", @"protein": @(1), @"carbs": @(1), @"fat": @(1)},
                     @{@"desc": @"Zone Diet", @"protein": @(3), @"carbs": @(4), @"fat": @(3)},
                     @{@"desc": @"Paleo Diet", @"protein": @(15), @"carbs": @(20), @"fat": @(65)},
                     @{@"desc": @"LFRV / 30bananasaday.com", @"protein": @(1), @"carbs": @(8), @"fat": @(1)},
                     @{@"desc": @"Low Carb Ketogenic", @"protein": @(5), @"carbs": @(1), @"fat": @(5)},
                     @{@"desc": @"Custom", @"protein": @(0), @"carbs": @(0), @"fat": @(0)},
                     ];

    self.mDietProfiles = [NSMutableArray arrayWithArray:arr];
    
}
- (void) initBMRSet {
    NSArray *arrVal = @[ @(0), @(0.2), @(0.5), @(0.9), @(-1)];
    self.mBMRValues = [NSMutableArray arrayWithArray:arrVal];
    NSArray *arrTitle = @[@"None", @"Lightly Active (BMR * 0.2)", @"Moderately Active (BMR * 0.5)", @"Very Active (BMR * 0.9)", @"Custom(kcal)"];
    self.mBMRTitles = [NSMutableArray arrayWithArray:arrTitle];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)save:(id)sender {
    self.mShowCaloriesSummary = [self.swColoriesSummary isOn];
    self.mShowMacroNutrientBreakdown = [self.swFullMacroNutrientBreakdown isOn];
    self.mShowHighlightedTargets = [self.swHighlightedTargets isOn];
    self.mShowWeightGoal = [self.swWeightGoal isOn];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[WebQuery singleton] setPref: @SHOW_CALORIES_PREF withValue: self.mShowCaloriesSummary ? @"true" : @"false" ];
        [[WebQuery singleton] setPref: @MACROS_VISIBLE_PREF withValue: self.mShowMacroNutrientBreakdown ? @"true" : @"false" ];
        [[WebQuery singleton] setPref: @CIRCLES_VISIBLE_PREF withValue: self.mShowHighlightedTargets ? @"true" : @"false" ];
        [[WebQuery singleton] setPref: @USER_PREF_SHOW_GOAL withValue: self.mShowWeightGoal ? @"true" : @"false" ];
        [[WebQuery singleton] setPref: @USER_PREF_WEIGHTGOAL_KEY withValue: [NSString stringWithFormat:@"%f", self.mWeightGoal]];
        
        for (int i = 0; i < 7; i ++) {
            NSString* pref_prefix = [NSString stringWithFormat:@PREF_PREFIX"%d", i];
            [[WebQuery singleton] setPref: pref_prefix withValue: [NSString stringWithFormat:@"%ld", (long)mNutrientTargets[i]] ];
        }
        [[WebQuery singleton] setPref: @USER_PREF_MACRO_INDEX_KEY withValue: [NSString stringWithFormat:@"%d", self.mDietProfileIndex] ];
        [[WebQuery singleton] setPref: @USER_PREF_MACRO_PROTEIN_KEY withValue: (self.protein != nil ? ([self.protein.text isEqualToString: @""] ? self.protein.placeholder : self.protein.text) : [NSString stringWithFormat:@"%d", self.mDietProfileProtein]) ];
        [[WebQuery singleton] setPref: @USER_PREF_MACRO_CARBS_KEY withValue: (self.carbs != nil ? ([self.carbs.text isEqualToString:@""] ? self.carbs.placeholder : self.carbs.text) : [NSString stringWithFormat:@"%d", self.mDietProfileCarb]) ];
        [[WebQuery singleton] setPref: @USER_PREF_MACRO_LIPIDS_KEY withValue: (self.fat != nil ? ([self.fat.text isEqualToString:@""]?self.fat.placeholder : self.fat.text) : [NSString stringWithFormat:@"%d", self.mDietProfileFat]) ];
        
        [[WebQuery singleton] setPref: @USER_PREF_ACTIVITY withValue: [NSString stringWithFormat:@"%.1f", self.mSetBmr] ];
        
        [[WebQuery singleton] setPref: @USER_PREF_CUSTOM_ACTIVITY withValue: (self.customBmr != nil ? ([self.customBmr.text isEqualToString:@""] ? self.customBmr.placeholder : self.customBmr.text) : [NSString stringWithFormat:@"%.1f", self.mCustomBmr]) ];
        
        TargetSummaryViewController* tsvc = (TargetSummaryViewController*)self.targetSummaryViewController;
        if (tsvc.day != nil) {
            [tsvc setSummary: [[WebQuery singleton] getSummary: tsvc.day]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    });
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) refreshData {
    [self.settingTableView reloadData];
}

- (void) resetNutrientTarget: (long)index withValue: (long)val {
    mNutrientTargets[index] = val;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.currentQuestion == 4)
//        return 96;
//    if ([UIScreen is35Inch]) {
//        return 76;
//    }
    return 44;//tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 23;
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    if (indexPath.row >=1 && indexPath.row <=4) {
        reuseId = @"settingSummaryPage";
    } else if (indexPath.row == 6) {
        reuseId = @"settingWeightGoal";
    } else if (indexPath.row >= 8 && indexPath.row <=14) {
        reuseId = @"settingHighlitedNutrientTargets";
    } else if (indexPath.row == 16) {
        reuseId = @"settingDietProfile";
    } else if (indexPath.row >= 17 && indexPath.row <=19) {
        reuseId = @"settingDietProfileProperty";
    } else if (indexPath.row == 21) {
        reuseId = @"settingBMR";
    } else if (indexPath.row == 22) {
        reuseId = @"settingBMRProperty";
    } else {
        reuseId = [NSString stringWithFormat:@"settingID_%ld", (long)indexPath.row];
    }
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:reuseId owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (UITableViewCell *)currentObject;
                break;
            }
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.row == 1 && self.swColoriesSummary == nil) {
        self.swColoriesSummary = (UISwitch*) [cell viewWithTag:7140];
        [self.swColoriesSummary setOn:self.mShowCaloriesSummary];
        UILabel* label = (UILabel*)[cell viewWithTag:7141];
        [label setText:@"Show Calories Summary"];
    } else if (indexPath.row == 2 && self.swFullMacroNutrientBreakdown == nil) {
        self.swFullMacroNutrientBreakdown = (UISwitch*) [cell viewWithTag:7140];
        [self.swFullMacroNutrientBreakdown setOn:self.mShowMacroNutrientBreakdown];
        UILabel* label = (UILabel*)[cell viewWithTag:7141];
        [label setText:@"Show Full Macronutrient Breakdown Summary"];
    } else if (indexPath.row == 3 && self.swHighlightedTargets == nil) {
        self.swHighlightedTargets = (UISwitch*) [cell viewWithTag:7140];
        [self.swHighlightedTargets setOn:self.mShowHighlightedTargets];
        UILabel* label = (UILabel*)[cell viewWithTag:7141];
        [label setText:@"Show Highlighted Targets"];
    } else if (indexPath.row == 4 && self.swWeightGoal == nil) {
        self.swWeightGoal = (UISwitch*) [cell viewWithTag:7140];
        [self.swWeightGoal setOn:self.mShowWeightGoal];
        UILabel* label = (UILabel*)[cell viewWithTag:7141];
        [label setText:@"Show Weight Goal"];
    }
    if (indexPath.row == 6) {
        for (int i = 0; i < [self.mWeightGoalValues count]; i ++) {
            if (self.mWeightGoal == [[self.mWeightGoalValues objectAtIndex:i] doubleValue]) {
                UILabel* weightGoal = (UILabel*) [cell viewWithTag:7151];
                [weightGoal setText:[self.mWeightGoalTitles objectAtIndex:i]];
            }
        }
    }
    if (indexPath.row >= 8 && indexPath.row <=14) {
        UILabel* label = (UILabel*)[cell viewWithTag:7151];
        NSString* desc = [[[WebQuery singleton] nutrient:mNutrientTargets[indexPath.row-8]] description];
        [label setText:desc];
    }
    if (indexPath.row >= 16 && indexPath.row <= 19) {
        NSDictionary* dict = (NSDictionary*)[self.mDietProfiles objectAtIndex: self.mDietProfileIndex];
        if (indexPath.row == 16) {
            UILabel* label = (UILabel*)[cell viewWithTag:7160];
            [label setText:dict[@"desc"]];
        } else if (indexPath.row == 18) {
            UILabel* label = (UILabel*)[cell viewWithTag:7161];
            [label setText: @"Carbs"];
            UITextField* tf = (UITextField*)[cell viewWithTag:7160];
            if (tf != nil) self.carbs = tf;
            else tf = self.carbs;
            
            if (tf != nil) {
                tf.placeholder = [NSString stringWithFormat: @"%d", [((NSNumber*)dict[@"carbs"]) intValue]];
                [tf setText: @""];
                if ([(NSString*)dict[@"desc"] isEqualToString: @"Custom"]) {
                    [tf setEnabled: YES];
                } else {
                    [tf setEnabled:NO];
                }
                tf.tag = indexPath.row;
            }
        } else if (indexPath.row == 19) {
            UILabel* label = (UILabel*)[cell viewWithTag:7161];
            [label setText: @"Fat"];
            
            UITextField* tf = (UITextField*)[cell viewWithTag:7160];
            if (tf != nil) self.fat = tf;
            else tf = self.fat;
            if (tf != nil) {
                tf.placeholder = [NSString stringWithFormat: @"%d", [(NSNumber*)dict[@"fat"] intValue]];
                [tf setText: @""];
                if ([(NSString*)dict[@"desc"] isEqualToString: @"Custom"]) {
                    [tf setEnabled: YES];
                } else {
                    [tf setEnabled:NO];
                }
                tf.tag = indexPath.row;
            }
        } else if (indexPath.row == 17) {
            UILabel* label = (UILabel*)[cell viewWithTag:7161];
            [label setText: @"Protein"];
            
            UITextField* tf = (UITextField*)[cell viewWithTag:7160];
            if (tf!= nil) self.protein = tf;
            else tf = self.protein;
            if (tf != nil) {
                tf.placeholder = [NSString stringWithFormat: @"%d", [(NSNumber*)dict[@"protein"] intValue]];
                [tf setText: @""/*[NSString stringWithFormat: @"%d", [(NSNumber*)dict[@"protein"] intValue]]*/];
                if ([(NSString*)dict[@"desc"] isEqualToString:@"Custom"]) {
                    [tf setEnabled: YES];
                } else {
                    [tf setEnabled:NO];
                }
                tf.tag = indexPath.row;
            }
        }
    }
    if (indexPath.row == 21) {
        UILabel* label = (UILabel*)[cell viewWithTag:7160];
        for (int i = 0; i < [self.mBMRValues count]; i ++) {
            if (self.mSetBmr == [[self.mBMRValues objectAtIndex:i] doubleValue]) {
                [label setText:[self.mBMRTitles objectAtIndex:i]];
            }
        }
    } else if (indexPath.row == 22) {
        UILabel* label = (UILabel*)[cell viewWithTag:7161];
        [label setText: @"kcal(Custom)"];
        
        UITextField* tf = (UITextField*)[cell viewWithTag:7160];
        if (tf != nil) self.customBmr = tf;
        else tf = self.customBmr;
        
        if (tf != nil) {
            tf.placeholder = [NSString stringWithFormat: @"%.1f", self.mCustomBmr];
            [tf setText:@""];

            if (self.mSetBmr == -1) {
                [tf setEnabled: YES];
            } else {
                [tf setEnabled: NO];
            }
            tf.tag = indexPath.row;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activeTextField)  [self.activeTextField resignFirstResponder];
    if (indexPath.row == 6) {
        SetWeightGoalViewController* swg = (SetWeightGoalViewController*)[Utils newViewControllerWithId:@"SetWeightGoalViewController" In: @"Main1"];
        swg.mWeightGoalValues = self.mWeightGoalValues;
        swg.mWeightGoalTitles = self.mWeightGoalTitles;
        swg.setting = self;

        [self.navigationController pushViewController:swg animated:YES];
    } else if (indexPath.row >= 8 && indexPath.row <= 14) {
        SelectNutrientTargetViewController* snt = (SelectNutrientTargetViewController*) [Utils newViewControllerWithId:@"SelectNutrientTargetViewController" In: @"Main1"];
        snt.setting = self;
        snt.nutrientKey = mNutrientTargets[indexPath.row-8];
        snt.index = indexPath.row - 8;
        [self.navigationController pushViewController:snt animated:YES];
    } else if (indexPath.row == 16) {
        SelectDietProfileViewController* sdp = (SelectDietProfileViewController*) [Utils newViewControllerWithId:@"SelectDietProfileViewController" In: @"Main1"];
        sdp.setting = self;
        sdp.mDietProfiles = self.mDietProfiles;
        [self.navigationController pushViewController:sdp animated:YES];
    } else if (indexPath.row == 21) {
        SelectBMRViewController* bmr = (SelectBMRViewController*) [Utils newViewControllerWithId: @"SelectBMRViewController" In: @"Main1"];
        bmr.setting = self;
        bmr.mBMRTitles = self.mBMRTitles;
        bmr.mBMRValues = self.mBMRValues;
        [self.navigationController pushViewController:bmr animated:YES];
    }
}
- (IBAction)customBmrEditingDidBegin:(id)sender {
    //[self textFieldDidBeginEditing:sender];
//    if  (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
    self.activeTextField = sender;
//    UITextField* tf = (UITextField*) sender;
//    CGPoint point = [self.settingTableView convertPoint:tf.bounds.origin fromView:tf];
//    NSIndexPath* path = [self.settingTableView indexPathForRowAtPoint:point];
//    [self.settingTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];

}


- (IBAction)customBmrEditingDidEnd:(id)sender {
    //[self textFieldDidEndEditing:sender];
    UITextField* tf = (UITextField*) sender;
    if ([tf.text isEqualToString:@""]) {
        
    } else {
        tf.placeholder = tf.text;
        tf.text = @"";
        self.mCustomBmr = [tf.placeholder doubleValue];
    }
    self.activeTextField = nil;
}
- (IBAction)dietEditingDidBegin:(id)sender {
    //[self textFieldDidBeginEditing: sender];
//    if  (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
    self.activeTextField = sender;
}
- (IBAction)dietEditingDidEnd:(id)sender {
    UITextField* tf = (UITextField*) sender;
    if ([tf.text isEqualToString:@""]) {
        
    } else {
        tf.placeholder = tf.text;
        tf.text = @"";
        long index = [self.mDietProfiles count] -1;

            NSDictionary* oldDict = (NSDictionary*)[self.mDietProfiles objectAtIndex: index];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict addEntriesFromDictionary:oldDict];
        if ([tf isEqual: self.protein]) {
            [dict setValue:@([tf.placeholder intValue]) forKey:@"protein"];
        } else if ([tf isEqual: self.carbs]) {
            [dict setValue:@([tf.placeholder intValue]) forKey:@"carbs"];
        } else if ([tf isEqual: self.fat]) {
            [dict setValue:@([tf.placeholder intValue]) forKey:@"fat"];
        }
            [self.mDietProfiles replaceObjectAtIndex: index withObject:dict];
            
        
    }
    self.activeTextField = nil;
}
//
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    [self animateTextField: textField up: YES];
//    
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [self animateTextField: textField up: NO];
//}
//
//- (void) animateTextField: (UITextField*) textField up: (BOOL) up
//{
//    const int movementDistance = 80; // tweak as needed
//    const float movementDuration = 0.3f; // tweak as needed
//    
//    int movement = (up ? -movementDistance : movementDistance);
//    
//    [UIView beginAnimations: @"anim" context: nil];
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    [UIView setAnimationDuration: movementDuration];
//    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
//    [UIView commitAnimations];
//}
@end
