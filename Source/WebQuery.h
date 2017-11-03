//
//  WebQuery.h
//  Cronometer
//
//  Created by Boris Esanu on 12/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Day.h"
#import "Food.h"
#import "Metric.h"
#import "Serving.h"
#import "Activity.h"
#import "SearchHit.h" 
#import "Exercise.h"
#import "Note.h"
#import "Biometric.h"
#import "Target.h"
#import "NutrientInfo.h"
#import "Summary.h"
#import "Diary.h"

@interface WebQuery : NSObject 

#define VERSION "iT"

#define PRODUCTION    "https://cronometer.com/fws"
#define DEVELOPMENT   "https://dev00.cronometer.com/fws"
#define LOCALHOST     "http://127.0.0.1:8888/fws"

#define BASE_URL      PRODUCTION

#define SHOW_CALORIES_PREF             "cb.visible"
#define MACROS_VISIBLE_PREF            "targets.macros"
#define CIRCLES_VISIBLE_PREF           "targets.circles"
#define USER_PREF_SHOW_GOAL            "calories.goal"
#define USER_PREF_WEIGHTGOAL_KEY       "weightGoal"

#define PREF_PREFIX                    "CT."

#define USER_PREF_MACRO_INDEX_KEY      "macroIndex"

#define USER_PREF_MACRO_PROTEIN_KEY    "macroProtein"
#define USER_PREF_MACRO_CARBS_KEY      "macroCarbs"
#define USER_PREF_MACRO_LIPIDS_KEY     "macroLipids"

#define USER_PREF_ACTIVITY             "calories.activity"
#define USER_PREF_CUSTOM_ACTIVITY      "calories.activity.custom"

@property (readwrite) long userId;
@property (readwrite) long long sessionKey;
@property (readwrite) double weightInKg;
@property (readwrite) double heightInCM;
@property (readwrite) NSInteger age;
@property (nonatomic, strong) NSString* gender;
@property (readwrite) bool gold; 
@property (nonatomic, strong) NSString* lastError;
@property (nonatomic, strong) NSDate *lastSync;

@property (nonatomic, strong) NSMutableDictionary *foodCache;
@property (nonatomic, strong) NSMutableDictionary *activityCache;
@property (nonatomic, strong) NSMutableDictionary *metricsCache;
@property (nonatomic, strong) NSMutableDictionary *targetsCache;
@property (nonatomic, strong) NSMutableDictionary *nutrientsCache;
@property (nonatomic, strong) NSMutableDictionary *prefsCache;

+ (WebQuery *) singleton;
//- (double) weightInKg;
//- (double) heightInCM;
- (void) facebookLogin: (NSString *)access_token;
- (void) login:(NSString *)email password:(NSString *)password;
- (void) createAccount:(NSString *)email password:(NSString *)password;
- (void) relogin;
- (void) relogin:(long long)sKey user:(long)uid;
- (NSDictionary*) resetPassword:(NSString *)email;
- (bool) isLoggedIn;
- (void) logout;
- (bool) needsAccountSetup;

- (double) weightInPounds;
- (double) weightInPreferredUnit;
- (double) heightInPreferredUnit;
- (long) getPreferredWeightUnit;
- (long) getPreferredHeightUnit; 

- (BOOL) setPref:(NSString *)key withValue:(NSString *)val;
- (NSString*) getPref: (NSString*) key defaultTo: (NSString*) def;
- (NSInteger) getIntPref: (NSString*) key defaultTo: (NSInteger) def;
- (bool) getBoolPref: (NSString*) key defaultTo: (bool) def;
- (double) getDoublePref: (NSString*) key defaultTo: (double) def;

- (NSArray *)getDiaryEntries:(Day *)day;
- (Diary*) getDiary: (Day*)day;
- (Summary*) getSummary: (Day*)day;
- (Food *)getFood:(long)foodId;
- (Activity *)getActivity:(long)aId;
- (NSArray *) topFoods;
- (NSArray *) topActivities;
- (NSArray *) findFoods: (NSString *)str;
- (NSArray *) findActivities: (NSString *)str;
- (long) searchFoodByBarcode: (NSString*) barcode;
- (Metric *) metric: (long)mId;
- (Target *) target: (long)nutrientId;
- (NutrientInfo *) nutrient: (long)nutrientId;
- (BOOL) delFood: (Food*) food;
- (NSDictionary*) foodStats: (long)foodid;

- (void) loadMetrics;
- (void) suggestTargets;
- (Target *) suggestTarget:(long)nutrientId;
- (BOOL) editTarget:(Target*)target;

- (void) loadTargets;
- (void) loadNutrients;

- (NSArray *) getTargets;
- (NSArray *) getMetrics;
- (NSArray *) getNutrients;

- (long)addServing:(Serving *)serving;
- (long)addExercise:(Exercise *)exercise;
- (long)addBiometric:(Biometric *)biometric;
- (long)addNote:(Note *)note;
- (long)addFood:(Food *)food;

- (BOOL)editServing:(Serving *)serving;
- (BOOL)editExercise:(Exercise *)exercise;
- (BOOL)editNote:(Note *)note;
- (BOOL)editBiometric:(Biometric *)biometric;

- (BOOL)editEntry:(DiaryEntry *)entry;

- (BOOL)deleteServing:(Serving *)serving;
- (BOOL)deleteExercise:(Exercise *)exercise;
- (BOOL)deleteNote:(Note *)note;
- (BOOL)deleteBiometric:(Biometric *)biometric;

- (BOOL)copyFrom:(Day*)fromDay to:(Day*)toDay;

- (void) warmCaches;

- (void) markDayCompleted: (Day*) day completed: (BOOL) completed;

- (double) getBMR;

@end
