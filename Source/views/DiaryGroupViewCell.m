//
//  DiaryGroupViewCell.m
//  Cronometer
//
//  Created by choe on 8/27/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "DiaryGroupViewCell.h"

@implementation DiaryGroupViewCell
@synthesize title;
@synthesize calories;
@synthesize diary;
@dynamic entry;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) setEntry: (DiaryEntry *) diaryEntry {
    if (diaryEntry) {
        entry = diaryEntry;
        self.title.text = [entry description];
        
        if ([entry isKindOfClass: [DiaryGroup class]]) {
            DiaryGroup* dg = (DiaryGroup *)entry;
            if (dg.group == diary.activeGroup) {
//                self.selected = YES;
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
                    title.textColor = title.tintColor;
                }
            }
            if ([dg calories] != 0) {
                self.calories.text = [NSString stringWithFormat:@"%ld kcal", (long)round([entry calories])];
//                if (dg.calories < 0) {
//                    self.calories.textColor = [UIColor redColor];
//                }
            } else {
                self.calories.text = @"";
            }
            
        }
    }
}

- (IBAction)onGroupActivated:(id)sender {
    if (entry) {
        if ([entry isKindOfClass: [DiaryGroup class]]) {
            DiaryGroup* dg = (DiaryGroup *)entry;
            diary.activeGroup = dg.group;
            [diary.diaryTable reloadData];
        }
    }
}
@end
