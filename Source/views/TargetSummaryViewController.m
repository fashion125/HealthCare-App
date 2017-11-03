//
//  TargetSummaryViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 06/11/2011.
//  Copyright (c) 2011 cronometer.com. All rights reserved.
//

#import "TargetSummaryViewController.h"

#import "TargetSummaryTableViewCell.h"
#import "CaloriesSummaryViewCell.h"
#import "WeightGoalViewCell.h"
#import "MacrosViewCell.h"
#import "NutrientTargetHeaderViewCell.h"
#import "NutrientTargetViewCell.h"
#import "SettingViewController.h"
#import "AddRecipeViewController.h"
#import "AddFoodViewController.h"
#import "NutrientBalanceViewCell.h"
#import "WebQuery.h"
#import "Utils.h"

@interface TargetSummaryViewController()
@property (readwrite) BOOL mShowCaloriesSummary;
@property (readwrite) BOOL mShowMacroNutrientBreakdown;
@property (readwrite) BOOL mShowHighlightedTargets;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelHeight;
@property (readwrite) BOOL mShowWeightGoal;
@end

@implementation TargetSummaryViewController
@synthesize nutrientTable, categories, amounts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.amounts = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.amounts = [[NSMutableDictionary alloc] init];
    
    self.navigationController.navigationBar.translucent = NO;
//    UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
//    
   
    // Do any additional setup after loading the view from its nib.
    
    if (isFromDiary == YES) {
        self.title = @"Nutrition Summary";
        UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithTitle: @"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
        [self.navigationItem setRightBarButtonItem:menuBtn];
        self.nameLabelHeight.constant = 0;
        // make sure nutrients are loaded, then refresh table view
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [[WebQuery singleton] loadNutrients];
//            
//            Diary *diary = [[WebQuery singleton] getDiary:self.day];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self loadData];
//                [self setAmountsFromDiary:diary];
//            });
//        });
    } else {
        self.title = @"Calorie Breakdown";
        if (self.serving != nil) {
            Food* food = [self.serving food];
            self.foodNameLabel.text = food.name;
            if (food != nil && [food.source isEqualToString:@"Custom"]) {
            
                UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithTitle: @"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(showEditPage:)];
                [self.navigationItem setRightBarButtonItem:menuBtn];
            } else {
                [self.navigationItem setRightBarButtonItem: nil];
            }
            
        }
        // make sure nutrients are loaded, then refresh table view
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [[WebQuery singleton] loadNutrients];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self loadData];
//                [self setAmountsFromServing:self.serving];
//            });
//        });
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.mShowCaloriesSummary = [[WebQuery singleton] getBoolPref: @SHOW_CALORIES_PREF defaultTo:true] == true ? YES : NO;
        self.mShowMacroNutrientBreakdown = [[WebQuery singleton] getBoolPref: @MACROS_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
        self.mShowHighlightedTargets = [[WebQuery singleton] getBoolPref: @CIRCLES_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
        self.mShowWeightGoal = [[WebQuery singleton] getBoolPref: @USER_PREF_SHOW_GOAL defaultTo: true] == true ? YES : NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.nutrientTable reloadData];
        });
        
    });
    
}
- (IBAction)showEditPage:(id)sender {
    Food* food = [self.serving food];
    if (food == nil) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([food isRecipe]) {
            AddRecipeViewController* addRecipeVC = (AddRecipeViewController*) [Utils newViewControllerWithId:@"addRecipeVC" In: @"Main1"];
            addRecipeVC.foodSearchVC = self.foodSearchVC;
            addRecipeVC.diaryVC = self.diaryVC;
            addRecipeVC.isEditing = YES;
            addRecipeVC.food = food;

            //addRecipeVC.title = @"Add Recipe";
            [self.navigationController pushViewController:addRecipeVC animated:YES];

        } else {
            AddFoodViewController* addFoodVC = (AddFoodViewController*) [Utils newViewControllerWithId:@"addFoodVC" In: @"Main1"];
            addFoodVC.foodSearchVC = self.foodSearchVC;
            addFoodVC.diaryVC = self.diaryVC;
            addFoodVC.isEditing = YES;
            addFoodVC.food = food;
            [self.navigationController pushViewController:addFoodVC animated:YES];
            
        }
    });
