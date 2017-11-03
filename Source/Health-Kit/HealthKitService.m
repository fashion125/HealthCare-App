//
//  HeathKitServie.m
//  Cronometer
//
//  Created by Frank Mao on 2014-10-02.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import "HealthKitService.h"
#import "HKHealthStore+AAPLExtensions.h"
 
@import HealthKit;

@interface HealthKitService()




@end


@implementation HealthKitService

+ (HealthKitService*)sharedInstance {
    static HealthKitService * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HealthKitService alloc] init];
    });
    
    return sharedInstance;
}
- (id)init
{
    self = [super init];
    if (self) {
        if (self.userPermissionGranted) {
            [self setupPermission];
        }

    }
    return self;
}

- (BOOL)userPermissionGranted
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"userPermissionGranted"];
}

- (void)setUserPermissionGranted:(BOOL)userPermissionGranted
{
    [[NSUserDefaults standardUserDefaults] setBool:userPermissionGranted forKey:@"userPermissionGranted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupPermission
{
    [self setupPermissionWithCompletionBlock:NULL];
}
- (void)setupPermissionWithCompletionBlock:(void(^)(BOOL success, NSError *error))completion
{
    

    // Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
    // first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
    // In your own app, you should consider requesting permissions the first time a user wants to interact with
    // HealthKit data.
    if ([HKHealthStore isHealthDataAvailable]) {
        self.writeDataTypes = [self dataTypesToWrite];
        self.readDataTypes = [self dataTypesToRead];
        self.healthStore = [[HKHealthStore alloc] init];
        [self.healthStore requestAuthorizationToShareTypes:self.writeDataTypes readTypes:self.readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }

            self.isServiceAccessible = self.writeDataTypes.count + self.readDataTypes.count > 0;
            
            if (self.isServiceAccessible) {
                self.userPermissionGranted = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the user interface based on the current user's health information.
  
                [self refreshData];
            });
            
            
            if (completion) {
                completion(self.isServiceAccessible, error);
            }
        }];
    }
}

- (void)refreshData
{
    [self getUsersHeight];
    [self getUsersWeight];
}
#pragma mark - HealthKit Permissions

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {

    return [NSSet setWithArray:@[
                                 [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed],
                                 [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                                 [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                                 [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                                 [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCholesterol],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatPolyunsaturated],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatMonounsaturated],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatSaturated],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySugar],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminA],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminB6],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminB12],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminC],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminD],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminE],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminK],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCalcium],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryIron],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryThiamin],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryRiboflavin],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryNiacin],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFolate],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPantothenicAcid],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPhosphorus],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryIodine],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryMagnesium],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryZinc],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySelenium],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCopper],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryManganese],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChromium],
//                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryMolybdenum],//no matching
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPotassium],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine],
                                 ]
            ];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType, biologicalSexType, nil];
}

#pragma mark - Reading HealthKit Data

- (NSDate*)getUsersDateOfBirth {
    NSError * error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    return dateOfBirth;
 
}
- (HKBiologicalSex)getUsersGender {
    
    NSError * error;
    HKBiologicalSexObject * genderObject = [self.healthStore biologicalSexWithError:&error];
    if (error){
        NSLog(@"%@", [error localizedDescription]);
    }
    return genderObject.biologicalSex;

}
- (void)getUsersHeight {



    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    if (![self.readDataTypes containsObject:heightType]) {
        return;
    }
    // Query to get the user's latest height, if it exists.
    [self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantitySample *mostRecentQuantitySample, NSError *error) {
        if (!mostRecentQuantitySample) {
            NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.usersHeight = nil;
            });
        }
        else {

            self.usersHeight = mostRecentQuantitySample;
            }
    }];
    
    
}


- (void)getUsersWeight {
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    
    if (![self.readDataTypes containsObject:weightType]) {
        return;
    }
    // Query to get the user's latest height, if it exists.
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantitySample *mostRecentQuantitySample, NSError *error) {
        if (!mostRecentQuantitySample) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.usersWeight = nil;
            });
        }
        else {
            
            self.usersWeight = mostRecentQuantitySample;
        }
    }];
}
- (void)getUsersWeightOnDate:(NSDate*)measureDate
                  completion:(void(^)(HKQuantitySample *, NSError *))completionBlock
{
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    if (![self.readDataTypes containsObject:weightType]) {
        return;
    }
    [self.healthStore aapl_quantitySampleOnDate:measureDate
                                         OfType:weightType
                                     completion:^(HKQuantitySample * quantitySample, NSError * error) {
                                         if (completionBlock) {
                                             completionBlock(quantitySample, error);
                                         }
                                     }];
}

