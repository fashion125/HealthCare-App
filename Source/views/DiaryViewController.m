//
//  DiaryViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 13/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "DiaryViewController.h"
#import "DiaryOptsViewController.h"
#import "UIViewController+Starlet.h"

#import "UIApplication+NetworkActivity.h"
//#import "NSDate+TCUtils.h"
#import "ActionSheetDatePicker.h"

#import "WebQuery.h"
#import "Toolbox.h"
#import "Formatter.h"
#import "DiaryEntry.h"
#import "Exercise.h"
#import "Note.h"
#import "DiaryGroup.h"
#import "FoodSearchViewController.h"
#import "ActivitySearchViewController.h"
#import "AddNoteViewController.h"
#import "AddBiometricViewController.h"
#import "AddServingViewController.h"
#import "AddExerciseViewController.h"
#import "DiaryTableViewCell.h"
#import "DiaryGroupViewCell.h"
#import "TargetSummaryViewController.h"
#import "AddFoodViewController.h"
#import "LoginViewController.h"
#import "HealthKitService.h"
#import "HealthKitPermissionViewController.h"
#import "SettingViewController.h"
#import "Utils.h"
#import "MacroInfoView.h"
#import "CMPopTipView.h"
#import "SetTargetsViewController.h"
#import "AddEntriesMenuBgViewController.h"
#import "AddButtonView.h"

@interface DiaryViewController()
@property (strong, nonatomic) IBOutlet UIButton *addFoodButton;
@property (strong, nonatomic) IBOutlet UIButton *addExerciseButton;
@property (strong, nonatomic) IBOutlet UIButton *addNoteButton;
@property (strong, nonatomic) IBOutlet UIButton *addBiometricButton;
@property (strong, nonatomic) IBOutlet UILabel *completedLabel;
@property (strong, nonatomic) IBOutlet UIImageView *completedImage;
@property (readwrite) BOOL  isLoading;
@property (strong, nonatomic) IBOutlet UIView *addEntriesMenuView;
@property (strong, nonatomic) IBOutlet UILabel *todayGoalCaloryLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *todayGoalViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addFoodButtonTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addExerciseButtonTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addBiometricsButtonTop;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addNotesButtonTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *goalLabelBottom;
@end

@implementation DiaryViewController

@synthesize diaryTable; 
@synthesize diaryEntries;
@synthesize currentDay; 
@synthesize caloriesTargetBar;
@synthesize nutrientsBar;
@synthesize pieChart;
@synthesize pieLabel;
@synthesize editButton;
@synthesize lastUpdate;
@synthesize entryBar;
@synthesize groups;
@synthesize activeGroup;
@synthesize sheetSender;
@synthesize isLoading;

static DiaryViewController *sharedInstance = nil;

+ (DiaryViewController *) singleton {
   return sharedInstance;
} 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   NSLog (@"%@", nibNameOrNil);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.currentDay = [Day today];      
       sharedInstance = self;
    }
    return self;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
    self.currentDay = [Day today];
    sharedInstance = self;
   if ([HKHealthStore isHealthDataAvailable]) {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HealthKitInfoViewOpened"]) {
//        [self openHealthKitInfoView];
    
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HealthKitInfoViewOpened"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
   }
   
   self.navigationController.navigationBar.translucent = NO;
   UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    [self.navigationItem setLeftBarButtonItem:menuBtn];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
    
//   NSString *calImg = @"calendar.png";
//   if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//      calImg = @"calendar_white.png";
//   }
//   
//   UIBarButtonItem *prevBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRewind target:self action:@selector(goPrevDay:)];
//   UIBarButtonItem *calBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:calImg] style:UIBarButtonItemStylePlain target:self action:@selector(showDatePicker:)];
//   
//   UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFastForward target:self action:@selector(goNextDay:)];

    self.editButton = self.editButtonItem;
    
//    AddButtonView* addButtonView = [AddButtonView contentView: self];
//    [addButtonView setFrame:CGRectMake(0, 0, 56, 26)];
//    self.addButton = [[UIBarButtonItem alloc] initWithCustomView:addButtonView];
    
//    self.addButton = [[UIBarButtonItem alloc] initWithCustomView:addButtonView style:UIBarButtonItemStylePlain target:self action:@selector(onClickAdd:)];
//    self.addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(onClickAdd:)];

//
//   self.title= @"Diary";
//   [self.navigationItem setRightBarButtonItems: [NSArray arrayWithObjects: self.addButton, nil] animated:NO];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
//   [self.navigationItem setLeftBarButtonItems: [NSArray arrayWithObjects: prevBtn, calBtn, nil] animated:NO];
   
   [self loadDay: currentDay];
   self.caloriesTargetBar.barCol = [UIColor colorWithHue: 0.125 saturation:0.99 brightness:0.99 alpha:1.0];
    
    self.targetProgressLabel.fillColor = [UIColor whiteColor];
    self.targetProgressLabel.trackColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue: 239/255.0 alpha:1.0];//[UIColor whiteColor];
    self.targetProgressLabel.progressColor = [UIColor purpleColor];
    
    self.targetProgressLabel.trackWidth = 11;//15;//14;
    self.targetProgressLabel.progressWidth = 11;
    
   
   // load day from last time update date
   NSDate *today = [NSDate date];
   NSDate *healthKitStartDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kHealthKitStartDate"];
   if (healthKitStartDate) {
      while (YES) {
         if ([healthKitStartDate compare:today] == NSOrderedAscending) {
             [self loadDay:[Day dayFromDate:healthKitStartDate] updateUI:NO];
         } else {
             break;
         }
         healthKitStartDate = [healthKitStartDate dateByAddingTimeInterval:1*24*60*60];
      }
    } else {
        healthKitStartDate = today;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:healthKitStartDate forKey:@"kHealthKitStartDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)onClickAdd:(id)sender {
    
    if (self.isEditing) {
        [self setEditing:NO animated:YES];
    }
    
    if (self.diary.completed) {
        [self showConfirmationAlertForIncompletedMark];
        return;
    }
    AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*) [Utils newViewControllerWithId:@"AddEntriesMenuBgViewController" In: @"Main"];

    vc.view.backgroundColor = [UIColor clearColor];
    vc.diaryVC = self;
    [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:vc animated:NO completion:nil];
//    [self.navigationController presentViewController:vc animated:YES completion: nil];
}
- (void)viewDidUnload {
   [self setDiaryTable:nil];
   [self setDiaryEntries:nil];
   [self setCaloriesTargetBar:nil];
   [self setNutrientsBar:nil];
   [self setPieChart:nil];
   [self setEditButton:nil];
   [self setEntryBar:nil];
   [self setSheetSender:nil];
   [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
   [super viewWillAppear: animated];
   [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void) viewDidAppear:(BOOL)animated {
   [super viewDidAppear: animated];
   [self.navigationController setNavigationBarHidden:NO animated:animated];
   if (lastUpdate != nil && [[NSDate date] timeIntervalSinceDate: lastUpdate] > 900) {
      // refresh the current dispaly
      NSLog(@"Refreshing Diary...");
      [self loadDay:currentDay];
   } else {
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           BOOL diaryGroupsOn = [self diaryGroupsOn];
           
           dispatch_async(dispatch_get_main_queue(), ^{
               if ((diaryGroupsOn == NO) &&
                   (self.diaryEntries == nil || [self.diaryEntries count] <= 0)) {
                   self.diaryTable.hidden = YES;
                   self.addEntriesMenuView.hidden = NO;
                   [self.todayGoalCaloryLabel setText: [NSString stringWithFormat: @"%d kcal", (int)round(self.diary.summary.weight_goal) ] ];
        //           self.navigationItem.rightBarButtonItem = nil;//self.addButton;
                   [self.addButton setEnabled: NO];
                   [self setMetricsForEmptyDiary];
               } else {
                   self.diaryTable.hidden = NO;
                   self.addEntriesMenuView.hidden = YES;
        //           self.navigationItem.rightBarButtonItem = self.addButton;
                   [self.addButton setEnabled: YES];
                   [self.diaryTable reloadData];
               }
           });
       });
   }
   [self updateNutritionSummary];
    
}
#pragma mark - Diary


// returns an immutable copy of the current diary items
- (NSArray *) curDiaryEntries {
   return [[NSArray alloc] initWithArray: self.diaryEntries];
}

- (void) sortDiaryEntries {
   [diaryEntries sortUsingSelector:@selector(compare:)];
}

// called when an entry has been added to the current diary
- (void) entryAdded: (DiaryEntry *) entry {
   if (entry.entryId) {
      [self.diaryEntries addObject: entry];
      [self sortDiaryEntries];
      [self loadGroups];
      [self.diaryTable reloadData];      
      [self updateNutritionSummary];
       
       [self exportToHealthKit:self.currentDay fromDiary:self.diaryEntries];
   } else {
      NSLog(@"entryAdded: Null Id");
      // show some sort of error alert?
   }
}
 