//    SettingViewController* settingsVC = (SettingViewController*) [Utils newViewControllerWithId:@"SettingViewController" In: @"Main1"];
//    settingsVC.targetSummaryViewController = self;
//    [self.navigationController pushViewController: settingsVC animated:YES];
}
- (IBAction)showSettings:(id)sender {
    SettingViewController* settingsVC = (SettingViewController*) [Utils newViewControllerWithId:@"SettingViewController" In: @"Main1"];
    settingsVC.targetSummaryViewController = self;
    [self.navigationController pushViewController: settingsVC animated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) addNutrient:(NutrientInfo*) ni toList:(NSMutableArray*)list withNutrients:(NSMutableArray*)nutrients {
   [list addObject:ni];
   for (NutrientInfo *ni2 in nutrients) {
      if (ni2.pId == ni.nId) {   
         [self addNutrient: ni2 toList: list withNutrients: nutrients];
      }
   }
}

- (void) loadData {
    self.mShowCaloriesSummary = [[WebQuery singleton] getBoolPref: @SHOW_CALORIES_PREF defaultTo:true] == true ? YES : NO;
    self.mShowMacroNutrientBreakdown = [[WebQuery singleton] getBoolPref: @MACROS_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
    self.mShowHighlightedTargets = [[WebQuery singleton] getBoolPref: @CIRCLES_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
    self.mShowWeightGoal = [[WebQuery singleton] getBoolPref: @USER_PREF_SHOW_GOAL defaultTo: true] == true ? YES : NO;
    
   NSMutableDictionary *tempCategories = [[NSMutableDictionary alloc] init];
   NSMutableDictionary *added = [[NSMutableDictionary alloc] init];

   // add each nutrient into a category list
   for (NutrientInfo *ni in [[WebQuery singleton] getNutrients]) {
       if (ni == nil) {
           continue;
       }
      if (added[@(ni.nId)] == nil) {
         NSMutableArray *list = [tempCategories objectForKey: ni.category];
         if (list == nil) {
            list = [[NSMutableArray alloc] init];
            [tempCategories setObject:list forKey:ni.category];
         }
            
         Target *t = [[WebQuery singleton] target: ni.nId];
         if (t != nil && t.visible) {
            if (ni.pId != 0) {
               if (added[@(ni.pId)] == nil) {
                  NutrientInfo *parent = [[WebQuery singleton] nutrient:ni.pId];
                  added[@(parent.nId)] = parent;
                  [list addObject:parent];
               }
            }
            added[@(ni.nId)] = ni;
            [list addObject:ni];
         }
      }
   }   
   
   self.categories = [[NSMutableDictionary alloc] init];
      
   // sort each category list according to name, and parent/child
   for (NSString* cat in [tempCategories keyEnumerator]) {      
      NSMutableArray *list = [tempCategories objectForKey: cat];
      if (list != nil) {         
         // sort list alphabetically first         
         [list sortUsingSelector:@selector(compare:)];  
         
         NSMutableArray *slist = [[NSMutableArray alloc] init];
         for (NutrientInfo *ni in list) {
            if (ni.pId == 0) {   
               [self addNutrient: ni toList: slist withNutrients: list];
            }
         }
         [categories setObject:slist forKey:cat];         
      }      
   }
    
   [self.nutrientTable reloadData];
} 

//- (void) setAmountsFromDiaryEntries:(NSArray *)diaryEntries {
//   for (NutrientInfo *ni in [[WebQuery singleton] getNutrients]) {
//      double total = 0;
//      for (DiaryEntry *entry in diaryEntries) {
//         if (entry && [entry isKindOfClass: [Serving class]]) {
//            Serving *serving = (Serving *)entry;
//            total += [serving nutrientAmount: ni.nId];
//         }
//      }
//      [self setAmount:total forNutrient:ni.nId];
//   }
//   
//   [self.nutrientTable reloadData];
//}

- (void) setAmountsFromDiary:(Diary *)diary {
    self.mShowCaloriesSummary = [[WebQuery singleton] getBoolPref: @SHOW_CALORIES_PREF defaultTo:true] == true ? YES : NO;
    self.mShowMacroNutrientBreakdown = [[WebQuery singleton] getBoolPref: @MACROS_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
    self.mShowHighlightedTargets = [[WebQuery singleton] getBoolPref: @CIRCLES_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
    self.mShowWeightGoal = [[WebQuery singleton] getBoolPref: @USER_PREF_SHOW_GOAL defaultTo: true] == true ? YES : NO;
    for (NutrientInfo *ni in [[WebQuery singleton] getNutrients]) {
        double total = 0;
        for (DiaryEntry *entry in diary.diaryEntries) {
            if (entry && [entry isKindOfClass: [Serving class]]) {
                Serving *serving = (Serving *)entry;
                total += [serving nutrientAmount: ni.nId];
            }
        }
        [self setAmount:total forNutrient:ni.nId];
    }
    self.summary = diary.summary;
    self.diaryEntries = (NSMutableArray*)diary.diaryEntries;
    
    NSArray *curDiaryEntries = diary.diaryEntries;
    if ([curDiaryEntries count] > 0) {
        double p = 0, c = 0, f = 0, a = 0;
        double pg = 0, cg = 0, fg = 0, ag = 0;
        
        for (DiaryEntry *entry in curDiaryEntries) {
            if (entry) {
                if ([entry isKindOfClass: [Serving class]]) {
                    Serving *serving = (Serving *)entry;
                    
                    pg += [serving nutrientAmount: PROTEIN];
                    cg += [serving nutrientAmount: NET_CARBS];
                    fg += [serving nutrientAmount: LIPIDS];
                    ag += [serving nutrientAmount: ALCOHOL];
                    
                    p += [serving nutrientAmount: CALORIES_FROM_PROTEIN];
                    c += [serving nutrientAmount: CALORIES_FROM_CARBOHYDRATES];
                    f += [serving nutrientAmount: CALORIES_FROM_LIPIDS];
                    a += [serving nutrientAmount: CALORIES_FROM_ALCOHOL];
                }
            }
        }
        //0xAA, 0xFF, 0xAA
        protein = p;
        carbs = c;
        lipids = f;
        alcohol = a;
        proteinG = pg;
        carbsG = cg;
        lipidsG = fg;
        alcoholG = ag;
        
        
    } else {
        protein = 0;
        carbs = 0;
        lipids = 0;
        alcohol = 0;
        proteinG = 0;
        carbsG = 0;
        lipidsG = 0;
        alcoholG = 0;
    }
    
    
    [self.nutrientTable reloadData];
}
- (void) setIsFromDiary: (BOOL) val {
    isFromDiary = val;
}

- (void) setSummaryWith:(Summary *)summary {
    
    _summary = summary;
    [self.nutrientTable reloadData];
}

- (void) setDiary:(Diary *)diary {
    _summary = diary.summary;
    self.diaryEntries = (NSMutableArray*)diary.diaryEntries;
    [self.nutrientTable reloadData];
}

- (void) setAmountsFromServing:(Serving *)serving {
    self.mShowCaloriesSummary = [[WebQuery singleton] getBoolPref: @SHOW_CALORIES_PREF defaultTo:true] == true ? YES : NO;
    self.mShowMacroNutrientBreakdown = [[WebQuery singleton] getBoolPref: @MACROS_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
    self.mShowHighlightedTargets = [[WebQuery singleton] getBoolPref: @CIRCLES_VISIBLE_PREF defaultTo: true] == true ? YES : NO;
    self.mShowWeightGoal = [[WebQuery singleton] getBoolPref: @USER_PREF_SHOW_GOAL defaultTo: true] == true ? YES : NO;
   for (NutrientInfo *ni in [[WebQuery singleton] getNutrients]) {
      [self setAmount:[serving nutrientAmount: ni.nId] forNutrient:ni.nId];
   }
    self.diaryEntries = [NSMutableArray array];
    [self.diaryEntries addObject: serving];
    for (NutrientInfo *ni in [[WebQuery singleton] getNutrients]) {
        double total = 0;
        for (DiaryEntry *entry in self.diaryEntries) {
            if (entry && [entry isKindOfClass: [Serving class]]) {
                Serving *serving = (Serving *)entry;
                total += [serving nutrientAmount: ni.nId];
            }
        }
        [self setAmount:total forNutrient:ni.nId];
    }
    
    NSArray *curDiaryEntries = self.diaryEntries;
    if ([curDiaryEntries count] > 0) {
        double p = 0, c = 0, f = 0, a = 0;
        double pg = 0, cg = 0, fg = 0, ag = 0;
        
        for (DiaryEntry *entry in curDiaryEntries) {
            if (entry) {
                if ([entry isKindOfClass: [Serving class]]) {
                    Serving *serving = (Serving *)entry;
                    
                    pg += [serving nutrientAmount: PROTEIN];
                    cg += [serving nutrientAmount: NET_CARBS];
                    fg += [serving nutrientAmount: LIPIDS];
                    ag += [serving nutrientAmount: ALCOHOL];
                    
                    p += [serving nutrientAmount: CALORIES_FROM_PROTEIN];
                    c += [serving nutrientAmount: CALORIES_FROM_CARBOHYDRATES];
                    f += [serving nutrientAmount: CALORIES_FROM_LIPIDS];
                    a += [serving nutrientAmount: CALORIES_FROM_ALCOHOL];
                }
            }
        }
        //0xAA, 0xFF, 0xAA
        protein = p;
        carbs = c;
        lipids = f;
        alcohol = a;
        proteinG = pg;
        carbsG = cg;
        lipidsG = fg;
        alcoholG = ag;
        
        
    } else {
        protein = 0;
        carbs = 0;
        lipids = 0;
        alcohol = 0;
        proteinG = 0;
        carbsG = 0;
        lipidsG = 0;
        alcoholG = 0;
    }
   [self.nutrientTable reloadData];
}

- (void) setAmount:(double)amount forNutrient:(long)nId {
   [amounts setObject:[NSNumber numberWithDouble:amount] forKey:[NSNumber numberWithLong:nId]];
}

- (double) amount: (long)nId {
   return [((NSNumber *)[amounts objectForKey:[NSNumber numberWithLong:nId]]) doubleValue];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([WebQuery singleton].gold) {
        return 8;
    }
    return 7;
}

- (NSString *) categoryName: (NSInteger) section {
   switch (section) {
      case 1: return @"General";
      case 2: return @"Vitamins";
      case 3: return @"Minerals";
      case 4: return @"Carbohydrates";
      case 5: return @"Lipids";
      case 6: return @"Protein";
   }
   return @"";
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 50;
}
- (int) cellHeight:(int)row {
    return 0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFromDiary) {
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                if (self.mShowCaloriesSummary) return 236;
                if (self.mShowWeightGoal) return 44;
                if (self.mShowMacroNutrientBreakdown) return 170;
                return 45;
//                if (self.mShowHighlightedTargets) return 165;
            } else if (indexPath.row == 1) {
                if (self.mShowCaloriesSummary && self.mShowWeightGoal) return 44;
                else {
                    if (self.mShowMacroNutrientBreakdown) {
                        if (!self.mShowCaloriesSummary && !self.mShowWeightGoal) return 45;
                        return 170;
                    } else {
                        if (!self.mShowCaloriesSummary && !self.mShowWeightGoal && self.mShowHighlightedTargets) {
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                                return 165;
                            } else {
                                return 240;
                            }
                        }
                        return 45;
                    }
                }
            } else if (indexPath.row == 2) {
                if (self.mShowCaloriesSummary && self.mShowWeightGoal && self.mShowMacroNutrientBreakdown) {return 170;
                } else {
                    if ((self.mShowMacroNutrientBreakdown && self.mShowWeightGoal) ||
                        (self.mShowMacroNutrientBreakdown && self.mShowCaloriesSummary) ||
                        (self.mShowWeightGoal && self.mShowCaloriesSummary)) {
                        return 45;
                    } else {
                        if (self.mShowHighlightedTargets) {
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                                return 165;
                            } else {
                                return 240;
                            }
                        }
                    }
                }
                return 45;
            } else if (indexPath.row == 3) {
                if (self.mShowCaloriesSummary && self.mShowWeightGoal && self.mShowMacroNutrientBreakdown) return 45;
                if (self.mShowHighlightedTargets) {
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        return 165;
                    } else {
                        return 240;
                    }
                }
            } else if (indexPath.row == 4) {
                if (self.mShowCaloriesSummary && self.mShowWeightGoal && self.mShowMacroNutrientBreakdown && self.mShowHighlightedTargets) {
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        return 165;
                    } else {
                        return 240;
                    }
                }
            }
        }
    } else {
        if (indexPath.section == 0) {
        
            if (indexPath.row == 0) {
                if (self.mShowMacroNutrientBreakdown) return 170;
                return 45;
//                if (self.mShowHighlightedTargets) return 165;
            } else if (indexPath.row == 1) {
                if (self.mShowMacroNutrientBreakdown) return 45;
                if (self.mShowHighlightedTargets) {
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        return 165;
                    } else {
                        return 240;
                    }
                }
            } else if (indexPath.row == 2) {
                if (self.mShowMacroNutrientBreakdown && self.mShowHighlightedTargets) {
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        return 165;
                    } else {
                        return 240;
                    }
                }
            }
        }//
    }
    if (indexPath.section == 7) {
        if (indexPath.row == 0) {
            return 50;
        } else  {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                return 200;
            } else {
                return 300;
            }
        }
    }
    return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
   return [self categoryName:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (isFromDiary) {
            return 1 + (self.mShowCaloriesSummary?1:0) + (self.mShowWeightGoal?1:0) + (self.mShowMacroNutrientBreakdown?1:0) + (self.mShowHighlightedTargets?1:0);
            
        } else {
            return 1 + (self.mShowMacroNutrientBreakdown?1:0) + (self.mShowHighlightedTargets?1:0);
        }
        
    } else if (section == 7) {
        return 2;
    }
   if (categories != nil) {
      NSMutableArray *list = [categories objectForKey: [self categoryName:section]];
      if (list != nil) {
         return [list count];
      } else {
          return 0;
      }
   }
   return 0;
}
- (CaloriesSummaryViewCell*) caloriesSummaryViewCell : (UITableView*)tableView{
    NSString* CellIdentifier = @"CaloriesSummaryViewCell";
    CaloriesSummaryViewCell *cellCalories = (CaloriesSummaryViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cellCalories == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[CaloriesSummaryViewCell class]]) {
                cellCalories = (CaloriesSummaryViewCell *)currentObject;
                break;
            }
        }
        cellCalories.accessoryType = UITableViewCellAccessoryNone;
    }
    [cellCalories setSummary: self.summary again: YES];
    return cellCalories;
}
- (WeightGoalViewCell*) weightGoalViewCell : (UITableView*)tableView{
    NSString* CellIdentifier = @"WeightGoalViewCell";
    WeightGoalViewCell *cellWeightGoal = (WeightGoalViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cellWeightGoal == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[WeightGoalViewCell class]]) {
                cellWeightGoal = (WeightGoalViewCell *)currentObject;
                break;
            }
        }
        cellWeightGoal.accessoryType = UITableViewCellAccessoryNone;
    }
    [cellWeightGoal setSummaryWith: self.summary];
    return cellWeightGoal;
}
- (MacrosViewCell*) macrosViewCell : (UITableView*)tableView{
    NSString* CellIdentifier = @"MacrosViewCell";
    MacrosViewCell *cellMacros = (MacrosViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cellMacros == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[MacrosViewCell class]]) {
                cellMacros = (MacrosViewCell *)currentObject;
                break;
            }
        }
        cellMacros.accessoryType = UITableViewCellAccessoryNone;
    }
    [cellMacros setMacrosWithProtein: protein pg: proteinG Carbs: carbs cg: carbsG Lipids:lipids fg: lipidsG Alcohol:alcohol ag: alcoholG];
    return cellMacros;
}
- (NutrientTargetViewCell*) nutrientTargetViewCell : (UITableView*)tableView{
    NSString* CellIdentifier = @"NutrientTargetViewCell";
    NutrientTargetViewCell *cellNutrientTarget = (NutrientTargetViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cellNutrientTarget == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[NutrientTargetViewCell class]]) {
                cellNutrientTarget = (NutrientTargetViewCell *)currentObject;
                break;
            }
        }
        cellNutrientTarget.accessoryType = UITableViewCellAccessoryNone;
    }
    [cellNutrientTarget setTargets: self.diaryEntries];
    return cellNutrientTarget;
}
- (NutrientTargetHeaderViewCell*) nutrientTargetHeaderViewCell : (UITableView*)tableView{
    NSString* CellIdentifier = @"NutrientTargetHeaderViewCell";
    NutrientTargetHeaderViewCell *cell = (NutrientTargetHeaderViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[NutrientTargetHeaderViewCell class]]) {
                cell = (NutrientTargetHeaderViewCell *)currentObject;
                break;
            }
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (NutrientTargetHeaderViewCell*) nutrientBalanceHeaderViewCell : (UITableView*)tableView{
    NSString* CellIdentifier = @"NutrientTargetHeaderViewCell";
    NutrientTargetHeaderViewCell *cell = (NutrientTargetHeaderViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[NutrientTargetHeaderViewCell class]]) {
                cell = (NutrientTargetHeaderViewCell *)currentObject;
                break;
            }
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.textLabel setText:@"NUTRIENT BALANCE"];
    return cell;
}
- (NutrientBalanceViewCell*) nutrientBalanceViewCell : (UITableView*)tableView{
    NSString* CellIdentifier = @"NutrientBalanceViewCell";
    NutrientBalanceViewCell *cellNutrientBalance = (NutrientBalanceViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cellNutrientBalance == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[NutrientBalanceViewCell class]]) {
                cellNutrientBalance = (NutrientBalanceViewCell *)currentObject;
                break;
            }
        }
        cellNutrientBalance.accessoryType = UITableViewCellAccessoryNone;
    }
    [cellNutrientBalance setValuesWithAmount:self.amounts];
    return cellNutrientBalance;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = nil;
    UITableViewCell* cell = nil;
