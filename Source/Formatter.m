//
//  Formatter.m
//  Cronometer
//
//  Created by Boris Esanu on 11/10/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "Formatter.h"

@implementation Formatter

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
 

static NSNumberFormatter *caloriesFormatter;
static NSNumberFormatter *amountFormatter;
static NSNumberFormatter *smallAmountFormatter;

+ (NSNumberFormatter*) getCaloriesFormatter {
   if (caloriesFormatter == nil) { 
      caloriesFormatter = [[NSNumberFormatter alloc] init];       
      [caloriesFormatter setPositiveFormat:@"####0.0"];    
   }
   return caloriesFormatter;
}

+ (NSNumberFormatter*) getAmountFormatter {
   if (amountFormatter == nil) { 
      amountFormatter = [[NSNumberFormatter alloc] init];       
      [amountFormatter setPositiveFormat:@"####0.#"];    
   }
   return amountFormatter;
}


+ (NSNumberFormatter*) getSmallAmountFormatter {
   if (smallAmountFormatter == nil) {
      smallAmountFormatter = [[NSNumberFormatter alloc] init];
      [smallAmountFormatter setPositiveFormat:@"#0.##"];
   }
   return smallAmountFormatter;
}



+ (NSString*) formatCalories:(double)value {
   return [[Formatter getCaloriesFormatter] stringFromNumber: [NSNumber numberWithDouble:value]];
}

+ (NSString*) formatAmount:(double)value {
   if (value < 2) {
      return [[Formatter getSmallAmountFormatter] stringFromNumber: [NSNumber numberWithDouble:value]];
   }
   return [[Formatter getAmountFormatter] stringFromNumber: [NSNumber numberWithDouble:value]];
}
 
+ (NSString*) formatNumberAmount:(NSNumber*)value {
   return [[Formatter getAmountFormatter] stringFromNumber: value];
}

+ (NSNumber*) numberFromString: (NSString*)text {
   return [[Formatter getAmountFormatter] numberFromString: text];
}

@end
