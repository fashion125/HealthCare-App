//
//  DiaryViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 13/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Diary.h"
#import "Day.h"
#import "DiaryEntry.h"
#import "TargetBar.h"
#import "PieChart.h"
#import "KAProgressLabel.h"

@interface DiaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> { 
   Day *currentDay; 
 
   NSMutableArray *diaryEntries;
   NSMutableArray *groups;
 
   UIActivityIndicatorView *spinner;
} 
@property (nonatomic, weak) IBOutlet UITableView *diaryTable;
@property (strong) NSMutableArray *diaryEntries;
@property (readwrite, strong) Diary* diary;
@property (strong) NSMutableArray *groups;
@property (strong) Day *currentDay;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet TargetBar *caloriesTargetBar;
@property (nonatomic, weak) IBOutlet TargetBar *nutrientsBar;
@property (nonatomic, weak) IBOutlet UILabel *nutrientsTargetPercentageLabel;
@property (nonatomic, weak) IBOutlet UILabel *nutrientsNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel *caloriesTargetNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel *nonMacroLabel;
@property (nonatomic, weak) IBOutlet KAProgressLabel *targetProgressLabel;
@property (nonatomic, weak) IBOutlet PieChart *pieChart;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
//@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (readwrite, strong) NSString *pieLabel;
@property (readwrite, strong) NSDate *lastUpdate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *entryBar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) id sheetSender;

@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@property (nonatomic, strong)	id				currentPopTipViewTarget;

@property (readwrite) long activeGroup;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateButtonOffset;
@property (strong, nonatomic) IBOutlet UIImageView *completedMarkImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addButtonImage;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

+ (DiaryViewController *) singleton;

- (IBAction)onClickAdd:(id)sender;

- (IBAction)addEntry:(id)sender; 

- (IBAction)addServing:(id)sender;
- (IBAction)addExercise:(id)sender;
- (IBAction)addBiometric:(id)sender;
- (IBAction)addNote:(id)sender;
- (void) rearrangeEntries;

- (void) viewEntry: (DiaryEntry *) entry;
- (void) deleteEntry: (DiaryEntry *) entry;

- (IBAction)goNextDay:(id)sender;
- (IBAction)goPrevDay:(id)sender;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)showMenu:(id)sender; 
- (IBAction)showMacroBreakdown:(id)sender;

- (void) updateNutritionSummary;

- (void) loadDay: (Day *)day;

- (void) entryAdded: (DiaryEntry *) entry;
- (void) entryChanged: (DiaryEntry *) entry;

- (void) logout;

- (void) refreshData;
- (void) loadGroups;



- (double) getCaloriesBurned:(NSArray *) entries;
- (double) getCaloriesConsumed:(NSArray *) entries;
- (double) getNutrientAmount:(NSArray *) entries forType:(long) nutrientId;

- (IBAction)showNutrientTargets:(id)sender; 

- (void) setOrderForNewDiaryEntry: (DiaryEntry *) entry;

@end
 
