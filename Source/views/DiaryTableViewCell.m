//
//  DiaryTableViewCell.m
//  Cronometer
//
//  Created by Boris Esanu on 23/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "DiaryTableViewCell.h"

#import "Formatter.h"
#import "Toolbox.h"

@implementation DiaryTableViewCell

@synthesize title;
@synthesize amount;
@synthesize units;
@synthesize calories;
@synthesize icon; 
@synthesize diary; 
@dynamic entry;
 
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
} 

- (CGFloat) widthForLabel: (UILabel*) label {
    if (label == nil) return 1;
    NSString* str = [NSString stringWithFormat:@"%@l", [label text]];
    CGSize textSize = [str sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    return textSize.width;
}

- (void) setEntry: (DiaryEntry *) diaryEntry {
   if (diaryEntry) {
      entry = diaryEntry;
      self.title.text = [entry description];
      if (![entry isKindOfClass: [Note class]]) {
          
          if ([entry isKindOfClass:[Biometric class]]) {
              self.amount.hidden = YES;
              self.calories.text = [Formatter formatAmount: [entry amount]];
              NSString* temp = [NSString stringWithFormat: @" %@ ", [entry units]];
              self.largeUnit.text = temp;//[entry units];
              self.descVerticalAlign.constant = 0;

              self.calories.textColor = [UIColor darkGrayColor];
              self.largeUnit.backgroundColor = [UIColor darkGrayColor];
              self.largeUnitWidth.constant = [self widthForLabel: self.largeUnit];
          } else {
              if (self.amount != nil) {
                 NSString* u = [NSString stringWithFormat: @"%@", [entry units]];
                 unichar c = [u characterAtIndex:0];
                 
                 if (c >= '0' && c <= '9') {
                    self.amount.text = [NSString stringWithFormat:@" %@ × %@ ", [Formatter formatAmount: [entry amount]], u];
                 } else {
                    self.amount.text = [NSString stringWithFormat:@" %@ %@ ", [Formatter formatAmount: [entry amount]], u];
                 }
                  //[self.amount sizeToFit];
                  self.amountWidth.constant = [self widthForLabel: self.amount];
              }
              self.units.text = @"" ;//[entry units];
              if ([entry calories] != 0) {
                  self.calories.text = [Formatter formatCalories:[entry calories]];
                  self.largeUnit.text = @" kcal ";
                  if (entry.calories < 0) {
                      self.calories.textColor = [UIColor redColor];
                  }else{
                      self.largeUnit.backgroundColor = [UIColor colorWithRed:34/255.0f
                                                                       green:167/255.0f
                                                                        blue:88/255.0f
                                                                       alpha:1.0];
                  }
                  self.largeUnitWidth.constant = [self widthForLabel: self.largeUnit];
              } else {
                  self.calories.text = @"";//@"0.0";
                  self.largeUnit.text = @" kcal ";
                  self.largeUnitWidth.constant = [self widthForLabel: self.largeUnit];
              }
          }
         self.icon.image = [UIImage imageNamed: [entry iconFile]];
      }
      if ([entry isKindOfClass: [DiaryGroup class]]) {
         DiaryGroup* dg = (DiaryGroup *)entry;
         if (dg.group == diary.activeGroup) {
            self.selected = YES;
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
               title.textColor = title.tintColor;
            }
         }
         if ([dg calories] != 0) {
            self.calories.text = [NSString stringWithFormat:@"%ld kcal", (long)round([entry calories])];
             if (dg.calories < 0) {
                 self.calories.textColor = [UIColor redColor];
             }

         } else {
            self.calories.text = @"";
         }

      }
       
//       [self.largeUnit sizeToFit];
//       CGRect frame = self.largeUnit.frame;
//       frame.size.width += 8;
//       frame.origin.x = self.calories.frame.origin.x + self.calories.frame.size.width / 2
//            - self.largeUnit.frame.size.width / 2;
//       self.largeUnit.frame = frame;

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

- (void)didTransitionToState:(UITableViewCellStateMask)state {
   [super didTransitionToState:state];
  // NSLog(@"%u", state);
   //calories.hidden = (state & (UITableViewCellStateShowingEditControlMask | UITableViewCellStateShowingDeleteConfirmationMask));
}

@end