- (void)getUsersHeightOnDate:(NSDate*)measureDate
                  completion:(void(^)(HKQuantitySample *, NSError *))completionBlock
{
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    if (![self.readDataTypes containsObject:heightType]) {
        return;
    }
    [self.healthStore aapl_quantitySampleOnDate:measureDate
                                         OfType:heightType
                                     completion:^(HKQuantitySample * quantitySample, NSError * error) {
                                         if (completionBlock) {
                                             completionBlock(quantitySample, error);
                                         }
                                     }];
}
#pragma mark - Writing HealthKit Data
// measureDate always 12:00am
- (void)cleanUpExportedSamples:(NSDate*)measureDate
{
    

}
- (void)saveDataIntoHealthStore:(double)data ofDate:(NSDate*)measureDate quantity:(HKQuantity*)quantity quantityType:(HKQuantityType*)quantityType withCompletionBlock:(void(^)(BOOL, NSError *))completionBlock{
    
    if (![self.writeDataTypes containsObject:quantityType]) {
        NSLog(@"skipping writing date type %@", quantityType);
        return;
    }
    
    HKQuantitySample *dataSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:measureDate endDate:measureDate];
    
    
    NSDate * startDate = [measureDate dateByAddingTimeInterval:-100];
    NSDate * endDate = [measureDate dateByAddingTimeInterval:100];
    NSPredicate * predicate1 = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    NSPredicate * predicate2 = [HKQuery predicateForObjectsFromSource:[HKSource defaultSource]];
    
    NSCompoundPredicate * compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
    
    HKSampleQuery * query = [[HKSampleQuery alloc] initWithSampleType:quantityType
        predicate:compoundPredicate
        limit:100
        sortDescriptors:nil
        resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
           
            for (HKQuantitySample* result in results) {
                [self.healthStore deleteObject:result withCompletion:^(BOOL success, NSError *error) {
                    if (success) {
//                         NSLog(@"deleted %@ success: %d", result, success);
                    }else{
                         NSLog(@"deleting %@ failed, error: %@", result.quantityType, error);
                    }
                }];

            }
            
           
            
            
            [self.healthStore saveObject:dataSample withCompletion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"An error occured saving data %@. In your app, try to handle this gracefully. The error was: %@.", dataSample, error);
                    //            abort();
//                    [Toolbox showMessage:[error localizedDescription] withTitle:@"Error"];
                }else{
                    if (completionBlock) {
                        completionBlock(success, error);
                    }
                }
                
            }];
            
        }];
   
   
    
      [self.healthStore executeQuery:query];
    
    

}

- (void)saveHeightInInchesIntoHealthStore:(double)height ofDate:(NSDate*)measureDate{

    HKUnit *inchUnit = [HKUnit inchUnit];
    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
  
    [self saveDataIntoHealthStore:height ofDate:measureDate quantity:heightQuantity quantityType:heightType withCompletionBlock:NULL];
    
}

- (void)saveWeightInPoundsIntoHealthStore:(double)weight ofDate:(NSDate*)measureDate{

    HKUnit *poundUnit = [HKUnit poundUnit];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
 
    
    [self saveDataIntoHealthStore:weight  ofDate:measureDate quantity:weightQuantity quantityType:weightType withCompletionBlock:NULL];
}


- (void)saveBodyFatPercentageIntoHealthStore:(double)percentage ofDate:(NSDate*)measureDate{
    
    HKQuantity *percentageQuantity = [HKQuantity quantityWithUnit:[HKUnit percentUnit] doubleValue:percentage];
    
    HKQuantityType *percentageType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage];
    
    
    [self saveDataIntoHealthStore:percentage  ofDate:measureDate quantity:percentageQuantity quantityType:percentageType withCompletionBlock:NULL];
}

- (void)saveActiveEnergyBurnedIntoHealthStore:(double)calorie ofDate:(NSDate*)measureDate{
    
    HKQuantity *calorieQuantity = [HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:calorie];
    
    HKQuantityType *calorieType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    
    [self saveDataIntoHealthStore:calorie  ofDate:measureDate quantity:calorieQuantity quantityType:calorieType withCompletionBlock:NULL];
}

- (void)saveDietaryCalorieIntoHealthStore:(double)calorie ofDate:(NSDate*)measureDate{
    
    HKQuantity *calorieQuantity = [HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:calorie];
    
    HKQuantityType *calorieType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    
    [self saveDataIntoHealthStore:calorie  ofDate:measureDate quantity:calorieQuantity quantityType:calorieType withCompletionBlock:NULL];
}

