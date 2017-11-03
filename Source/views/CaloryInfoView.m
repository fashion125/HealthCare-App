//
//  CaloryInfoView.m
//  Cronometer
//
//  Created by choe on 8/6/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "CaloryInfoView.h"

@implementation CaloryInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (id) contentView {
    CaloryInfoView *view = [[[NSBundle mainBundle] loadNibNamed:@"CaloryInfoView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([view isKindOfClass:[CaloryInfoView class]])
        return view;
    else
        return nil;
}

- (void)setValues: (id)summary name:(NSString*) name {
    [self.nameLabel setText: name];
    
//    double percent = 0;
    double total = 0;
    double val = 0;
    Summary* s = (Summary*)summary;

    if ([name isEqualToString: @"PROTEIN"]) {
//        percent = s.consumed.protein_percent;
        total = s.consumed.total;
        val = s.consumed.protein_kcal;
        
    } else if ([name isEqualToString: @"FAT"]) {
//        percent = s.consumed.fat_percent;
        total = s.consumed.total;
        val = s.consumed.fat_kcal;
        
    } else if ([name isEqualToString: @"CARBS"]) {
//        percent = s.consumed.carbs_percent;
        total = s.consumed.total;
        val = s.consumed.carbs_kcal;
        
    } else if ([name isEqualToString: @"ALCOHOL"]) {
//        percent = s.consumed.alcohol_percent;
        total = s.consumed.total;
        val = s.consumed.alcohol_kcal;
        
    }
//    else if ([name isEqualToString: @"CALORIC DEFICIT"]) {
////        percent = s.consumed.deficit_percent;
//        total = s.consumed.total;
//        val = s.consumed.deficit_kcal;
//        
//    }
    else if ([name isEqualToString: @"BMR"]) {
//        percent = s.burned.bmr_percent;
        total = s.burned.total;
        val = s.burned.bmr_kcal;
        
    } else if ([name isEqualToString: @"ACTIVITY"]) {
//        percent = s.burned.activity_percent;
        total = s.burned.total;
        val = s.burned.activity_kcal;
        
    } else if ([name isEqualToString: @"EXERCISE"]) {
//        percent = s.burned.exercise_percent;
        total = s.burned.total;
        val = s.burned.exercise_kcal;
        
    }
//    else if ([name isEqualToString: @"CALORIC SURPLUS"]) {
////        percent = s.burned.surplus_percent;
//        total = s.burned.total;
//        val = s.burned.surplus_kcal;
//    }
//    if (!isShowing) {
//        self.totalWidth.constant = 0;
//        self.percentLabel.hidden = YES;
//        [self.valueLabel setText : [NSString stringWithFormat: @"%.1f kcal", val]];
//    } else {
        [self.valueLabel setText : [NSString stringWithFormat: @"%.1f", val]];
        [self.totalLabel setText : [NSString stringWithFormat: @"/%.1f kcal", total]];
        [self.percentLabel setText : [NSString stringWithFormat: @"%d%%", (int)round(val/total*100.0)]];
//    }
}

@end
