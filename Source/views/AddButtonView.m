//
//  AddButtonView.m
//  Cronometer
//
//  Created by Alex Sun on 12/15/15.
//  Copyright © 2015 cronometer.com. All rights reserved.
//

#import "AddButtonView.h"
#import "DiaryViewController.h"

@interface AddButtonView()

@property (readwrite) DiaryViewController* diaryVC;
@end

@implementation AddButtonView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//Only override drawRect: if you perform custom drawing.
//An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
// Drawing code
    [super drawRect:rect];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    //6 CGContextSetLineWidth(ctx, 5);
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);//[[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0] CGColor]);
    
//    CGContextAddArc(ctx, 3, 3, 3, 0, M_PI/2, 0);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, 3, 3, 2, M_PI, M_PI*3/2, 0);
    CGContextMoveToPoint(ctx, 3, 1);
    CGContextAddLineToPoint(ctx, width-3, 1);
    CGContextAddArc(ctx, width-3, 3, 2, M_PI*3/2, M_PI*2, 0);
    CGContextMoveToPoint(ctx, 3, height-1);
    CGContextAddLineToPoint(ctx, width-3, height-1);
    CGContextAddArc(ctx, width-3, height-3, 2, 0, M_PI/2, 0);
    CGContextMoveToPoint(ctx, 1, 3);
    CGContextAddLineToPoint(ctx, 1, height-3);
    CGContextAddArc(ctx, 3, height-3, 2, M_PI/2, M_PI, 0);
    CGContextMoveToPoint(ctx, width-1, 3);
    CGContextAddLineToPoint(ctx, width-1, height-3);
    
    
    CGContextStrokePath(ctx);
    
}

- (void) setDiaryVc: (id)diaryVC {
    self.diaryVC = (DiaryViewController*) diaryVC;
}
+ (id) contentView:(id)diaryVC {
    
    
    AddButtonView *view = [[[NSBundle mainBundle] loadNibNamed:@"AddButtonView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([view isKindOfClass:[AddButtonView class]]) {
        [view setDiaryVc: diaryVC];
        return view;
    } else
        return nil;
}
- (IBAction)onClickAdd:(id)sender {
    if (self.diaryVC == nil) {
        return;
    }
    [self.diaryVC onClickAdd:nil];
}
@end
