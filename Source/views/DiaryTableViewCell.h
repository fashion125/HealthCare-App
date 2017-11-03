//
//  DiaryTableViewCell.h
//  Cronometer
//
//  Created by Boris Esanu on 23/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiaryViewController.h"
#import "DiaryEntry.h"
#import "Note.h"
#import "DiaryGroup.h"

@interface DiaryTableViewCell : UITableViewCell {
   UILabel *title;
   UILabel *amount;
   UILabel *units;
   UILabel *calories;
   UIImageView *icon; 
   DiaryViewController *__unsafe_unretained diary;
   DiaryEntry *entry;
}
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *amount;
@property (nonatomic, strong) IBOutlet UILabel *units;
@property (nonatomic, strong) IBOutlet UILabel *largeUnit;
@property (nonatomic, strong) IBOutlet UILabel *calories;
@property (nonatomic, strong) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *amountWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *largeUnitWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descVerticalAlign;

@property (nonatomic, strong) DiaryEntry *entry;
@property (unsafe_unretained) DiaryViewController *diary;

- (void) setEntry: (DiaryEntry *) entry;

- (IBAction)onGroupActivated:(id)sender;


@end


