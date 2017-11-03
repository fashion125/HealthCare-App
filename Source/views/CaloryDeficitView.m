//
//  CaloryDeficitView.m
//  Cronometer
//
//  Created by choe on 9/6/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "CaloryDeficitView.h"

@implementation CaloryDeficitView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
+ (id) contentView {
    CaloryDeficitView *view = [[[NSBundle mainBundle] loadNibNamed:@"CaloryDeficitView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([view isKindOfClass:[CaloryDeficitView class]])
        return view;
    else
        return nil;
}

- (void)setValues: (id)summary name:(NSString*) name {
    [self.nameLabel setText: name];
    
    //    double percent = 0;
    double val = 0;
    Summary* s = (Summary*)summary;
    
    if ([name isEqualToString: @"CALORIC DEFICIT"]) {
        //        percent = s.consumed.deficit_percent;
        val = s.consumed.deficit_kcal;
        
    } else if ([name isEqualToString: @"CALORIC SURPLUS"]) {
        //        percent = s.burned.surplus_percent;
        val = s.burned.surplus_kcal;
    }
    
    [self.valueLabel setText : [NSString stringWithFormat: @"%.1f kcal", val]];
}


@end