// called when an entry has been modified in the current diary
- (void) entryChanged: (DiaryEntry *) entry {
   // find old version of this entry and replace it with new one
   for (int i=0; i<[self.diaryEntries count]; i++) {
      DiaryEntry *old = [self.diaryEntries objectAtIndex:i];
      if (old.entryId == entry.entryId && [old class] == [entry class]) {
         [self.diaryEntries replaceObjectAtIndex:i withObject: entry];
      }
   }
   [self.diaryTable reloadData];   
   [self updateNutritionSummary];
    
   [self exportToHealthKit:self.currentDay fromDiary:self.diaryEntries];
}


- (IBAction)addEntry:(id)sender {
   UISegmentedControl *seg = (UISegmentedControl *)sender;
   switch ([seg selectedSegmentIndex]) {
      case 0: [self addServing:sender]; break;
      case 1: [self addExercise:sender]; break;
      case 2: [self addBiometric:sender]; break;
      case 3: [self addNote:sender]; break;
   };
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {

   [super setEditing:editing animated:animated];
   [self.diaryTable setEditing: editing animated: YES];
    if (editing) {
//        [self.addButton setEnabled: NO];
    } else {
        self.navigationItem.rightBarButtonItem = nil;//self.addButton;
//        [self.addButton setEnabled: YES];
    }
}

- (IBAction) showNutrientTargets: (id)sender {
    TargetSummaryViewController* targetSummaryVC = (TargetSummaryViewController*)[Utils newViewControllerWithId:@"targetSummaryVC" In:@"Main1"];
//    targetSummaryVC.title = @"Nutrition Summary";
    [targetSummaryVC setIsFromDiary: YES];
    targetSummaryVC.day = self.currentDay;
    [self.navigationController pushViewController:targetSummaryVC animated:YES];

   // make sure nutrients are loaded, then refresh table view
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[WebQuery singleton] loadNutrients];

      dispatch_async(dispatch_get_main_queue(), ^{
         [targetSummaryVC loadData];
         [targetSummaryVC setAmountsFromDiary:self.diary];
      });
       Diary *diary = [[WebQuery singleton] getDiary:self.currentDay];
       dispatch_async(dispatch_get_main_queue(), ^{
           [targetSummaryVC setAmountsFromDiary:diary];
       });
   });   
}

#if 0
- (IBAction) showAddFood: (id)sender {
    
    AddFoodViewController* addFoodVC = (AddFoodViewController*) [Utils newViewControllerWithId:@"addFoodVC"];
    addFoodVC.title = @"Add Food";
    [self.navigationController pushViewController:addFoodVC animated:YES];
}
#endif

- (IBAction)addServing:(id)sender {
   if (self.isEditing) {
      [self setEditing:NO animated:YES];
   }
//   FoodSearchViewController *aViewController = [[FoodSearchViewController alloc] initWithNibName:@"FoodSearchViewController" bundle:[NSBundle mainBundle]];
    FoodSearchViewController* foodSearchVC = (FoodSearchViewController*)[Utils newViewControllerWithId:@"foodSearchVC"];
   foodSearchVC.diaryVC = self;
   [self.navigationController pushViewController:foodSearchVC animated:YES];
}

- (IBAction)addExercise:(id)sender {   
   if (self.isEditing) {
      [self setEditing:NO animated:YES];
   }
//   ActivitySearchViewController *aViewController = [[ActivitySearchViewController alloc] initWithNibName:@"ActivitySearchViewController" bundle:[NSBundle mainBundle]];
    ActivitySearchViewController* activitySearchVC = (ActivitySearchViewController*)[Utils newViewControllerWithId:@"activitySearchVC"];
   activitySearchVC.diaryVC = self;
   [self.navigationController pushViewController:activitySearchVC animated:YES];  
}

- (IBAction)addBiometric:(id)sender {
   if (self.isEditing) {
      [self setEditing:NO animated:YES];
   }
//   AddBiometricViewController *aViewController = [[AddBiometricViewController alloc] initWithNibName:@"AddBiometricViewController" bundle:[NSBundle mainBundle]];
    AddBiometricViewController* addBiometricVC = (AddBiometricViewController*) [Utils newViewControllerWithId:@"addBiometricVC" In: @"Main1"];
    [addBiometricVC initBiometric];
   addBiometricVC.diaryVC = self;
   [self.navigationController pushViewController:addBiometricVC animated:YES];
}

- (IBAction)addNote:(id)sender {
   if (self.isEditing) {
      [self setEditing:NO animated:YES];
   }
//   AddNoteViewController *aViewController = [[AddNoteViewController alloc] initWithNibName:@"AddNoteViewController" bundle:[NSBundle mainBundle]];
    AddNoteViewController* addNoteVC = (AddNoteViewController*) [Utils newViewControllerWithId:@"addNoteVC" In: @"Main1"];
    [addNoteVC initNote];
   addNoteVC.diaryVC = self;
   [self.navigationController pushViewController:addNoteVC animated:YES];  
}
- (void) rearrangeEntries {
    if (self.diary.completed || (self.diaryEntries == nil || [self.diaryEntries count] <= 0)) return;
    self.navigationItem.rightBarButtonItem = self.editButton;
    [self setEditing: YES animated: YES];
}

- (IBAction)goNextDay:(id)sender {
    if (self.isEditing) {
        [self setEditing: NO animated: YES];
    }
   [currentDay addDays:1];
   [self loadDay: currentDay];
}

- (IBAction)goPrevDay:(id)sender {
    if (self.isEditing) {
        [self setEditing: NO animated: YES];
    }
   [currentDay addDays:-1];
   [self loadDay: currentDay];   
}

#define kDatePickerTag 100

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
   [self loadDay: [Day dayFromDate: selectedDate]];
   [sheetSender setEnabled:YES]; // reenable date button
}

- (void)actionPickerCancelled:(id)senftargetProgressLabelder {
   [sheetSender setEnabled:YES];
}


