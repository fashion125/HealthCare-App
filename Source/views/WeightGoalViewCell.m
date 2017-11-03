//
//  WeightGoalViewCell.m
//  Cronometer
//
//  Created by choe on 8/14/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "WeightGoalViewCell.h"

@interface WeightGoalViewCell()
@property (strong, readwrite) Summary* summary;
@end

@implementation WeightGoalViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setSummaryWith : (Summary*) summary1 {
    
    _summary = summary1;
   if (summary1.weight_goal < 0) {
      [self.commentLabel setText: [NSString stringWithFormat: @"For your weight goal you must burn %d more calories today", (int)fabs(round(summary1.weight_goal)) ] ];
   } else {
      [self.commentLabel setText: [NSString stringWithFormat: @"For your weight goal you can eat %d more calories today", (int)round(summary1.weight_goal) ] ];
   }
    [self setNeedsDisplay];
   
}
@end