//    if (indexPath.section == 0 && indexPath.row == 0 && isFromDiary && self.mShowCaloriesSummary) {
//        
//        cell = [self caloriesSummaryViewCell:tableView];
//        
//    } else if ( (indexPath.section == 0 && indexPath.row == 0 && isFromDiary && self.mShowWeightGoal) ||
//               (indexPath.section == 0 && indexPath.row == 1 && isFromDiary && self.mShowWeightGoal && self.mShowCaloriesSummary)  ) {
//        
//        cell = [self weightGoalViewCell:tableView];
//    } else if ((indexPath.section == 0 && indexPath.row == 2 && isFromDiary) || (indexPath.section == 0 && indexPath.row == 0 && !isFromDiary)) {
//        
//        cell = [self macrosViewCell:tableView];
//    } else if ((indexPath.section == 0 && indexPath.row == 3 && isFromDiary) || (indexPath.section == 0 && indexPath.row == 1 && !isFromDiary)) {
//        
//        cell = [self nutrientTargetViewCell:tableView];
//    }
    if (isFromDiary && indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            if (self.mShowCaloriesSummary) {
                return [self caloriesSummaryViewCell:tableView];
            }
            if (self.mShowWeightGoal) {
                return [self weightGoalViewCell:tableView];
            }
            if (self.mShowMacroNutrientBreakdown) {
                return [self macrosViewCell:tableView];
            }
            return [self nutrientTargetHeaderViewCell:tableView];
//            if (self.mShowHighlightedTargets) return [self nutrientTargetViewCell:tableView];
        } else if (indexPath.row == 1) {           
            
            if (self.mShowCaloriesSummary && self.mShowWeightGoal) {
                return [self weightGoalViewCell:tableView];
            } else {
                if (self.mShowMacroNutrientBreakdown) {
                    if (!self.mShowCaloriesSummary && !self.mShowWeightGoal) {
                        return [self nutrientTargetHeaderViewCell:tableView];
                    }
                    return [self macrosViewCell:tableView];
                } else {
                    if (!self.mShowCaloriesSummary && !self.mShowWeightGoal && self.mShowHighlightedTargets) {
                        return [self nutrientTargetViewCell:tableView];
                    }
                    return [self nutrientTargetHeaderViewCell:tableView];
                }
            }
        } else if (indexPath.row == 2) {
            if (self.mShowMacroNutrientBreakdown && self.mShowWeightGoal && self.mShowCaloriesSummary) {
                return [self macrosViewCell:tableView];
            } else {
                if ((self.mShowMacroNutrientBreakdown && self.mShowWeightGoal) ||
                    (self.mShowMacroNutrientBreakdown && self.mShowCaloriesSummary) ||
                    (self.mShowWeightGoal && self.mShowCaloriesSummary)) {
                    return [self nutrientTargetHeaderViewCell:tableView];
                } else {
                    if (self.mShowHighlightedTargets) {
                        return [self nutrientTargetViewCell:tableView];
                    }                    
                }
            }
            
            return [self nutrientTargetHeaderViewCell:tableView];
        } else if (indexPath.row == 3) {
            if (self.mShowMacroNutrientBreakdown && self.mShowWeightGoal && self.mShowCaloriesSummary) {
                return [self nutrientTargetHeaderViewCell:tableView];
            }
            if (self.mShowHighlightedTargets) {
                return [self nutrientTargetViewCell:tableView];
            }
            return [self nutrientTargetHeaderViewCell:tableView];
        } else if (indexPath.row == 4) {
            if (self.mShowHighlightedTargets && self.mShowMacroNutrientBreakdown && self.mShowWeightGoal && self.mShowCaloriesSummary) {
                return [self nutrientTargetViewCell:tableView];
            }
            return [self nutrientTargetViewCell:tableView];
        }
    } else if (!isFromDiary && indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (self.mShowMacroNutrientBreakdown) return [self macrosViewCell:tableView];
            return [self nutrientTargetHeaderViewCell:tableView];
//            if (self.mShowHighlightedTargets) return [self nutrientTargetViewCell:tableView];
        } else if (indexPath.row == 1) {
            if (self.mShowMacroNutrientBreakdown) {
                return [self nutrientTargetHeaderViewCell:tableView];
            }
            return [self nutrientTargetViewCell:tableView];
        } else if (indexPath.row == 2) {
            if (self.mShowHighlightedTargets && self.mShowMacroNutrientBreakdown) {
                return [self nutrientTargetViewCell:tableView];
            }
        }
    } else if (indexPath.section == 7) {
        if (indexPath.row == 0) {
            return [self nutrientBalanceHeaderViewCell:tableView];
        } else {
            return [self nutrientBalanceViewCell:tableView];
            
        }
    } else {
        CellIdentifier = @"TargetSummaryTableViewCell";
        TargetSummaryTableViewCell *cellTarget = (TargetSummaryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cellTarget == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if(currentObject && [currentObject isKindOfClass:[TargetSummaryTableViewCell class]]) {
                    cellTarget = (TargetSummaryTableViewCell *)currentObject;
                    break;
                }
            }
//            cellTarget = [[TargetSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            cellTarget.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSMutableArray *list = [categories objectForKey: [self categoryName:indexPath.section]];
        if (list != nil) {
            NutrientInfo *ni = [list objectAtIndex:indexPath.row];
            Target *t = [[WebQuery singleton] target: ni.nId];
            
            double amount = [self amount: ni.nId]; 
            [cellTarget setTarget: t forNutrient: ni amount: amount];
        }
//        [cellTarget setTarget: nil forNutrient: nil amount: indexPath.section*10000 + indexPath.row];
        [cellTarget setNeedsDisplay];
        [cellTarget setNeedsLayout];
        cell = cellTarget;
    }
   
   return cell;
}

# pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0 || indexPath.section == 7) return;
    
    NSMutableArray *list = [categories objectForKey: [self categoryName:indexPath.section]];
    if (list == nil) {
        
        return;
    }
    
    NutrientInfo *ni = [list objectAtIndex:indexPath.row];
    Target *t = [[WebQuery singleton] target: ni.nId];
    
    Target * targetToEdit = t;
    
//    EditTargetViewController * vc = [[EditTargetViewController alloc] initWithNibName:nil bundle:nil];
    EditTargetViewController* editTargetVC = (EditTargetViewController*)[Utils newViewControllerWithId:@"editTargetVC" In: @"Main1"];
    editTargetVC.targetToEdit = targetToEdit;
    editTargetVC.nutrientInfo = ni;
    editTargetVC.delegate = self;
    
    //UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:editTargetVC];
    [self.navigationController pushViewController: editTargetVC animated:YES];
    //[self presentViewController:nvc animated:YES completion:NULL];
}


# pragma mark - ()
- (IBAction)onDone:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - EditTargetViewControllerDelegate
- (void)onTargetEditSuccess
{
    [self loadData];
    
}


@end
