//
//  HeathKitServie.h
//  Cronometer
//
//  Created by Frank Mao on 2014-10-02.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;


#define kCMIsMetricSystem @"isMetricSystem"

@interface HealthKitService : NSObject
@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic) BOOL isServiceAccessible;
@property (nonatomic) HKQuantitySample * usersHeight;
@property (nonatomic) HKQuantitySample * usersWeight;
@property (nonatomic, strong) NSSet *writeDataTypes;
@property (nonatomic) BOOL userPermissionGranted;

@property (nonatomic, strong) NSSet *readDataTypes;
+ (HealthKitService*)sharedInstance;

- (HKBiologicalSex)getUsersGender;
- (NSDate*)getUsersDateOfBirth;

- (BOOL)userPermissionGranted;

- (void)getUsersWeightOnDate:(NSDate*)measureDate
                  completion:(void(^)(HKQuantitySample *, NSError *))completionBlock;

- (void)getUsersHeightOnDate:(NSDate*)measureDate
                  completion:(void(^)(HKQuantitySample *, NSError *))completionBlock;

- (void)setupPermission;
- (void)setupPermissionWithCompletionBlock:(void(^)(BOOL success, NSError *error))completion;
- (void)refreshData;

- (void)saveWeightInPoundsIntoHealthStore:(double)weight ofDate:(NSDate*)measureDate;
- (void)saveHeightInInchesIntoHealthStore:(double)height ofDate:(NSDate*)measureDate;
- (void)saveBodyFatPercentageIntoHealthStore:(double)percentage ofDate:(NSDate*)measureDate;
- (void)saveDietaryCalorieIntoHealthStore:(double)calorie ofDate:(NSDate*)measureDate;
- (void)saveActiveEnergyBurnedIntoHealthStore:(double)calorie ofDate:(NSDate*)measureDate;
- (void)saveHeartRateIntoHealthStore:(double)heartRate ofDate:(NSDate*)measureDate;
- (void)saveSystolicBloodPressureIntoHealthStore:(double)bloodPressure ofDate:(NSDate*)measureDate;
- (void)saveDiastolicBloodPressureIntoHealthStore:(double)bloodPressure ofDate:(NSDate*)measureDate;
- (void)saveBloodGlucoseIntoHealthStore:(double)bloodGlucose ofDate:(NSDate*)measureDate;
- (void)saveBodyTemperatureInCelsiusIntoHealthStore:(double)temperature ofDate:(NSDate*)measureDate;

//- (void)saveDietaryCholesterolIntoHealthStore:(double)cholesterol ofDate:(NSDate*)measureDate;
//- (void)saveDietaryFatTotalIntoHealthStore:(double)fatTotal ofDate:(NSDate*)measureDate;
- (void)saveDietaryNutrientAmountInGramIntoHealthStore:(double)nutrientAmount ofDate:(NSDate*)measureDate quantityTypeIdentifier:(NSString*)quantityTypeIdentifier;
@end