- (IBAction)showDatePicker:(id)sender {
   
   if ([sender class] == [UIBarButtonItem class]) {
      sender = (UIView *)[sender performSelector:@selector(view)];
   }

   self.sheetSender = sender;
   [sheetSender setEnabled:YES];
   
   [ActionSheetDatePicker showPickerWithTitle:@"Pick Date" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:sender];
   
//   
//   ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc]
//                                               initWithTitle:nil datePickerMode:UIDatePickerModeDate
//                                               selectedDate:[self.currentDay convertToDate]
//                                               target:self action:@selector(dateWasSelected:element:) 
//                                               origin:sender];
//   
//   [actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
//   [actionSheetPicker addCustomButtonWithTitle:@"Yesterday" value:[[NSDate date] TC_dateByAddingCalendarUnits:NSDayCalendarUnit amount:-1]];
//   
//    actionSheetPicker.hideCancel = YES;
//    actionSheetPicker.presentFromRect = [sender bounds];
//   [actionSheetPicker showActionSheetPicker];
}
- (void)showActionButtons: (BOOL) show {
    if (show == YES) {
        self.addFoodButton.hidden = NO;
        self.addExerciseButton.hidden = NO;
        self.addNoteButton.hidden = NO;
        self.addBiometricButton.hidden = NO;
    } else {
        self.addFoodButton.hidden = YES;
        self.addExerciseButton.hidden = YES;
        self.addNoteButton.hidden = YES;
        self.addBiometricButton.hidden = YES;
    }
}
- (void)showCompletedMark: (BOOL) show {
    if (show == YES) {
//        self.completedImage.hidden = NO;
//        self.completedLabel.hidden = NO;
        self.completedMarkImage.hidden = NO;
        self.addButtonImage.hidden = YES;
    } else {
//        self.completedImage.hidden = YES;
//        self.completedLabel.hidden = YES;
        self.completedMarkImage.hidden = YES;
        self.addButtonImage.hidden = NO;
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   [sheetSender setEnabled:TRUE];

   if (buttonIndex != [actionSheet cancelButtonIndex]) {      
      if (buttonIndex == [actionSheet destructiveButtonIndex]) {
         [self logout];
      } else {
         NSString *item =[actionSheet buttonTitleAtIndex:buttonIndex];
          if ([item isEqualToString:@"Edit"]) {
              if (self.diary.completed || (self.diaryEntries == nil || [self.diaryEntries count] <= 0)) return;
              self.navigationItem.rightBarButtonItem = self.editButton;
              [self setEditing: YES animated: YES];
          } else if ([item isEqualToString:@"Copy Previous Day"]) {
             [self copyPreviousDay];
         } else if ([item isEqualToString:@"Import from HealthKit"]) {
             [self importFromHealthKit];
         } else if ([item isEqualToString:@"Export to HealthKit"]) {
             [self exportToHealthKit:self.currentDay fromDiary:self.diaryEntries];
         } else if  ([item isEqualToString:@"Settings"]){

             SettingViewController* settingsVC = (SettingViewController*) [Utils newViewControllerWithId:@"SettingViewController" In: @"Main1"];
             [self.navigationController pushViewController: settingsVC animated:YES];
            
         } else if ([item isEqualToString:@"Set Health Permissions"]) {
             if ( [HealthKitService sharedInstance].userPermissionGranted ) {
                 [self openHealthKitPermissionView];
             }else{
                 [[HealthKitService sharedInstance] setupPermission];
             }
         } else if ([item isEqualToString:@"Mark Day as Incomplete"]) {
             isLoading = YES;
             [self showProgressWithComplete:^{
             
                 [[WebQuery singleton] markDayCompleted:self.currentDay completed:NO];
                 {
                     self.diary.completed = NO;
                     [self showActionButtons:!(self.diary.completed)];
                     [self showCompletedMark:self.diary.completed];
                 };
                 isLoading = NO;
             }];
             
         } else if ([item isEqualToString:@"Mark Day as Complete"]) {
             isLoading = YES;
             [self showProgressWithComplete:^{
                 [[WebQuery singleton] markDayCompleted:self.currentDay completed:YES];
                 {
                     self.diary.completed = YES;
                     [self showActionButtons:!(self.diary.completed)];
                     [self showCompletedMark:self.diary.completed];
                 };
                 isLoading = NO;
             }];
             
         } else if ([item isEqualToString:@"Set Nutrient Targets"]) {
             SetTargetsViewController *setTargetsVC = (SetTargetsViewController *)[Utils newViewControllerWithId:@"setTargetsVC"];
             setTargetsVC.diaryVC = self;
             [self.navigationController pushViewController:setTargetsVC animated:YES];
         }
      }
   }
}

- (void)openHealthKitPermissionView
{
    HealthKitPermissionViewController * vc = [[HealthKitPermissionViewController alloc] init];
    [self presentViewController:vc animated:YES completion:NULL];
}

- (IBAction)showMenu:(id)sender {
//    [self setEditing: YES animated: YES];

    if (self.isEditing) {
        [self setEditing: NO animated: YES];
    }

    if (isLoading == YES) return;
   self.sheetSender = sender;
   [sheetSender setEnabled:FALSE];
    if (self.diary != nil) {
        if (self.diary.completed == YES) {
            UIActionSheet *asheet =
                [HKHealthStore isHealthDataAvailable] ?
                    [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout"
                                       otherButtonTitles:
//                                        @"Edit",
                                         @"Mark Day as Incomplete",
                                         @"Set Health Permissions",
                                        @"Set Nutrient Targets",

                                         //     @"Import from HealthKit", //story #81849002, hide it for now.
                                         nil]
                    : [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel"        destructiveButtonTitle:@"Logout"
                                       otherButtonTitles:
//                       @"Edit",
                       @"Mark Day as Incomplete",
                       @"Set Nutrient Targets",nil];
            
            [asheet showFromBarButtonItem:sender animated:YES];
        } else {
            UIActionSheet *asheet =[HKHealthStore isHealthDataAvailable] ?
                [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout"
                                   otherButtonTitles:
//                 @"Edit",
                 @"Copy Previous Day",
                 @"Mark Day as Complete",
                 @"Set Health Permissions",
                 @"Set Nutrient Targets",
                                     //     @"Import from HealthKit", //story #81849002, hide it for now.
                                     nil]
                : [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout"
                                     otherButtonTitles:
//                   @"Edit",
                   @"Copy Previous Day",
                   @"Mark Day as Complete",
                   @"Set Nutrient Targets",nil];
            
            [asheet showFromBarButtonItem:sender animated:YES];
            
        }
    } else {
        
       UIActionSheet *asheet =
        [HKHealthStore isHealthDataAvailable] ?
        [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout"
                           otherButtonTitles:
//         @"Edit",
         @"Copy Previous Day" ,
         @"Set Health Permissions",
         @"Set Nutrient Targets",

         //     @"Import from HealthKit", //story #81849002, hide it for now.
         nil]
        :
        [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout"
                           otherButtonTitles:
//         @"Edit",
         @"Copy Previous Day",
         @"Set Nutrient Targets",nil];
        
       [asheet showFromBarButtonItem:sender animated:YES];
    }
}

- (void) showConfirmationAlert
{
    // A quick and dirty popup, displayed only once
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                       message:@"Copy the previous day’s items into the current day?"
                                                      delegate:self
                                             cancelButtonTitle:@"No"
                                             otherButtonTitles:@"Yes",nil];
    alert.tag = 1001;
    [alert show];
}

- (void) showConfirmationAlertForIncompletedMark
{
    // A quick and dirty popup, displayed only once
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:@"Your day is marked as Complete.\nAdding an entry will revert it to incomplete."
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    alert.tag = 1002;
    [alert show];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 = Tapped yes
    if (alertView.tag == 1001) {
        if (buttonIndex == 1)
        {
            Day *yesterday = [Day copy:currentDay];
            [yesterday addDays:-1];
            [[WebQuery singleton] copyFrom:yesterday to:currentDay];
            [self loadDay: currentDay];
        }
    } else if (alertView.tag == 1002) {
        if (buttonIndex == 1) {
            isLoading = YES;
            [self showProgressWithComplete:^{
                
                [[WebQuery singleton] markDayCompleted:self.currentDay completed:NO];
                {
                    self.diary.completed = NO;
                    [self showActionButtons:!(self.diary.completed)];
                    [self showCompletedMark:self.diary.completed];
                };
                AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*) [Utils newViewControllerWithId:@"AddEntriesMenuBgViewController" In: @"Main"];
                
                vc.view.backgroundColor = [UIColor clearColor];
                vc.diaryVC = self;
                [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                [self presentViewController:vc animated:NO completion:nil];
                isLoading = NO;
            }];
            
        }
        
    }
}
- (void)copyPreviousDay {
    [self showConfirmationAlert];
   
}

- (void)openHealthKitInfoView
{
    HealthKitPermissionViewController * vc = [[HealthKitPermissionViewController alloc] init];
    vc.isPostLoginMode = YES;
    
    [self presentViewController:vc animated:YES completion:NULL];
}

