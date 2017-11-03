//
//  NutrientBalanceViewCell.m
//  Cronometer
//
//  Created by Alex Sun on 12/19/15.
//  Copyright © 2015 cronometer.com. All rights reserved.
//

#import "NutrientBalanceViewCell.h"
#import "NutrientInfo.h"
#import "Formatter.h"

@implementation NutrientBalanceViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
}
- (double) amount: (long)nId {
    return [((NSNumber *)[amounts objectForKey:[NSNumber numberWithLong:nId]]) doubleValue];
}

- (NSString*) stringOfDoubleValue: (double) val {
    double val1 = round(val);
    if (val1 == val) {
        return [NSString stringWithFormat: @"%.0f", val];
    }
    return [NSString stringWithFormat: @"%.3f", val];
}
- (void) setValuesWithAmount: (NSMutableDictionary*) dictAmounts {
    amounts = dictAmounts;
    double omega6 = [self amount: OMEGA_6];
    double omega3 = [self amount: OMEGA_3];
    double value0 = 0;
    if (omega3 == 0) {
        value0 = 0;
        [self.valueLabel0 setText: @"n/a"];
    } else {
        value0 = omega6/omega3;
        [self.valueLabel0 setText:[self stringOfDoubleValue:value0]];
    }
    [self.meterCaseView0 setValuesWithMin: 0 max: 25 optimal: 1 current: value0];
    
    double zinc = [self amount: ZINC];
    double copper = [self amount: COPPER];
    double value1 = 0;
    if (copper == 0) {
        value1 = 0;
        [self.valueLabel1 setText: @"n/a"];
    } else {
        value1 = zinc/copper;
        [self.valueLabel1 setText:[self stringOfDoubleValue:value1]];
    }
    [self.meterCaseView1 setValuesWithMin: 0 max: 20 optimal: 10 current: value1];
    
    double potassium = [self amount: POTASSIUM];
    double sodium = [self amount: SODIUM];
    double value2 = 0;
    if (sodium == 0) {
        value2 = 0;
        [self.valueLabel2 setText: @"n/a"];
    } else {
        value2 = potassium / sodium;
        [self.valueLabel2 setText:[self stringOfDoubleValue:value2]];
    }
    [self.meterCaseView2 setValuesWithMin: 0 max: 6 optimal: 2 current: value2];
    
    double calcium = [self amount: CALCIUM];
    double magnesium = [self amount: MAGNESIUM];
    double value3 = 0;
    if (magnesium == 0) {
        value3 = 0;
        [self.valueLabel3 setText: @"n/a"];
    } else {
        value3 = calcium / magnesium;
        [self.valueLabel3 setText: [self stringOfDoubleValue: value3]];
    }
    [self.meterCaseView3 setValuesWithMin: 0 max: 6 optimal: 1.25 current: value3];
    
    double pral = [self amount: PROTEIN]*0.49 + [self amount: PHOSPHORUS]*0.037 - [self amount: POTASSIUM]*0.021 - [self amount: MAGNESIUM]*0.026 - [self amount: CALCIUM]*0.013;
    [self.valueLabel4 setText: [self stringOfDoubleValue: pral]];
    [self.meterCaseView4 setValuesWithMin: -30 max: 30 optimal: -25 current: pral];
}
@end
