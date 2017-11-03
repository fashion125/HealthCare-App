//
//  DiaryGroupViewCell.h
//  Cronometer
//
//  Created by choe on 8/27/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiaryViewController.h"
#import "DiaryEntry.h"
#import "Note.h"
#import "DiaryGroup.h"

@interface DiaryGroupViewCell : UIView
{
    UILabel *title;
    UILabel *calories;
    DiaryViewController *__unsafe_unretained diary;
    DiaryEntry *entry;
}
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *calories;
@property (nonatomic, strong) DiaryEntry *entry;
@property (unsafe_unretained) DiaryViewController *diary;
- (void) setEntry: (DiaryEntry *) entry;
- (IBAction)onGroupActivated:(id)sender;
@end