- (void)exportToHealthKit:(Day*)dateToExport fromDiary:(NSArray*)fromDiary
{
    if (![[HealthKitService sharedInstance] isServiceAccessible]) {
        return;
    }
    
    for (DiaryEntry * item in fromDiary) {
    
        if ([item isKindOfClass:[Biometric class]]) {
            
            Biometric * biometric = (Biometric*)item;
            NSLog(@"diary item mid: %ld", biometric.mId);
            NSLog(@"diary item unit: %ld", biometric.uId);
            NSLog(@"diary item amout: %f", biometric.amount);
            
            if (biometric.mId == 1) {
                float pounds = biometric.uId == 1 ? biometric.amount / kCRON_POUNDS_TO_KG : biometric.amount ;
                [[HealthKitService sharedInstance] saveWeightInPoundsIntoHealthStore:pounds ofDate:[dateToExport convertToDate]];
            }else if (biometric.mId == 2) {
                float inches = biometric.uId == 3 ? biometric.amount / kCRON_INCHES_TO_CM : item.amount ;
                [[HealthKitService sharedInstance] saveHeightInInchesIntoHealthStore:inches ofDate:[dateToExport convertToDate]];
            }else if (biometric.mId == 3) {
                [[HealthKitService sharedInstance] saveHeartRateIntoHealthStore:item.amount ofDate:[dateToExport convertToDate]];
                
            }else if (biometric.mId == 4) {
                [[HealthKitService sharedInstance] saveSystolicBloodPressureIntoHealthStore:item.amount ofDate:[dateToExport convertToDate]];
                
            }else if (biometric.mId == 5) {
                [[HealthKitService sharedInstance] saveDiastolicBloodPressureIntoHealthStore:item.amount ofDate:[dateToExport convertToDate]];
                
            }else if (biometric.mId == 6) {
                [[HealthKitService sharedInstance] saveBloodGlucoseIntoHealthStore:item.amount / 100.0f ofDate:[dateToExport convertToDate]];
                
            }else if (biometric.mId == 7) {
                double celsius = item.amount;
                
                if (biometric.uId == 11) {
                    celsius = [self FtoC:item.amount];
                }
                
                [[HealthKitService sharedInstance] saveBodyTemperatureInCelsiusIntoHealthStore:celsius ofDate:[dateToExport convertToDate]];
                
            }else if (biometric.mId == 8) {
                [[HealthKitService sharedInstance] saveBodyFatPercentageIntoHealthStore:item.amount / 100.0f ofDate:[dateToExport convertToDate]];
            }
            
        }
        
    }
    
    double caloriesBurned = [self getCaloriesBurned:fromDiary]; //kcal
    if (caloriesBurned > 0) {
        [[HealthKitService sharedInstance] saveActiveEnergyBurnedIntoHealthStore:caloriesBurned * 1000 ofDate:[dateToExport convertToDate]];
    }
    
    double caloriesConsumed = [self getCaloriesConsumed:fromDiary]; //kcal
    if (caloriesConsumed > 0) {
        [[HealthKitService sharedInstance] saveDietaryCalorieIntoHealthStore:caloriesConsumed * 1000 ofDate:[dateToExport convertToDate]];
    }
    
    [self exportNutrientToHealthKit:LIPIDS quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryFatTotal amountConverterToGram:1.0f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:SATFAT quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryFatSaturated amountConverterToGram:1.0f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:MONOUNSAT quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryFatMonounsaturated amountConverterToGram:1.0f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:POLYUNSAT quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryFatPolyunsaturated amountConverterToGram:1.0f dateToExport:dateToExport fromDiary:fromDiary];
    
    [self exportNutrientToHealthKit:CHOLESTEROL quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryCholesterol amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:SODIUM quantityTypeIdentifier:HKQuantityTypeIdentifierDietarySodium amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:CARBOHYDRATES quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates amountConverterToGram:1.0f dateToExport:dateToExport fromDiary:fromDiary];

    [self exportNutrientToHealthKit:FIBER quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryFiber amountConverterToGram:1.f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:SUGAR quantityTypeIdentifier:HKQuantityTypeIdentifierDietarySugar amountConverterToGram:1.f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:PROTEIN quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryProtein amountConverterToGram:1.f dateToExport:dateToExport fromDiary:fromDiary];
    
    [self exportNutrientToHealthKit:VITAMIN_A_RAE quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryVitaminA amountConverterToGram:0.001*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    
    [self exportNutrientToHealthKit:VITAMIN_B1 quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryThiamin amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_B2 quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryRiboflavin amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_B3 quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryNiacin amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_B5 quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryPantothenicAcid amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_B6 quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryVitaminB6 amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_B12 quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryVitaminB12 amountConverterToGram:0.001*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_C quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryVitaminC amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_D quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryVitaminD amountConverterToGram:0.025*0.001*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_E quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryVitaminE amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:VITAMIN_K quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryVitaminK amountConverterToGram:0.001*0.001f dateToExport:dateToExport fromDiary:fromDiary];

    [self exportNutrientToHealthKit:CALCIUM quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryCalcium amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:IRON quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryIron amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:FOLATE quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryFolate amountConverterToGram:0.001f*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:BIOTIN quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryBiotin amountConverterToGram:0.001f*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:PHOSPHORUS quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryPhosphorus amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:IODINE quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryIodine amountConverterToGram:0.001f*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:MAGNESIUM quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryMagnesium amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:ZINC quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryZinc amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:SELENIUM quantityTypeIdentifier:HKQuantityTypeIdentifierDietarySelenium amountConverterToGram:0.001f*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:COPPER quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryCopper amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:MANGANESE quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryManganese amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:CHROMIUM quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryChromium amountConverterToGram:0.001f*0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:CHLORIDE quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryChloride amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary]; //?
    [self exportNutrientToHealthKit:POTASSIUM quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryPotassium amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    [self exportNutrientToHealthKit:CAFFEINE quantityTypeIdentifier:HKQuantityTypeIdentifierDietaryCaffeine amountConverterToGram:0.001f dateToExport:dateToExport fromDiary:fromDiary];
    
}

- (void)exportNutrientToHealthKit:(int)nutrientId quantityTypeIdentifier:(NSString*)quantityTypeIdentifier amountConverterToGram:(float)amountConverterToGram dateToExport:(Day*)dateToExport fromDiary:(NSArray*)fromDiary
{
    double amount = [self getNutrientAmount:fromDiary forType:nutrientId];
    if (amount > 0) {
        [[HealthKitService sharedInstance] saveDietaryNutrientAmountInGramIntoHealthStore:amount * amountConverterToGram ofDate:[dateToExport convertToDate] quantityTypeIdentifier:quantityTypeIdentifier];
    }
}

- (double)FtoC:(double)f
{
    double celsius = (f - 32)*(5.0f/9);
    return celsius;
}

 

- (void)importFromHealthKit
{
    if (![[HealthKitService sharedInstance] isServiceAccessible]) {
        return;
    }
    
    //weight
    [[HealthKitService sharedInstance] getUsersWeightOnDate:[self.currentDay convertToDate] completion:^(HKQuantitySample *userWeight, NSError *error) {
        
        if (!error && userWeight.quantity > 0) {
            // metric
            Biometric * biometric = [[Biometric alloc] init];
            biometric.mId = 1;
            biometric.uId = [[WebQuery singleton] getPreferredWeightUnit];
            if (biometric.uId == 1) {
                float kg =  ([userWeight.quantity doubleValueForUnit:[HKUnit gramUnit]] / 1000.0f );
                biometric.amount = kg;
            }else{
                float pounds =  ([userWeight.quantity doubleValueForUnit:[HKUnit poundUnit]] );
                biometric.amount = pounds;
            }
            biometric.day = [Day dayFromDate:userWeight.startDate];
            
            [self saveBiometricData:biometric];
        }
    }];
   
    /*
    HKQuantitySample * userWeight = [[HealthKitService sharedInstance] usersWeight];
    if (userWeight != nil) {
        
        
        NSLog(@"user weight: %@", userWeight);
        
        
        
        // metric
        Biometric * biometric = [[Biometric alloc] init];
        biometric.mId = 1;
        biometric.uId = [[WebQuery singleton] getPreferredWeightUnit];
        if (biometric.uId == 1) {
            float kg =  ([userWeight.quantity doubleValueForUnit:[HKUnit gramUnit]] / 1000.0f );
            biometric.amount = kg;
        }else{
            float pounds =  ([userWeight.quantity doubleValueForUnit:[HKUnit poundUnit]] );
            biometric.amount = pounds;
        }
        
       biometric.day = [self currentDay];
       [self saveBiometricData:biometric];
     
        
    }*/
    
    [[HealthKitService sharedInstance] getUsersHeightOnDate:[self.currentDay convertToDate] completion:^(HKQuantitySample *usersHeight, NSError *error) {
        
        if (!error && usersHeight.quantity > 0) {
            // metric
            Biometric * biometric = [[Biometric alloc] init];
            biometric.mId = 2;
            biometric.uId = [[WebQuery singleton] getPreferredHeightUnit];
            
            
            // metric
            if (biometric.uId == 3) {
                float cm =  ([usersHeight.quantity doubleValueForUnit:[HKUnit meterUnit]] * 100.0f);
                biometric.amount = cm;
            }else{
                float inch =  ([usersHeight.quantity doubleValueForUnit:[HKUnit inchUnit]] );
                biometric.amount = inch;
            }

            biometric.day = [Day dayFromDate:usersHeight.startDate];
            
            [self saveBiometricData:biometric];
        }
    }];
    /*
    //height
    HKQuantitySample * usersHeight = [[HealthKitService sharedInstance] usersHeight];
    if (usersHeight != nil) {
        
        
        NSLog(@"user height: %@", usersHeight);
        
        Biometric * biometric = [[Biometric alloc] init];
        biometric.mId = 2;
        biometric.uId = [[WebQuery singleton] getPreferredHeightUnit];

        
        // metric
        if (biometric.uId == 3) {
            float cm =  ([usersHeight.quantity doubleValueForUnit:[HKUnit meterUnit]] * 100.0f);
            biometric.amount = cm;
        }else{
            float inch =  ([usersHeight.quantity doubleValueForUnit:[HKUnit inchUnit]] );
            biometric.amount = inch;
        }
        
        biometric.day = [self currentDay];
        [self saveBiometricData:biometric];
    }
     */
                
}

- (BOOL)biometericDoesExist:(Biometric*)biometric
{
    for (int i=0; i<[self.diaryEntries count]; i++) {
        Biometric *old = [self.diaryEntries objectAtIndex:i];
        if (old.mId == biometric.mId && [old class] == [biometric class]) {
            biometric.order = old.order;
            biometric.entryId = old.entryId;
            return YES;
        }
    }
    
    return NO;
}

- (void)saveBiometricData:(Biometric*)biometric
{
    __weak __typeof__(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        

        
        if ([self biometericDoesExist:biometric]) {
            [[WebQuery singleton] editBiometric:biometric];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself entryChanged: biometric];
                
            });
            
        }else{
            
            [wself setOrderForNewDiaryEntry:  biometric];
            [[WebQuery singleton] addBiometric:  biometric];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself entryAdded: biometric];
                
            });
            
        }

    });
    
}

- (IBAction)showMacroBreakdown:(id)sender {
   UIActionSheet *popup = [[UIActionSheet alloc]
                           initWithTitle:self.pieLabel
                           delegate:nil cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil otherButtonTitles:nil];
   [popup sizeToFit];   
   [popup showFromRect:self.pieChart.bounds inView:self.pieChart animated:YES];
}


- (double) getCaloriesBurned:(NSArray *) entries {
   double sum = 0;
   for (DiaryEntry *entry in entries) {
      if ([entry isKindOfClass: [Exercise class]]) {
         Exercise *ex = (Exercise *)entry;
         sum += [ex calories];
      }
   }
   return ABS(sum);
}


- (double) getCaloriesConsumed:(NSArray *) entries {
   return [self getNutrientAmount:entries forType:CALORIES];
}


