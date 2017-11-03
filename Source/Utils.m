//
//  Utils.m
//  Cronometer
//
//  Created by Boris Esanu on 7/3/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@implementation Utils

+ (UIViewController *) newViewControllerWithId: (NSString *)identifier {
   // log the last view we tried to show as it may be useful to see it in any crash logs
   [[Crashlytics sharedInstance] setObjectValue:identifier forKey:@"LastViewLoaded"];

   
    UIViewController *vc = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        vc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    } else {
        vc = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    }
    return vc;
}

+ (UIViewController *) newViewControllerWithId: (NSString *)identifier In: (NSString*) prefix {
   // log the last view we tried to show as it may be useful to see it in any crash logs
   [[Crashlytics sharedInstance] setObjectValue:identifier forKey:@"LastViewLoaded"];

   UIViewController *vc = nil;
    NSString* storyboardName = nil;//[NSString stringWithFormat:@"%@"]
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        storyboardName = [NSString stringWithFormat:@"%@_iPhone", prefix];
    } else {
        storyboardName = [NSString stringWithFormat:@"%@_iPad", prefix];
    }
    vc = [[UIStoryboard storyboardWithName: storyboardName bundle: nil] instantiateViewControllerWithIdentifier: identifier];
    return vc;
}
+ (BOOL) isIPhone4_or_less {
    return IS_IPHONE_4_OR_LESS;
}
+ (BOOL) isIPhone5 {
    return IS_IPHONE_5;
}
+ (BOOL) isIPhone5s {
    return IS_IPHONE_5;
}
+ (BOOL) isIPhone6 {
    return IS_IPHONE_6;
}
+ (BOOL) isIPhone6s {
    return IS_IPHONE_6P;
}
+ (BOOL) isIPad {
    return IS_IPAD;
}

@end

