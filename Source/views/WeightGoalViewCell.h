//
//  WeightGoalViewCell.h
//  Cronometer
//
//  Created by choe on 8/14/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightGoalViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *commentLabel;

-(void)setSummaryWith : (Summary*) summary;
@end
