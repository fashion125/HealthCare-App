//
//  SetWeightGoalViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 7/15/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetWeightGoalViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (readwrite, strong) NSMutableArray* mWeightGoalValues;
@property (readwrite, strong) NSMutableArray* mWeightGoalTitles;
@property (readwrite, strong) id setting;

@end
