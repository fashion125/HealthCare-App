//
//  TargetSummaryTableViewCell.m
//  Cronometer
//
//  Created by Boris Esanu on 06/11/2011.
//  Copyright (c) 2011 cronometer.com. All rights reserved.
//

#import "TargetSummaryTableViewCell.h"
#import "WebQuery.h"
#import "Formatter.h"

@interface TargetSummaryTableViewCell()
@property (strong, readwrite) Target* target;
@property (strong, readwrite) NutrientInfo* ni;
@property (strong, readwrite) NSNumber* amount;
@property (strong, nonatomic) IBOutlet UIView *targetBar1;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel;
@property (strong, nonatomic) IBOutlet UIImageView *redBar;
@property (strong, nonatomic) IBOutlet UIImageView *greenBar;
@property (strong, nonatomic) IBOutlet UIImageView *yellowBar;

@end

@implementation TargetSummaryTableViewCell  

//@synthesize targetBar;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   [super setSelected:selected animated:animated];
   
   // Configure the view for the selected state
}
 
-(int) getNumParents: (NutrientInfo*)ni {
   int total = 0; 
   while (ni != nil && ni.pId != 0) {
      total++;
      ni = [[WebQuery singleton] nutrient: ni.pId];
   }
   return total;
}
-(void)drawRect:(CGRect)rect {
    [self setTargetAgain:self.target forNutrient:self.ni amount:[self.amount doubleValue]];
}
-(void)setTargetAgain:(Target*) target forNutrient: (NutrientInfo*) ni amount:(double)amount {
    self.target = target;
    self.ni = ni;
    self.amount = @(amount);
    
    self.targetBar1.layer.cornerRadius = 5;
    self.targetBar1.layer.masksToBounds = YES;
    
    if ([target min] != nil) {
        double tMin = [[target min] doubleValue];
        long percent = 0;
        if (tMin != 0) {
            percent = round(100 * amount / tMin);
        } else {
            if (amount >= 0.01) {
                percent = 100;
            } else {
                amount = 0;
            }
        }
        //        self.targetBar.curValue = amount;
        //        self.targetBar.maxValue = tMin;
        [self.targetLabel setText: [NSString stringWithFormat: @"%@ %@ / %@ %@ (%ld%%)", ni.name, [Formatter formatAmount: amount], [Formatter formatAmount: tMin], ni.unit, percent]];
        
        if (tMin <= amount) {
            self.yellowBar.hidden = YES;
            self.greenBar.hidden = NO;
            self.redBar.hidden = YES;
        } else {
            self.yellowBar.hidden = NO;
            self.greenBar.hidden = YES;
            self.redBar.hidden = YES;
            CGRect rect = self.yellowBar.frame;
            rect.size.width = amount/tMin * self.targetBar1.frame.size.width;
            self.yellowBar.frame = rect;
        }
        if ([target max] != nil) {
            if (amount >= 0.01 && amount > [[target max] doubleValue]) {
                self.yellowBar.hidden = YES;
                self.greenBar.hidden = YES;
                self.redBar.hidden = NO;
                //                self.targetBar.barCol = [UIColor colorWithHue: 0.025 saturation:0.99 brightness:0.90 alpha:1.0];
            }
        }
        
    } else {
        [self.targetLabel setText: [NSString stringWithFormat: @"%@ %@ %@ (No Target)", ni.name, [Formatter formatAmount: amount], ni.unit]];
    }
    if (ni.pId != 0) {
        //        int numParents = [self getNumParents: ni];
        //        CGRect childRect = CGRectInset(self.targetBar.bounds, 10*numParents, 0);
    }
}
-(void)setTarget:(Target*) target forNutrient: (NutrientInfo*) ni amount:(double)amount {
    self.target = target;
    self.ni = ni;
    self.amount = @(amount);
    
    self.targetBar1.layer.cornerRadius = 5;
    self.targetBar1.layer.masksToBounds = YES;
    self.redBar.hidden = YES;
    self.greenBar.hidden = YES;
    self.yellowBar.hidden = YES;
    
    if ([target min] != nil) {
        double tMin = [[target min] doubleValue];
        long percent = 0;
        if (tMin != 0) {
            percent = round(100 * amount / tMin);
        } else {
            if (amount >= 0.01) {
                percent = 100;
            } else {
                amount = 0;
            }
        }
//        self.targetBar.curValue = amount;
//        self.targetBar.maxValue = tMin;
        [self.targetLabel setText: [NSString stringWithFormat: @"%@ %@ / %@ %@ (%ld%%)", ni.name, [Formatter formatAmount: amount], [Formatter formatAmount: tMin], ni.unit, percent]];
        
        if (tMin <= amount) {
            self.yellowBar.hidden = YES;
            self.greenBar.hidden = NO;
            self.redBar.hidden = YES;
        } else {
            self.yellowBar.hidden = NO;
            self.greenBar.hidden = YES;
            self.redBar.hidden = YES;
            CGRect rect = self.yellowBar.frame;
            rect.size.width = amount/tMin * self.targetBar1.frame.size.width;
            self.yellowBar.frame = rect;
        }
        if ([target max] != nil) {
            if (amount >= 0.01 && amount > [[target max] doubleValue]) {
                self.yellowBar.hidden = YES;
                self.greenBar.hidden = YES;
                self.redBar.hidden = NO;
//                self.targetBar.barCol = [UIColor colorWithHue: 0.025 saturation:0.99 brightness:0.90 alpha:1.0];
            }
        }
        
    } else {
        [self.targetLabel setText: [NSString stringWithFormat: @"%@ %@ %@ (No Target)", ni.name, [Formatter formatAmount: amount], ni.unit]];
    }
    if (ni.pId != 0) {
//        int numParents = [self getNumParents: ni];
//        CGRect childRect = CGRectInset(self.targetBar.bounds, 10*numParents, 0);
    }
    [self setNeedsDisplay];
}

