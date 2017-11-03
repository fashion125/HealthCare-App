//
//  MacrosViewCell.h
//  Cronometer
//
//  Created by choe on 8/1/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChart.h"

@interface MacrosViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PieChart *pieChart;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pieChartHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pieChartWidth;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelWidth;

@property (strong, nonatomic) IBOutlet UIView *energyBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *energyVal;
@property (strong, nonatomic) IBOutlet UILabel *energyLabel;

@property (strong, nonatomic) IBOutlet UIView *proteinBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *proteinVal;
@property (strong, nonatomic) IBOutlet UILabel *proteinLabel;

@property (strong, nonatomic) IBOutlet UIView *carbsBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carbsVal;
@property (strong, nonatomic) IBOutlet UILabel *carbsLabel;

@property (strong, nonatomic) IBOutlet UIView *fatBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fatVal;
@property (strong, nonatomic) IBOutlet UILabel *fatLabel;

- (void) setMacrosWithProtein: (double) p pg: (double) pg Carbs: (double) c cg: (double) cg Lipids: (double) f fg: (double)fg Alcohol: (double) a ag: (double) ag;
@end
