//
//  NutrientTargetViewCell.m
//  Cronometer
//
//  Created by choe on 8/1/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "NutrientTargetViewCell.h"
#import "DiaryEntry.h"

@implementation NutrientTargetViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTargets : (NSArray*) diaryEntries {
    double total = 0;
    double value = 0;
    double result = 0;
    
    NSMutableDictionary *nutrients = [NSMutableDictionary dictionary];
    
    for (DiaryEntry *entry in diaryEntries) {
        if (entry && [entry isKindOfClass: [Serving class]]) {
            Serving *serving = (Serving *)entry;
            for (Target *t in [[WebQuery singleton] getTargets]) {
                NSNumber *key = [NSNumber numberWithLong: t.nutrientId];
                NSNumber *val = [nutrients objectForKey: key];
                if (val) {
                    val = [NSNumber numberWithDouble: ([val doubleValue] + [serving nutrientAmount: t.nutrientId])];
                } else {
                    val = [NSNumber numberWithDouble: [serving nutrientAmount: t.nutrientId]];
                }
                [nutrients setObject:val forKey:key];
            }
        }
    }
    for (Target *t in [[WebQuery singleton] getTargets]) {
        if (t.visible && t.min != nil && [t.min doubleValue] > 0) {
            NSNumber *key = [NSNumber numberWithLong: t.nutrientId];
            NSNumber *amount = [nutrients objectForKey: key];
            if (amount != nil) {
                if ([amount doubleValue] < [t.min doubleValue]) {
                    value += [amount doubleValue] / [t.min doubleValue];
                } else {
                    value++;
                }
            }
            total++;
        }
        result = value / total;
    }
    result = round(100*result);
    
    self.kaProgress0.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress0.progressColor = [UIColor purpleColor];
    self.kaProgress0.trackWidth = 7;//14;
    self.kaProgress0.progressWidth = 5;
    
    self.kaProgress1.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress1.progressColor = [UIColor purpleColor];
    self.kaProgress1.trackWidth = 7;//14;
    self.kaProgress1.progressWidth = 5;
    
    self.kaProgress2.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress2.progressColor = [UIColor purpleColor];
    self.kaProgress2.trackWidth = 7;//14;
    self.kaProgress2.progressWidth = 5;
    
    self.kaProgress3.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress3.progressColor = [UIColor purpleColor];
    self.kaProgress3.trackWidth = 7;//14;
    self.kaProgress3.progressWidth = 5;
    
    self.kaProgress4.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress4.progressColor = [UIColor purpleColor];
    self.kaProgress4.trackWidth = 7;//14;
    self.kaProgress4.progressWidth = 5;
    
    self.kaProgress5.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress5.progressColor = [UIColor purpleColor];
    self.kaProgress5.trackWidth = 7;//14;
    self.kaProgress5.progressWidth = 5;
    
    self.kaProgress6.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress6.progressColor = [UIColor purpleColor];
    self.kaProgress6.trackWidth = 7;//14;
    self.kaProgress6.progressWidth = 5;
    
    self.kaProgress7.trackColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue: 244/255.0 alpha:1.0];
    self.kaProgress7.progressColor = [UIColor purpleColor];
    self.kaProgress7.trackWidth = 7;//14;
    self.kaProgress7.progressWidth = 5;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.kaProgress0.progress = value/total;
        [self.percentLabel0 setText: [NSString stringWithFormat:@"%.0f%%", result]];
        [self.targetLabel0 setText: @"Targets"];
        
        [self setNutrientTargets:0 nutrients:nutrients KA:self.kaProgress1 percentLabel:self.percentLabel1 targetLabel:self.targetLabel1];
        [self setNutrientTargets:1 nutrients:nutrients KA:self.kaProgress2 percentLabel:self.percentLabel2 targetLabel:self.targetLabel2];
        [self setNutrientTargets:2 nutrients:nutrients KA:self.kaProgress3 percentLabel:self.percentLabel3 targetLabel:self.targetLabel3];
        [self setNutrientTargets:3 nutrients:nutrients KA:self.kaProgress4 percentLabel:self.percentLabel4 targetLabel:self.targetLabel4];
        [self setNutrientTargets:4 nutrients:nutrients KA:self.kaProgress5 percentLabel:self.percentLabel5 targetLabel:self.targetLabel5];
        [self setNutrientTargets:5 nutrients:nutrients KA:self.kaProgress6 percentLabel:self.percentLabel6 targetLabel:self.targetLabel6];
        [self setNutrientTargets:6 nutrients:nutrients KA:self.kaProgress7 percentLabel:self.percentLabel7 targetLabel:self.targetLabel7];
    });
}
- (void) setNutrientTargets: (int) index nutrients: (NSMutableDictionary*) nutrients KA: (KAProgressLabel*) kap percentLabel: (UILabel*) percentLabel targetLabel: (UILabel*) targetLabel {
    
    int defaults[7] = {291,303,301,318,401,418,417};
    NSString* pref_prefix = [NSString stringWithFormat:@PREF_PREFIX"%d", index];
    NSInteger nId = [[WebQuery singleton] getIntPref: pref_prefix defaultTo:defaults[index]];
    NutrientInfo* ni = [[WebQuery singleton] nutrient: nId];
    Target* target = [[WebQuery singleton] target: nId];
    if (target.visible && target.min != nil && [target.min doubleValue] > 0) {
        NSNumber *key = [NSNumber numberWithLong: target.nutrientId];
        NSNumber *amount = [nutrients objectForKey: key];
        double amountv;
        if (amount != nil) {
            amountv = [amount doubleValue];
        } else {
            amountv = 0;
        }
        double percent = amountv*100.0 / [target.min doubleValue];
        if (target.max != nil && amountv > [target.max doubleValue]) {
            kap.progressColor = [UIColor colorWithRed:240/255.0 green:81/255.0 blue: 85/255.0 alpha:1.0];
        } else if ([target.min doubleValue] > amountv){
            kap.progressColor = [UIColor colorWithRed:248/255.0 green:199/255.0 blue: 85/255.0 alpha:1.0];
        } else {
            kap.progressColor = [UIColor colorWithRed:39/255.0 green:174/255.0 blue: 97/255.0 alpha:1.0];
        }
        kap.progress = percent/100.0;
        [percentLabel setText: [NSString stringWithFormat:@"%.0f%%", percent]];
        [targetLabel setText: [ni shortName]];
        
    } else {
        kap.progress = 0.0;
        [percentLabel setText: @"n/a"];
        [targetLabel setText: [ni shortName]];
        
    }
    
    

}
@end
