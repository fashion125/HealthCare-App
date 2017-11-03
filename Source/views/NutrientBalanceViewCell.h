//
//  NutrientBalanceViewCell.h
//  Cronometer
//
//  Created by Alex Sun on 12/19/15.
//  Copyright © 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterCircleView.h"

@interface NutrientBalanceViewCell : UITableViewCell {
    NSMutableDictionary *amounts;
}

@property (weak, nonatomic) IBOutlet UIView *meterView0;
@property (weak, nonatomic) IBOutlet MeterCircleView *meterCaseView0;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel0;

@property (weak, nonatomic) IBOutlet UIView *meterView1;
@property (weak, nonatomic) IBOutlet MeterCircleView *meterCaseView1;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel1;

@property (weak, nonatomic) IBOutlet UIView *meterView2;
@property (weak, nonatomic) IBOutlet MeterCircleView *meterCaseView2;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel2;

@property (weak, nonatomic) IBOutlet UIView *meterView3;
@property (weak, nonatomic) IBOutlet MeterCircleView *meterCaseView3;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel3;

@property (weak, nonatomic) IBOutlet UIView *meterView4;
@property (weak, nonatomic) IBOutlet MeterCircleView *meterCaseView4;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel4;

- (void) setValuesWithAmount: (NSMutableDictionary*) dictAmounts;
@end
