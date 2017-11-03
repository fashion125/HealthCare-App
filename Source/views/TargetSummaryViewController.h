//
//  TargetSummaryViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 06/11/2011.
//  Copyright (c) 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditTargetViewController.h"
#import "Serving.h"

@interface TargetSummaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EditTargetViewControllerDelegate>
{
    double protein;
    double carbs;
    double lipids;
    double alcohol;
    double proteinG;
    double carbsG;
    double lipidsG;
    double alcoholG;
    BOOL   isFromDiary;
}
@property (strong, nonatomic) IBOutlet UITableView *nutrientTable;
 
@property (nonatomic, strong) NSMutableDictionary *categories;
@property(readwrite) id foodSearchVC;
@property(readwrite) id diaryVC;
@property (strong) NSMutableArray *diaryEntries;
@property (strong) Summary* summary;
@property (strong) Serving* serving;

@property (nonatomic, strong) NSMutableDictionary *amounts;
@property (strong, readwrite) Day* day;

- (IBAction)onDone:(id)sender;

//- (void) setAmountsFromDiaryEntries:(NSArray *)diaryEntries;
- (void) setAmountsFromDiary:(Diary *)diary;
- (void) setAmountsFromServing:(Serving *)serving;
- (void) setSummaryWith:(Summary *)summary;
- (void) setDiary:(Diary *)diary;
- (void) setIsFromDiary: (BOOL) val;

- (void) loadData;



@end
