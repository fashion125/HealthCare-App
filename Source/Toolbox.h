//
//  Toolbox.h
//  Cronometer
//
//  Created by Boris Esanu on 21/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <Foundation/Foundation.h> 

@interface Toolbox : NSObject
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

+ (NSString *) urlEncode: (NSString *)str;
+ (NSData *)sha256:(NSData *)data;
+ (NSString *)encode:(NSData *)plainText;
+ (void) showMessage: (NSString *)msg  withTitle: (NSString *) title;
+ (void) showMessage: (NSString *)msg;
+ (void) moveView: (UIView*) view up: (int) delta;
+ (NSString *) capString:(NSString *)str maxLen:(int)maxLen;
+ (UIColor *) darker: (UIColor *) col by: (double) val;

@end