//-(void)setTarget:(Target*) target forNutrient: (NutrientInfo*) ni amount:(double)amount {
////    [self.label setText: [NSString stringWithFormat: @"%@: %@ %@ (%d%%)", @"---", [Formatter formatAmount: amount], @"unit", 77]];
////    dispatch_async(dispatch_get_main_queue(), ^{
////        self.targetBar.label = [NSString stringWithFormat: @"%@: %@ %@ (%d%%)", @"---", [Formatter formatAmount: amount], @"unit", 77];
////        [self.targetBar setNeedsDisplay];
////        
////        
////    });
////    return;
//   if ([target min] != nil) {
//      double tMin = [[target min] doubleValue];
//      long percent = 0;
//      if (tMin != 0) {
//         percent = round(100 * amount / tMin);         
//      } else {
//         if (amount >= 0.01) {
//            percent = 100;
//         } else {
//            amount = 0;
//         }
//      }
//       self.targetBar.curValue = amount;
//       self.targetBar.maxValue = tMin;
//      self.targetBar.label = [NSString stringWithFormat: @"%@: %@ %@ (%ld%%)", ni.name, [Formatter formatAmount: amount], ni.unit, percent];
//      
//      if ([target max] != nil) {
//         if (amount >= 0.01 && amount > [[target max] doubleValue]) {
//            self.targetBar.barCol = [UIColor colorWithHue: 0.025 saturation:0.99 brightness:0.90 alpha:1.0];  
//         }
//      }      
//      
//   } else {
//      self.targetBar.label = [NSString stringWithFormat: @"%@: %@ %@ (No Target)", ni.name, [Formatter formatAmount: amount], ni.unit];  
//   }
//   if (ni.pId != 0) {
//      int numParents = [self getNumParents: ni];
//      CGRect childRect = CGRectInset(self.targetBar.bounds, 10*numParents, 0); 
//      self.targetBar.bounds = childRect;
//   }
//    [self.targetBar setNeedsDisplay];
//}



@end
