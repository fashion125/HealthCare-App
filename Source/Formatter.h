//
//  Formatter.h
//  Cronometer
//
//  Created by Boris Esanu on 11/10/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Formatter : NSObject


+ (NSString*) formatCalories:(double)value;
+ (NSString*) formatAmount:(double)value;
+ (NSString*) formatNumberAmount:(NSNumber*)value;
+ (NSNumber*) numberFromString: (NSString*)text;

@end