- (double) getNutrientAmount:(NSArray *) entries forType:(long) nutrientId {
   double sum = 0;
   
   for (DiaryEntry *entry in entries) {
      if ([entry isKindOfClass: [Serving class]]) {
          Serving *serving = (Serving *)entry;
          sum += [serving nutrientAmount: nutrientId];
      }
   }
   return sum;
}

//- (void) updateNutritionSummary {
//   NSArray *curDiary = [self curDiary];
//   if ([curDiary count] > 0) {
//      double cals = 0, p = 0, c = 0, f = 0, a = 0;
//      double pg = 0, cg = 0, fg = 0, ag = 0;
//      
//      for (DiaryEntry *entry in curDiary) {
//         if (entry) {
//            cals += [entry calories];
//            if ([entry isKindOfClass: [Serving class]]) {
//               Serving *serving = (Serving *)entry;
//               pg += [serving nutrientAmount: PROTEIN];
//               cg += [serving nutrientAmount: CARBOHYDRATES];
//               fg += [serving nutrientAmount: LIPIDS];
//               ag += [serving nutrientAmount: ALCOHOL];
//               
//               p += [serving nutrientAmount: CALORIES_FROM_PROTEIN];
//               c += [serving nutrientAmount: CALORIES_FROM_CARBOHYDRATES];
//               f += [serving nutrientAmount: CALORIES_FROM_LIPIDS];
//               a += [serving nutrientAmount: CALORIES_FROM_ALCOHOL];
//            }
//         }
//      }
//      Target *target = [[WebQuery singleton] target: CALORIES];
//      double calTarget = [[target min] doubleValue];
//      if ([target min] != nil) {
//         long calPer = round(100 * cals / calTarget);         
//         self.caloriesTargetBar.curValue = cals;
//         self.caloriesTargetBar.maxValue = calTarget;     
//         self.caloriesTargetBar.label = [NSString stringWithFormat: @"Energy: %@ kcal (%ld%%)", [Formatter formatAmount: cals], calPer];
//         self.caloriesTargetNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount: -cals]];
//      } else {
//         self.caloriesTargetBar.curValue = 0;
//         self.caloriesTargetBar.maxValue = 0;     
//         self.caloriesTargetBar.label = [NSString stringWithFormat: @"Energy: No Target"];
//            self.caloriesTargetNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount: 0]];
//      }
//      
//      double total = 0;
//      double value = 0;
//      double result = 0;
//      
//      NSMutableDictionary *nutrients = [NSMutableDictionary dictionary];
//      
//      for (DiaryEntry *entry in curDiary) {
//         if (entry && [entry isKindOfClass: [Serving class]]) {
//            Serving *serving = (Serving *)entry;
//            for (Target *t in [[WebQuery singleton] getTargets]) {
//               NSNumber *key = [NSNumber numberWithLong: t.nutrientId];               
//               NSNumber *val = [nutrients objectForKey: key];
//               if (val) {
//                  val = [NSNumber numberWithDouble: ([val doubleValue] + [serving nutrientAmount: t.nutrientId])];
//               } else {
//                  val = [NSNumber numberWithDouble:  [serving nutrientAmount: t.nutrientId]];
//               }
//               [nutrients setObject:val forKey:key];
//            }
//         }
//      }
//      
//      for (Target *t in [[WebQuery singleton] getTargets]) {
//         if (t.visible && t.min != nil && [t.min doubleValue] > 0) {
//            NSNumber *key = [NSNumber numberWithLong: t.nutrientId];                
//            NSNumber *amount = [nutrients objectForKey: key];
//            if (amount != nil) {
//               if ([amount doubleValue] < [t.min doubleValue]) {
//                  value += [amount doubleValue] / [t.min doubleValue];
//               } else {
//                  value++;
//               }
//            }
//            total++;            
//         }
//         result = value / total;
//      }
//      result = round(100*result);
//      self.nutrientsBar.curValue = value;
//      self.nutrientsBar.maxValue = total;     
//      self.nutrientsBar.label = [NSString stringWithFormat: @"%d%% of Nutritional Targets Achieved", (int)result];
//      self.nutrientsNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount:value]];
//      self.nutrientsTargetPercentageLabel.text = [NSString stringWithFormat: @"%d%%", (int)result];
//       self.targetProgressLabel.progress = value/total;
//
//      //0xAA, 0xFF, 0xAA
//      [self.pieChart clearSlices];
//      [self.pieChart addSlice: p color: [PieChart greenColor]];
//      [self.pieChart addSlice: c color:  [PieChart blueColor]];
//      [self.pieChart addSlice: f color:  [PieChart redColor]];
//      [self.pieChart addSlice: a color: [UIColor yellowColor ] ];
//      
//      double t = p+c+f+a;
//      if (t > 0) {
//         self.pieLabel = [NSString stringWithFormat:@"\nProtein: %0.1fg, %.0f kcal, %.0f%%\n Carbs: %0.2fg, %.0f kcal, %.0f%%\n Fats: %0.2fg, %.0f kcal, %.0f%%",
//                       pg,p,100*p/t,
//                       cg,c,100*c/t,
//                       fg,f,100*f/t];
//         NSLog(@"%@", self.pieLabel);
//          self.nonMacroLabel.hidden = YES;
//      } else {
//         self.pieLabel = @"No Data";
//          self.nonMacroLabel.hidden = NO;
//      }
//      
//   } else {
//      [self.pieChart clearSlices];      
//      self.caloriesTargetBar.curValue = 0;   
//      self.caloriesTargetBar.label = [NSString stringWithFormat: @"Energy: %@ kcal (%d%%)", [Formatter formatAmount: 0.0], 0];
//      self.caloriesTargetNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount: 0]];
//      self.nutrientsBar.curValue = 0; 
//      self.nutrientsBar.label = [NSString stringWithFormat: @"%d%% of Nutritional Targets Achieved", (int)0];
//      self.nutrientsNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount:0]];
//      self.nutrientsTargetPercentageLabel.text = [NSString stringWithFormat: @"%d%%", (int)0];
//      self.targetProgressLabel.progress = 0;
//   }
//   
//   [self.caloriesTargetBar setNeedsDisplay];
//   [self.nutrientsBar setNeedsDisplay];
//   [self updateDiaryGroupHeaders];
//}
//

- (void) updateNutritionSummary {
    NSArray *curDiaryEntries = [self curDiaryEntries];
    if ([curDiaryEntries count] > 0) {
        double p = 0, c = 0, f = 0, a = 0;
        double pg = 0, cg = 0, fg = 0, ag = 0;
        double burned = 0, consumed = 0;
        
        for (DiaryEntry *entry in curDiaryEntries) {
            if (entry) {
                double kcals = [entry calories];
                if (kcals > 0) {
                    consumed += kcals;
                } else {
                    burned += kcals;
                }
                if ([entry isKindOfClass: [Serving class]]) {
                    Serving *serving = (Serving *)entry;

                   pg += [serving nutrientAmount: PROTEIN];
                   cg += [serving nutrientAmount: CARBOHYDRATES];
                   fg += [serving nutrientAmount: LIPIDS];
                   ag += [serving nutrientAmount: ALCOHOL];
                    
                    p += [serving nutrientAmount: CALORIES_FROM_PROTEIN];
                    c += [serving nutrientAmount: CALORIES_FROM_CARBOHYDRATES];
                    f += [serving nutrientAmount: CALORIES_FROM_LIPIDS];
                    a += [serving nutrientAmount: CALORIES_FROM_ALCOHOL];
                }
            }
        }
        burned -= self.diary.summary.burned.bmr_kcal;
        burned -= self.diary.summary.burned.activity_kcal;
        
        Target *target = [[WebQuery singleton] target: CALORIES];
//        double calTarget = [[target min] doubleValue];
        if ([target min] != nil) {
//            long calPer = round(100 * cals / calTarget);
//            self.caloriesTargetBar.curValue = cals;
//            self.caloriesTargetBar.maxValue = calTarget;
//            self.caloriesTargetBar.label = [NSString stringWithFormat: @"Energy: %@ kcal (%ld%%)", [Formatter formatAmount: cals], calPer];
            self.caloriesTargetNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount: roundf(-burned)]];
        } else {
//            self.caloriesTargetBar.curValue = 0;
//            self.caloriesTargetBar.maxValue = 0;
//            self.caloriesTargetBar.label = [NSString stringWithFormat: @"Energy: No Target"];
            self.caloriesTargetNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount: 0]];
        }
        
        double total = 0;
        double value = 0;
        double result = 0;
        
        NSMutableDictionary *nutrients = [NSMutableDictionary dictionary];
        
        for (DiaryEntry *entry in curDiaryEntries) {
            if (entry && [entry isKindOfClass: [Serving class]]) {
                Serving *serving = (Serving *)entry;
                for (Target *t in [[WebQuery singleton] getTargets]) {
                    NSNumber *key = [NSNumber numberWithLong: t.nutrientId];
                    NSNumber *val = [nutrients objectForKey: key];
                    if (val) {
                        val = [NSNumber numberWithDouble: ([val doubleValue] + [serving nutrientAmount: t.nutrientId])];
                    } else {
                        val = [NSNumber numberWithDouble: [serving nutrientAmount: t.nutrientId]];
                    }
                    [nutrients setObject:val forKey:key];
                }
            }
        }
        
        for (Target *t in [[WebQuery singleton] getTargets]) {
            if (t.visible && t.min != nil && [t.min doubleValue] > 0) {
                NSNumber *key = [NSNumber numberWithLong: t.nutrientId];
                NSNumber *amount = [nutrients objectForKey: key];
                if (amount != nil) {
                    if ([amount doubleValue] < [t.min doubleValue]) {
                        value += [amount doubleValue] / [t.min doubleValue];
                    } else {
                        value++;
                    }
                }
                total++;
            }
            result = value / total;
        }
        result = round(100*result);
