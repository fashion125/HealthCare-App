//
//  SelectBMRViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 7/16/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectBMRViewController : UIViewController
@property (readwrite, strong) id setting;
@property (readwrite, strong) NSMutableArray* mBMRValues;
@property (readwrite, strong) NSMutableArray* mBMRTitles;
@end
