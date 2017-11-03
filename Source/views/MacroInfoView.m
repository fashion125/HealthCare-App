//
//  MacroInfoView.m
//  Cronometer
//
//  Created by Boris Esanu on 7/18/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "MacroInfoView.h"

@implementation MacroInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (id) contentView {
    MacroInfoView *view = [[[NSBundle mainBundle] loadNibNamed:@"MacroInfoView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([view isKindOfClass:[MacroInfoView class]])
        return view;
    else
        return nil;
}
- (void) setValuesWith: (double) p carbs: (double) c lipids: (double)l alchol: (double) a {
    [self.proteinLabel setText: [NSString stringWithFormat:@"%.1f%@", p, @"%"] ];
    [self.carbsLabel setText: [NSString stringWithFormat:@"%.1f%@", c, @"%"] ];
    [self.lipidsLabel setText: [NSString stringWithFormat:@"%.1f%@", l, @"%"] ];
    [self.alcoholLabel setText: [NSString stringWithFormat:@"%.1f%@", a, @"%"] ];
}
@end