//        self.nutrientsBar.curValue = value;
//        self.nutrientsBar.maxValue = total;
//        self.nutrientsBar.label = [NSString stringWithFormat: @"%d%% of Nutritional Targets Achieved", (int)result];
        self.nutrientsNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount:round(consumed)]];
        self.nutrientsTargetPercentageLabel.text = [NSString stringWithFormat: @"%d%%", (int)result];
        self.targetProgressLabel.progress = value/total;
        if (value > 0) {
            self.targetProgressLabel.trackColor = /*[UIColor colorWithRed:239/255.0 green:239/255.0 blue: 239/255.0 alpha:1.0];*/[UIColor whiteColor];
        } else {
            self.targetProgressLabel.trackColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue: 239/255.0 alpha:1.0];
        }
        self.targetProgressLabel.progressColor = [UIColor purpleColor];
        
        //0xAA, 0xFF, 0xAA
        [self.pieChart clearSlices];
        [self.pieChart addSlice: p color: [PieChart greenColor]];
        [self.pieChart addSlice: c color:  [PieChart blueColor]];
        [self.pieChart addSlice: f color:  [PieChart redColor]];
        [self.pieChart addSlice: a color: [UIColor yellowColor ] ];
        
        double t = p+c+f+a;
        if (t > 0) {
            self.pieLabel = [NSString stringWithFormat:@"\nProtein: %0.1fg, %.0f kcal, %.0f%%\n Carbs: %0.2fg, %.0f kcal, %.0f%%\n Fats: %0.2fg, %.0f kcal, %.0f%%",
                             pg,p,100*p/t,
                             cg,c,100*c/t,
                             fg,f,100*f/t];
            NSLog(@"%@", self.pieLabel);
//            self.nonMacroLabel.hidden = YES;
        } else {
//            self.pieLabel = @"No Data";
//            self.nonMacroLabel.hidden = NO;
        }
        
    } else {
        [self.pieChart clearSlices];
        self.caloriesTargetBar.curValue = 0;
        self.caloriesTargetBar.label = [NSString stringWithFormat: @"Energy: %@ kcal (%d%%)", [Formatter formatAmount: 0.0], 0];
        self.caloriesTargetNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount: 0]];
        self.nutrientsBar.curValue = 0;
        self.nutrientsBar.label = [NSString stringWithFormat: @"%d%% of Nutritional Targets Achieved", (int)0];
        self.nutrientsNumberLabel.text = [NSString stringWithFormat: @"%@", [Formatter formatAmount:0]];
        self.nutrientsTargetPercentageLabel.text = [NSString stringWithFormat: @"%d%%", (int)0];
        self.targetProgressLabel.progress = 0;
        self.targetProgressLabel.trackColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue: 239/255.0 alpha:1.0];
    }
    
    [self.caloriesTargetBar setNeedsDisplay];
    [self.nutrientsBar setNeedsDisplay];
    [self updateDiaryGroupHeaders];
}


- (bool) diaryGroupsOn {
   return [WebQuery singleton].gold && [[WebQuery singleton] getBoolPref: @"DG_ON" defaultTo: false];
}

- (IBAction)pressMacro:(id)sender {
    [self dismissAllPopTipViews];
    if (self.visiblePopTipViews == nil) {
        self.visiblePopTipViews = [NSMutableArray array];
    }
    if (sender == self.currentPopTipViewTarget) {
        // Dismiss the popTipView and that is all
        self.currentPopTipViewTarget = nil;
    }
    else {
        CMPopTipView *popTipView;
        MacroInfoView* infoView = nil;
        infoView = [MacroInfoView contentView];
        
        NSArray *curDiaryEntries = [self curDiaryEntries];
        if ([curDiaryEntries count] > 0) {
            double p = 0, c = 0, f = 0, a = 0;
            
            for (DiaryEntry *entry in curDiaryEntries) {
                if (entry) {
                    if ([entry isKindOfClass: [Serving class]]) {
                        Serving *serving = (Serving *)entry;
                        
                        p += [serving nutrientAmount: CALORIES_FROM_PROTEIN];
                        c += [serving nutrientAmount: CALORIES_FROM_CARBOHYDRATES];
                        f += [serving nutrientAmount: CALORIES_FROM_LIPIDS];
                        a += [serving nutrientAmount: CALORIES_FROM_ALCOHOL];
                    }
                }
            }
            
            double t = p+c+f+a;
            if (t > 0) {
                [infoView setValuesWith:100*p/t carbs:100*c/t lipids:100*f/t alchol:100*a/t];
            } else {
                [infoView setValuesWith:0 carbs:0 lipids:0 alchol:0];
            }
            
        } else {
            [infoView setValuesWith:0 carbs:0 lipids:0 alchol:0];
        }
        
        popTipView = [[CMPopTipView alloc] initWithCustomView:infoView];
        popTipView.delegate = (id<CMPopTipViewDelegate>)self;
        
//        popTipView.animation = arc4random() % 2;
        popTipView.borderWidth = 0;
        popTipView.backgroundColor = [UIColor grayColor];
        popTipView.hasGradientBackground = NO;

        popTipView.has3DStyle = NO;//(BOOL)(arc4random() % 2);
        popTipView.cornerRadius = 7;
        popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:3.0];
        
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            [popTipView presentPointingAtView:button inView:self.view animated:YES];
        }
        [self.visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
    }
}
#pragma mark - CMPopTipViewDelegate methods
- (void)dismissAllPopTipViews
{
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
}

- (void) updateDiaryGroupHeaders {
   if ([self diaryGroupsOn] && [[WebQuery singleton] getBoolPref: @"DG_KCAL" defaultTo: true]) {
      NSArray *curDiary = [self curDiaryEntries];
      for (DiaryGroup *group in groups) {
         double kcal = 0;
         for (DiaryEntry *entry in curDiary) {
            if (entry && group.group == [entry getGroup] && ([entry isKindOfClass: [Serving class]] || [entry isKindOfClass: [Exercise class]])) {
               kcal += [entry calories];
            }
         }
         group.calories = kcal;
      }
       [self.diaryTable reloadData];
   }
}


const NSInteger kMaxDiaryGroups = 8;

- (void) loadGroups {
   if ([self diaryGroupsOn]) {
      if (groups != nil) {
         [groups removeAllObjects];
      } else {
         self.groups = [NSMutableArray arrayWithCapacity: kMaxDiaryGroups];
      }
   }
   for (int i=0; i<kMaxDiaryGroups; i++) {
      //if ([[WebQuery singleton] getBoolPref: [NSString stringWithFormat:@"DG%02dON", i+1] defaultTo: true]) {
         DiaryGroup *dg = [[DiaryGroup alloc] init];
         dg.group = i;
         dg.visible = [[WebQuery singleton] getBoolPref: [NSString stringWithFormat:@"DG%02dON", i+1] defaultTo: false];
    
         for (DiaryEntry *entry in [self curDiaryEntries]) {
            if ([entry getGroup] == dg.group) {
               dg.count++;
            }
         }         
         
         [groups addObject: dg];
      //}
   }
}

- (void) setOrderForNewDiaryEntry: (DiaryEntry *) entry {
   [entry setGroup: activeGroup];
   long max = 0;
   for (DiaryEntry *entry in [self curDiaryEntries]) {
      if ([entry getGroup] == activeGroup) {
         if ([entry getSeq] > max) {
            max = [entry getSeq];
         }
      }
   }         
   [entry setSeq: max+1];
}


- (void) refreshData {
   [self loadDay: [Day today]];
}

- (void) setMetricsForEmptyDiary {
    if ([Utils isIPad]) {
        return;
    }
    if ([Utils isIPhone4_or_less]) {
        self.todayGoalViewHeight.constant = 50;
        self.addFoodButtonTop.constant = 4;
        self.addExerciseButtonTop.constant = 6;
        self.addBiometricsButtonTop.constant = 6;
        self.addNotesButtonTop.constant = 6;
        self.goalLabelBottom.constant = 0;
    } else if ([Utils isIPhone5] || [Utils isIPhone5s]) {
        
    } else {
        self.todayGoalViewHeight.constant = 90;
        self.addFoodButtonTop.constant = 16;
        self.addExerciseButtonTop.constant = 20;
        self.addBiometricsButtonTop.constant = 20;
        self.addNotesButtonTop.constant = 20;
        self.goalLabelBottom.constant = 4;
    }
}
- (void) loadDay: (Day *)day {
    [self loadDay:day updateUI:YES];
}

