//
//  UIApplication+NetworkActivity.h
//  Cronometer
//
//  Created by Boris Esanu on 16/12/2011.
//  Copyright (c) 2011 cronometer.com. All rights reserved.
//
// Code From:
//   http://stackoverflow.com/questions/3032192/networkactivityindicatorvisible 
 
@interface UIApplication (NetworkActivity)
- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;
- (void)resetNetworkActivityIndicator;
@end
