//
//  AddFoodTableViewCell.m
//  Cronometer
//
//  Created by Boris Esanu on 2014-05-04.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import "AddFoodTableViewCell.h"
#import "Formatter.h"

@implementation AddFoodTableViewCell

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

- (void)setNutrient:(NutrientInfo *)ni andAmount:(double)amount {
   self.ni = ni;
   
   self.unitField.text = ni.unit;
   
   if (ni.pId != 0) {
      NutrientInfo *pi = [[WebQuery singleton] nutrient:ni.pId];
      if (pi && pi.pId != 0) {
         self.nameField.text = [NSString  stringWithFormat:@"      %@", ni.name];
      } else {
         self.nameField.text = [NSString  stringWithFormat:@"   %@", ni.name];
      }
   } else {
      self.nameField.text = ni.name;
   }
   
   if (amount != 0) {
      self.amountField.text = [NSString  stringWithFormat:@"%.2f", amount];
      self.amountField.textColor = [UIColor blackColor];
   } else {
      self.amountField.text = @"0.0";
      self.amountField.textColor = [UIColor lightGrayColor];
   }

   if (ni.rdi == 0) {
      self.dvField.hidden = YES;
   } else {
      self.dvField.text = [NSString stringWithFormat:@"%.1f%%", 100.0 * amount / ni.rdi];
   }
}
 
@end