- (void) loadDay: (Day *)day updateUI:(BOOL)updateUI{
    if (updateUI) {
        self.currentDay = day;
        self.lastUpdate = [NSDate date];
        
//        self.nonMacroLabel.hidden = NO;
    }
   dispatch_async(dispatch_get_main_queue(), ^{
      [[UIApplication sharedApplication] showNetworkActivityIndicator];
   });

    [self showProgressView];
    
//    if (self.navigationItem.rightBarButtonItem != nil) {
//        [self.navigationItem.rightBarButtonItem setEnabled:NO];
//    }
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.addButton setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      Diary *fetchedDiary = [[WebQuery singleton] getDiary: day];
        BOOL diaryGroupsOn = [self diaryGroupsOn];
       self.diary = fetchedDiary;
        dispatch_async(dispatch_get_main_queue(), ^{
          [self hideProgressView];
//          if (self.navigationItem.rightBarButtonItem != nil) {
//              [self.navigationItem.rightBarButtonItem setEnabled:YES];
//          }
          [self.navigationItem.leftBarButtonItem setEnabled:YES];
          [self.addButton setEnabled:YES];
          if (fetchedDiary != nil) {
              [self showActionButtons:!(self.diary.completed)];
              [self showCompletedMark:self.diary.completed];
              if (updateUI) {
                  // Make sure that currentDay == day, to handle laggy responses
                  if (currentDay != day) return;
                  self.diaryEntries = [NSMutableArray arrayWithArray: fetchedDiary.diaryEntries];
                  [self loadGroups];
                  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                      [self.dateButton setTitle: [@"" stringByAppendingString: [currentDay formatLong]] forState:UIControlStateNormal];
                      [self.dateLabel setText: [@"" stringByAppendingString: [currentDay formatLong]]];
                      
                  } else {
//                      [self.dateButton setTitle: [@"  " stringByAppendingString: [currentDay formatShort]] forState:UIControlStateNormal];
                      [self.dateLabel setText: [@"" stringByAppendingString: [currentDay formatShort]]];
                  }
                  if ((diaryGroupsOn == NO) &&
                      (self.diaryEntries == nil || [self.diaryEntries count] <= 0)) {
                      self.diaryTable.hidden = YES;
                      self.addEntriesMenuView.hidden = NO;
                      self.navigationItem.rightBarButtonItem = nil;//self.addButton;
                      [self.todayGoalCaloryLabel setText: [NSString stringWithFormat: @"%d kcal", (int)round(self.diary.summary.weight_goal) ] ];
                      [self setMetricsForEmptyDiary];
                      [self.addButton setEnabled: NO];
                  } else {
                      self.diaryTable.hidden = NO;
                      self.addEntriesMenuView.hidden = YES;
//                      self.navigationItem.rightBarButtonItem = self.addButton;
                      [self.addButton setEnabled: YES];
                      [self.diaryTable reloadData];
                  }
                  [self updateNutritionSummary];
              }
              [self showActionButtons:!(self.diary.completed)];
              [self showCompletedMark:self.diary.completed];
              [self exportToHealthKit:day fromDiary:fetchedDiary.diaryEntries];
              
          }
          [[UIApplication sharedApplication] hideNetworkActivityIndicator];
      });
   });
//    [self showProgressWithComplete:^{
//        Diary *fetchedDiary = [[WebQuery singleton] getDiary: day];
//        self.diary = fetchedDiary;
//        
//        if (fetchedDiary != nil) {
//            [self showActionButtons:!(self.diary.completed)];
//            [self showCompletedMark:self.diary.completed];
//            if (updateUI) {
//                // Make sure that currentDay == day, to handle laggy responses
//                if (currentDay != day) return;
//                self.diaryEntries = [NSMutableArray arrayWithArray: fetchedDiary.diaryEntries];
//                [self loadGroups];
//                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                    [self.dateButton setTitle: [@"" stringByAppendingString: [currentDay formatLong]] forState:UIControlStateNormal];
//                    
//                } else {
//                    [self.dateButton setTitle: [@"  " stringByAppendingString: [currentDay formatShort]] forState:UIControlStateNormal];
//                }
//                if (self.diaryEntries == nil || [self.diaryEntries count] <= 0) {
//                    self.diaryTable.hidden = YES;
//                    self.addEntriesMenuView.hidden = NO;
//                    self.navigationItem.rightBarButtonItem = nil;//self.addButton;
//                    [self setMetricsForEmptyDiary];
//                } else {
//                    self.diaryTable.hidden = NO;
//                    self.addEntriesMenuView.hidden = YES;
//                    self.navigationItem.rightBarButtonItem = self.addButton;
//                    [self.diaryTable reloadData];
//                }
//                [self updateNutritionSummary];
//            }
//            [self showActionButtons:!(self.diary.completed)];
//            [self showCompletedMark:self.diary.completed];
//            [self exportToHealthKit:day fromDiary:fetchedDiary.diaryEntries];
//            
//        }
//        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
//
//    }];
}

- (void) logout {
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[WebQuery singleton] logout];
   });
   
   dispatch_async(dispatch_get_main_queue(), ^{
      if (LoginViewController.singleton) {
         [self.navigationController popToViewController:LoginViewController.singleton animated:YES];
      } else {
         [self.navigationController popViewControllerAnimated: YES];
      }
   });
}

#pragma mark -
#pragma mark Table view data source

- (long) diaryIndexForIndexPath: (NSIndexPath*)indexPath {
   long index = indexPath.row;
   if (groups != nil) {
      int offset = 0;
      for (int i=0; i<indexPath.section; i++) {
         DiaryGroup *dg = [groups objectAtIndex:i];
         offset += dg.count;
      }
      index = offset+indexPath.row;      
   }   
   return index;
}

