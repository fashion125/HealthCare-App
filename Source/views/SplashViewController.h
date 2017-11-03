//
//  SplashViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 30/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiaryViewController.h"

@interface SplashViewController : UIViewController {
   UIActivityIndicatorView *spinner;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

- (BOOL) facebookLogin;

@end
