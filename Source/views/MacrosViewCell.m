//
//  MacrosViewCell.m
//  Cronometer
//
//  Created by choe on 8/1/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "MacrosViewCell.h"
#import "Formatter.h"

@implementation MacrosViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setMacrosWithProtein: (double) p pg: (double) pg Carbs: (double) c cg: (double) cg Lipids: (double) f fg: (double)fg Alcohol: (double) a ag: (double) ag {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

    } else {
        self.labelWidth.constant =  self.labelWidth.constant * 3/2;
        self.pieChartHeight.constant = self.pieChartHeight.constant * 3/2;
        self.pieChartWidth.constant = self.pieChartWidth.constant * 3/2;
    }
    [self.pieChart clearSlices];
    [self.pieChart addSlice: p color: [PieChart greenColor]];
    [self.pieChart addSlice: c color: [PieChart blueColor]];
    [self.pieChart addSlice: f color: [PieChart redColor]];
    [self.pieChart addSlice: a color: [UIColor yellowColor ] ];
    
    self.energyBar.layer.cornerRadius = 5;
    self.energyBar.layer.masksToBounds = YES;
    self.proteinBar.layer.cornerRadius = 5;
    self.proteinBar.layer.masksToBounds = YES;
    self.carbsBar.layer.cornerRadius = 5;
    self.carbsBar.layer.masksToBounds = YES;
    self.fatBar.layer.cornerRadius = 5;
    self.fatBar.layer.masksToBounds = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTarget: self.energyBar barPercent: self.energyVal labelView:self.energyLabel nId:CALORIES amount:p+c+f+a];
        [self setTarget: self.proteinBar barPercent: self.proteinVal labelView:self.proteinLabel nId:PROTEIN amount:pg];
        [self setTarget: self.carbsBar barPercent: self.carbsVal labelView:self.carbsLabel nId:NET_CARBS amount: cg];
        [self setTarget: self.fatBar barPercent: self.fatVal labelView:self.fatLabel nId:LIPIDS amount: fg];
    });
    
}
- (double) targetMin: (long) nId {
    NSArray *arr = @[
                     @{@"desc": @"Default (Fixed Targets)", @"protein": @(0), @"carbs": @(0), @"fat": @(0)},
                     @{@"desc": @"Even", @"protein": @(1), @"carbs": @(1), @"fat": @(1)},
                     @{@"desc": @"Zone Diet", @"protein": @(3), @"carbs": @(4), @"fat": @(3)},
                     @{@"desc": @"Paleo Diet", @"protein": @(15), @"carbs": @(20), @"fat": @(65)},
                     @{@"desc": @"LFRV / 30bananasaday.com", @"protein": @(1), @"carbs": @(8), @"fat": @(1)},
                     @{@"desc": @"Low Carb Ketogenic", @"protein": @(5), @"carbs": @(1), @"fat": @(5)},
                     @{@"desc": @"Custom", @"protein": @(0), @"carbs": @(0), @"fat": @(0)},
                     ];
    
    NSMutableArray* dietProfiles = [NSMutableArray arrayWithArray:arr];
    int dietProfileIndex = (int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_INDEX_KEY defaultTo: 0];
    double dietProfileProtein = 0;//(int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_PROTEIN_KEY defaultTo: 0 ];
    double dietProfileCarb = 0;//(int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_CARBS_KEY defaultTo: 0 ];
    double dietProfileFat = 0;//(int)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_LIPIDS_KEY defaultTo: 0 ];
    Target* calories = [[WebQuery singleton] target: CALORIES];
    
    if (dietProfileIndex != 0 && calories != nil && calories.min != nil) {
        if (dietProfileIndex != [dietProfiles count]-1) {
            NSDictionary* dict = (NSDictionary*)[dietProfiles objectAtIndex: dietProfileIndex];
            dietProfileCarb = [((NSNumber*)dict[@"carbs"]) doubleValue];
            dietProfileFat = [(NSNumber*)dict[@"fat"] doubleValue];
            dietProfileProtein = [(NSNumber*)dict[@"protein"] doubleValue];
        } else {
            dietProfileProtein = (double)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_PROTEIN_KEY defaultTo: 0 ];
            dietProfileCarb = (double)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_CARBS_KEY defaultTo: 0 ];
            dietProfileFat = (double)[[WebQuery singleton] getIntPref: @USER_PREF_MACRO_LIPIDS_KEY defaultTo: 0 ];
        }
        double total = dietProfileProtein + dietProfileCarb + dietProfileFat;
        if (total > 0) {
            if (nId == PROTEIN) {
                return ((dietProfileProtein / total) * [calories.min doubleValue]) / 4.0;
            } else if (nId == NET_CARBS || nId == CARBOHYDRATES) {
                return ((dietProfileCarb / total) * [calories.min doubleValue]) / 4.0;
            } else if (nId == LIPIDS) {
                return ((dietProfileFat / total) * [calories.min doubleValue]) / 9.0;
            }
        }
    }
    Target* t = [[WebQuery singleton] target: nId];
    if (t != nil) {
        return t.min != nil ? [t.min doubleValue] : 0;
    }
    return 0;
}
-(void)setTarget: (UIView*) bar barPercent: (NSLayoutConstraint*) nsc labelView: (UILabel*) label nId: (long)nId amount:(double)a
{
    NutrientInfo* ni = [[WebQuery singleton] nutrient: nId];
//    Target* target = [[WebQuery singleton] target: nId];
    double amount = a;
    
    if (ni != nil) {
        double t = [self targetMin: (int)nId];
        if (t > 0) {
            double percent = 100.0 * amount / t;
            [label setText: [NSString stringWithFormat: @"%@: %@ %@ / %@ %@ (%ld%%)", ni.name, [Formatter formatAmount: amount], ni.unit, [Formatter formatAmount: t], ni.unit, (long)round(percent)]];
            nsc.constant = [bar bounds].size.width * MIN(1, amount / t);
        } else {
            [label setText: [NSString stringWithFormat: @"%@: %@ %@ (No Target)", ni.name, [Formatter formatAmount: amount], ni.unit] ];
            nsc.constant = 0;
        }
    } else {
        [label setText: [NSString stringWithFormat: @"%@ %@ (No Target)", /*ni.name, */[Formatter formatAmount: amount], ni.unit] ];
        nsc.constant = 0;
    }
//    if ([target min] != nil) {
//        double tMin = [[target min] doubleValue];
//        long percent = 0;
//        if (tMin != 0) {
//            percent = round(100 * amount / tMin);
//        } else {
//            if (amount >= 0.01) {
//                percent = 100;
//            } else {
//                amount = 0;
//            }
//        }
////        self.targetBar.curValue = amount;
////        self.targetBar.maxValue = tMin;
//        [label setText: [NSString stringWithFormat: @"%@: %@ %@ / %@ %@ (%ld%%)", ni.name, [Formatter formatAmount: amount], ni.unit, [Formatter formatAmount: tMin], ni.unit, percent]];
//
//        nsc.constant = [bar bounds].size.width * (double)percent / 100.0;
//        
////        if ([target max] != nil) {
////            if (amount >= 0.01 && amount > [[target max] doubleValue]) {
////                self.targetBar.barCol = [UIColor colorWithHue: 0.025 saturation:0.99 brightness:0.90 alpha:1.0];
////            }
////        }
//        
//    } else {
//        [label setText: [NSString stringWithFormat: @"%@: %@ %@ (No Target)", ni.name, [Formatter formatAmount: amount], ni.unit] ];
//        nsc.constant = 0;
//    }
//    if (ni.pId != 0) {
//        int numParents = [self getNumParents: ni];
//        CGRect childRect = CGRectInset(self.targetBar.bounds, 10*numParents, 0);
//        self.targetBar.bounds = childRect;
//    }
}

@end