- (DiaryEntry *) entryForIndexPath: (NSIndexPath*)indexPath {
   long index = [self diaryIndexForIndexPath: indexPath];
   if (index < [diaryEntries count]) {
      return [diaryEntries objectAtIndex: index];
   } else {
      return nil;
   }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   if (groups != nil) {
      return [groups count];
   }
   return 1;
}
- (BOOL) isLastGroup:(NSInteger) section {
    if (groups == nil) return NO;
    
    DiaryGroup *group1 = [groups objectAtIndex:section];
    if (!group1.visible) {
        return NO;
    }

    for (long i = section+1; i < [groups count]; i ++) {
        DiaryGroup *group = [groups objectAtIndex:i];
        if (group.visible) {
            return NO;
        }
    }
    return YES;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (groups == nil) return 0;
    DiaryGroup *group = [groups objectAtIndex:section];
    if ([self isLastGroup:section] && group.count == 0) {
        return 50;
    }
    if (group.visible) return 30;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //return nil;
    
   if (groups == nil) {
     return @"";//[NSString stringWithFormat: @"Diary for %@", [currentDay formatLong]];
   } else {
     return nil;
   }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   if (groups != nil) {
      DiaryGroup *group = [groups objectAtIndex:section];
      return group.count;
   } else {
      return [diaryEntries count];
   }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {   
//   DiaryTableViewCell *cell = nil;
//   if (groups != nil) {
//      NSString *cellIdentifier = @"DiaryGroupTableViewCell";
//      cell = (DiaryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//      if (cell == nil) {
//         NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
//         for (id currentObject in topLevelObjects) {
//            if(currentObject && [currentObject isKindOfClass:[DiaryTableViewCell class]]) {
//               cell = (DiaryTableViewCell *)currentObject;
//               break;
//            }
//         }
//         cell.accessoryType = UITableViewCellAccessoryNone;
//      }    
//      cell.diary = self;
//      
//      [cell setEntry: [groups objectAtIndex:section]];
//       UITableViewHeaderFooterView *cellView = [[UITableViewHeaderFooterView alloc] init];
//       cellView.frame = cell.frame;
//       [cellView addSubview:cell];
////       tableView.tableHeaderView = cellView;
//       return cellView;
//   }
//   return cell; 
//}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DiaryGroupViewCell *cell = nil;
    if (groups != nil) {
        NSString *cellIdentifier = @"DiaryGroupViewCell";
        cell = (DiaryGroupViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if(currentObject && [currentObject isKindOfClass:[DiaryGroupViewCell class]]) {
                    cell = (DiaryGroupViewCell *)currentObject;
                    break;
                }
            }
//            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.diary = self;
        
        [cell setEntry: [groups objectAtIndex:section]];
//        UITableViewHeaderFooterView *cellView = [[UITableViewHeaderFooterView alloc] init];
//        cellView.frame = cell.frame;
//        [cellView addSubview:cell];
//        //       tableView.tableHeaderView = cellView;
//        return cellView;
    }
    return cell; 
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {   
   DiaryTableViewCell *cell = nil;
   
   DiaryEntry *entry = [self entryForIndexPath: indexPath];   
   
   NSString *cellIdentifier = @"DiaryTableViewCell";
   if (entry && [entry isKindOfClass: [Note class]]) {
      cellIdentifier = @"NoteTableViewCell";
   }
   
   cell = (DiaryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
   if (cell == nil) {      
      NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
      for (id currentObject in topLevelObjects) {
         if(currentObject && [currentObject isKindOfClass:[DiaryTableViewCell class]]) {
            cell = (DiaryTableViewCell *)currentObject;
            break;
         }
      }
      cell.accessoryType = UITableViewCellAccessoryNone;
       if (groups == nil) {
           if (indexPath.row % 2) {
               cell.contentView.backgroundColor = [[UIColor alloc]initWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1] ;
           } else {
               cell.contentView.backgroundColor = [UIColor colorWithRed:255/255.0f
                                                                  green:255/255.0f
                                                                   blue:255/255.0f
                                                                  alpha:1.0] ;
           }
       } else {
           DiaryGroup *group = [groups objectAtIndex:indexPath.section];
           if (group.visible != YES) {
               long count = 0;
               for (long i = indexPath.section-1; i >= 0; i --) {
                   DiaryGroup* group1 = [groups objectAtIndex:i];
                   count += group1.count;
                   if (group1.visible) {
                       break;
                   }
               }
               if ((count+indexPath.row) % 2) {
                   cell.contentView.backgroundColor = [[UIColor alloc]initWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1] ;
               } else {
                   cell.contentView.backgroundColor = [UIColor colorWithRed:255/255.0f
                                                                      green:255/255.0f
                                                                       blue:255/255.0f
                                                                      alpha:1.0] ;
               }
           } else {
               if (indexPath.row % 2) {
                   cell.contentView.backgroundColor = [[UIColor alloc]initWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1] ;
               } else {
                   cell.contentView.backgroundColor = [UIColor colorWithRed:255/255.0f
                                                                      green:255/255.0f
                                                                       blue:255/255.0f
                                                                      alpha:1.0] ;
               }
           }
           
       }
   }
   
   cell.diary = self;
   [cell setEntry: entry];    
   return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isLoading) return NO;
    if (self.diary.completed) return NO;
   return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.diary.completed) return NO;
   return YES;
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
   return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      DiaryEntry *entry = [self entryForIndexPath: indexPath]; 
      if (entry != nil) {
          
          [self deleteEntry: entry];
      }
   } else {
       [diaryTable reloadData];
   }
}
-(BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
   DiaryEntry *srcEntry = [self entryForIndexPath: sourceIndexPath];
   if (srcEntry) {
      if (groups != nil) {
         DiaryGroup *srcGroup = [groups objectAtIndex:[sourceIndexPath section]];
         DiaryGroup *destGroup = [groups objectAtIndex:[destinationIndexPath section]];
         [srcEntry setGroup: destGroup.group];
         srcGroup.count--;
         destGroup.count++;
         long destIndex = [self diaryIndexForIndexPath:destinationIndexPath];
         [diaryEntries removeObject: srcEntry];
         [diaryEntries insertObject: srcEntry atIndex: destIndex];
      } else {
         [diaryEntries removeObjectAtIndex: sourceIndexPath.row];
         [diaryEntries insertObject: srcEntry atIndex: destinationIndexPath.row];
      }

      // fix orders
      long group = 0;
      long seq = 0;
      for (DiaryEntry *entry in [self curDiaryEntries]) {
         seq++;      
         if (groups == nil) {
            [entry setGroup: 0];
         } else if ([entry getGroup] != group) {
            // reset for new group
            seq = 1;
            group = [entry getGroup];
         }
         if (entry == srcEntry || seq != [entry getSeq]  || group != [entry getGroup]) {
            NSLog(@" Updating %@ from %ld-%ld to %ld-%ld", entry, [entry getGroup], [entry getSeq], group, seq);
            [entry setSeq: seq];
            [[WebQuery singleton] editEntry:entry];
         }
      }
       [diaryTable reloadData];
      
//      NSLog(@" DIARY:");
//      for (DiaryEntry *entry in [self curDiary]) {
//         NSLog(@"  %@:  %d-%d", entry, [entry getGroup], [entry getSeq]);
//      }
   }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   NSLog(@"RowSelected = %ld", (long)[indexPath row]);
    if (self.diary.completed == YES) return;
   DiaryEntry *entry = [self entryForIndexPath: indexPath];
   if (entry != nil) {
      [self viewEntry: entry];
      [self.diaryTable deselectRowAtIndexPath: [diaryTable indexPathForSelectedRow] animated:NO];
   }
}

- (void) deleteEntry: (DiaryEntry *) entry {
   if (entry) {
       [self showProgressView];
       
       //    if (self.navigationItem.rightBarButtonItem != nil) {
       //        [self.navigationItem.rightBarButtonItem setEnabled:NO];
       //    }
       [self.navigationItem.leftBarButtonItem setEnabled:NO];
//       [self.addButton setEnabled:NO];
       
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          
         CLS_LOG(@"DELETE %@ #%ld", entry, entry.entryId );
         if ([entry isKindOfClass: [Serving class]]) { 
            [[WebQuery singleton] deleteServing: (Serving *)entry];
         } else if ([entry isKindOfClass: [Note class]]) {  
            [[WebQuery singleton] deleteNote: (Note *)entry];         
         } else if ([entry isKindOfClass: [Biometric class]]) { 
            [[WebQuery singleton] deleteBiometric: (Biometric *)entry];         
         } else if ([entry isKindOfClass: [Exercise class]]) {  
            [[WebQuery singleton] deleteExercise: (Exercise *)entry]; 
         }
         if ([self.diaryEntries indexOfObject:entry] != NSNotFound) {
            [self.diaryEntries removeObject:entry];
         }
          BOOL diaryGroupsOn = [self diaryGroupsOn];
          
         dispatch_async(dispatch_get_main_queue(), ^{
             [self hideProgressView];
             
             //    if (self.navigationItem.rightBarButtonItem != nil) {
             //        [self.navigationItem.rightBarButtonItem setEnabled:NO];
             //    }
             [self.navigationItem.leftBarButtonItem setEnabled:YES];
//             [self.addButton setEnabled:YES];
             
            [self loadGroups];
            [self.diaryTable reloadData];
            [self updateNutritionSummary];
             if ((diaryGroupsOn == NO) &&
                 (self.diaryEntries == nil || [self.diaryEntries count] <= 0)) {
                 self.diaryTable.hidden = YES;
                 self.addEntriesMenuView.hidden = NO;
                 [self.todayGoalCaloryLabel setText: [NSString stringWithFormat: @"%d kcal", (int)round(self.diary.summary.weight_goal) ] ];
                 self.navigationItem.rightBarButtonItem = nil;//self.addButton;
                 [self.addButton setEnabled: NO];
             } else {
                 self.diaryTable.hidden = NO;
                 self.addEntriesMenuView.hidden = YES;
//                 if (self.navigationItem.rightBarButtonItem == nil) {
//                     self.navigationItem.rightBarButtonItem = self.addButton;
                     [self.addButton setEnabled: YES];
//                 }
                 [self.diaryTable reloadData];
             }
         });
      });
   }
}


- (void) viewEntry: (DiaryEntry *) entry {
   if (entry) {
      if ([entry isKindOfClass: [Serving class]]) {
          
          AddServingViewController* addServingVC = (AddServingViewController*) [Utils newViewControllerWithId:@"addServingVC" In: @"Main1"];
          addServingVC.diaryVC = self;
          addServingVC.foodSearchVC = nil;
          addServingVC.serving = [Serving fromServing: (Serving *)entry];
          [self.navigationController pushViewController: addServingVC animated:YES];
          
      } else if ([entry isKindOfClass: [Note class]]) {       
          
          AddNoteViewController* addNoteVC = (AddNoteViewController*) [Utils newViewControllerWithId:@"addNoteVC" In: @"Main1"];
          addNoteVC.note = [Note fromNote: (Note *)entry];
          addNoteVC.diaryVC = self;
          [self.navigationController pushViewController:addNoteVC animated:YES];
          
      } else if ([entry isKindOfClass: [Biometric class]]) {
          
          AddBiometricViewController* addBiometricVC = (AddBiometricViewController*) [Utils newViewControllerWithId:@"addBiometricVC" In: @"Main1"];
          [addBiometricVC initBiometric];
          addBiometricVC.diaryVC = self;
          addBiometricVC.biometric = [Biometric fromBiometric: (Biometric *)entry];
          [self.navigationController pushViewController:addBiometricVC animated:YES];
      
      } else if ([entry isKindOfClass: [Exercise class]]) {
                   
          AddExerciseViewController* addExerciseVC = (AddExerciseViewController*) [Utils newViewControllerWithId:@"addExerciseVC" In: @"Main1"];
          addExerciseVC.diaryVC = self;
          [addExerciseVC initExercise];
          addExerciseVC.exercise = [Exercise fromExercise:(Exercise*)entry];
          [self.navigationController pushViewController:addExerciseVC animated:YES];
          
      }
   }
}


@end
