//
//  CronometerAppDelegate.h
//  Cronometer
//
//  Created by Boris Esanu on 08/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

#import "SplashViewController.h"

@class SplashViewController;

@interface CronometerAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate> {
   
}
@property (strong, nonatomic) UIWindow *window;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end
