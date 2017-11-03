//
//  UIApplication+NetworkActivity.m
//  Cronometer
//
//  Created by Boris Esanu on 16/12/2011.
//  Copyright (c) 2011 cronometer.com. All rights reserved.
//

#import "UIApplication+NetworkActivity.h"
 
static NSInteger activityCount = 0;
@implementation UIApplication (NetworkActivity)
- (void)showNetworkActivityIndicator {
   if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
   @synchronized ([UIApplication sharedApplication]) {
      if (activityCount == 0) {
         [self setNetworkActivityIndicatorVisible:YES];
      }
      activityCount++;
   }
}
- (void)hideNetworkActivityIndicator {
   if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
   @synchronized ([UIApplication sharedApplication]) {
      activityCount--;
      if (activityCount <= 0) {
         [self setNetworkActivityIndicatorVisible:NO];
         activityCount=0;
      }    
   }
}

- (void)resetNetworkActivityIndicator {
   if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
   @synchronized ([UIApplication sharedApplication]) {
      [self setNetworkActivityIndicatorVisible:NO];
      activityCount=0;
   }
}


@end
