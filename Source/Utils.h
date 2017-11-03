//
//  Utils.h
//  Cronometer
//
//  Created by Boris Esanu on 7/3/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#ifndef Cronometer_Utils_h
#define Cronometer_Utils_h

#import <Foundation/Foundation.h>

@interface Utils : NSObject
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

+ (UIViewController *) newViewControllerWithId: (NSString *)identifier;
+ (UIViewController *) newViewControllerWithId: (NSString *)identifier In: (NSString*) prefix;
+ (BOOL) isIPhone4_or_less;
+ (BOOL) isIPhone5;
+ (BOOL) isIPhone5s;
+ (BOOL) isIPhone6;
+ (BOOL) isIPhone6s;
+ (BOOL) isIPad;
@end

#endif
