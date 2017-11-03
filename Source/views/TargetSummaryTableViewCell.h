//
//  TargetSummaryTableViewCell.h
//  Cronometer
//
//  Created by Boris Esanu on 06/11/2011.
//  Copyright (c) 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NutrientInfo.h"
#import "Target.h"

@interface TargetSummaryTableViewCell : UITableViewCell 
 
//@property (strong, nonatomic) IBOutlet TargetBar *targetBar;
//@property (strong, nonatomic) IBOutlet UILabel *label;

-(void)setTarget:(Target*) target forNutrient: (NutrientInfo*) ni amount:(double)amount;

@end
