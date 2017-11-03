/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Contains shared helper methods on HKHealthStore that are specific to Fit's use cases.
            
*/

@import HealthKit;

@interface HKHealthStore (AAPLExtensions)

// Fetches the single most recent quantity of the specified type.
- (void)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantitySample *mostRecentSample, NSError *error))completion;
- (void)aapl_quantitySampleOnDate:(NSDate*)measureDate OfType:(HKQuantityType *)quantityType completion:(void (^)(HKQuantitySample *, NSError *))completion;
@end