- (void)saveHeartRateIntoHealthStore:(double)heartRate ofDate:(NSDate*)measureDate{

    HKQuantity *heartRateQuantity = [HKQuantity quantityWithUnit: [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]   doubleValue:heartRate];
    
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    
    [self saveDataIntoHealthStore:heartRate  ofDate:measureDate quantity:heartRateQuantity quantityType:heartRateType withCompletionBlock:NULL];
}

- (void)saveSystolicBloodPressureIntoHealthStore:(double)bloodPressure ofDate:(NSDate*)measureDate{
    
    HKQuantity *bloodPressureQuantity = [HKQuantity quantityWithUnit: [HKUnit millimeterOfMercuryUnit]   doubleValue:bloodPressure];
    
    HKQuantityType *bloodPressureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
 
    
    [self saveDataIntoHealthStore:bloodPressure  ofDate:measureDate quantity:bloodPressureQuantity quantityType:bloodPressureType withCompletionBlock:NULL];
}

- (void)saveDiastolicBloodPressureIntoHealthStore:(double)bloodPressure ofDate:(NSDate*)measureDate{
    
    HKQuantity *bloodPressureQuantity = [HKQuantity quantityWithUnit: [HKUnit millimeterOfMercuryUnit]   doubleValue:bloodPressure];
    
    HKQuantityType *bloodPressureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    
 
    
    [self saveDataIntoHealthStore:bloodPressure  ofDate:measureDate quantity:bloodPressureQuantity quantityType:bloodPressureType withCompletionBlock:NULL];
}

- (void)saveBloodGlucoseIntoHealthStore:(double)bloodGlucose ofDate:(NSDate*)measureDate{
    
    HKQuantity *bloodGlucoseQuantity = [HKQuantity quantityWithUnit: [[HKUnit gramUnit] unitDividedByUnit:[HKUnit literUnit]]   doubleValue:bloodGlucose];
    
    HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    

    
    [self saveDataIntoHealthStore:bloodGlucose  ofDate:measureDate quantity:bloodGlucoseQuantity quantityType:bloodGlucoseType withCompletionBlock:NULL];
}

- (void)saveBodyTemperatureInCelsiusIntoHealthStore:(double)temperature ofDate:(NSDate*)measureDate{
    
    HKQuantity *bodyTemperatureQuantity = [HKQuantity quantityWithUnit: [HKUnit degreeCelsiusUnit]   doubleValue:temperature];
    
    HKQuantityType *bodyTemperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
 
 
    
    [self saveDataIntoHealthStore:temperature  ofDate:measureDate quantity:bodyTemperatureQuantity quantityType:bodyTemperatureType withCompletionBlock:NULL];
}


- (void)saveDietaryNutrientAmountInGramIntoHealthStore:(double)nutrientAmount ofDate:(NSDate*)measureDate quantityTypeIdentifier:(NSString*)quantityTypeIdentifier{
    
    HKQuantity *nutrientQuantity = [HKQuantity quantityWithUnit: [HKUnit gramUnit]    doubleValue:nutrientAmount];
    
    HKQuantityType *nutrientType = [HKQuantityType quantityTypeForIdentifier:quantityTypeIdentifier];
    
 
    
    [self saveDataIntoHealthStore:nutrientAmount ofDate:measureDate quantity:nutrientQuantity quantityType:nutrientType withCompletionBlock:NULL];
    
}
- (void)saveDietaryCholesterolIntoHealthStore:(double)cholesterol ofDate:(NSDate*)measureDate{
    
    HKQuantity *cholesterolQuantity = [HKQuantity quantityWithUnit: [HKUnit gramUnit]    doubleValue:cholesterol];
    
    HKQuantityType *cholesterolType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCholesterol];
 
    
    [self saveDataIntoHealthStore:cholesterol ofDate:measureDate quantity:cholesterolQuantity quantityType:cholesterolType withCompletionBlock:NULL];
    
}


- (void)saveDietaryFatTotalIntoHealthStore:(double)fatTotal ofDate:(NSDate*)measureDate{

    
    HKQuantity *fatTotalQuantity = [HKQuantity quantityWithUnit: [HKUnit gramUnit]    doubleValue:fatTotal];
    
    HKQuantityType *fatTotalType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal];
 
    
    [self saveDataIntoHealthStore:fatTotal ofDate:measureDate quantity:fatTotalQuantity quantityType:fatTotalType withCompletionBlock:NULL];
    
}


#pragma mark - Convenience

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    
    return numberFormatter;
}
@end
