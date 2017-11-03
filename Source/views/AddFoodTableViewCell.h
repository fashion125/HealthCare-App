//
//  AddFoodTableViewCell.h
//  Cronometer
//
//  Created by Boris Esanu on 2014-05-04.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NutrientInfo.h"
#import "Food.h"

@interface AddFoodTableViewCell : UITableViewCell

@property (readwrite) double amount;
@property (nonatomic, strong) NutrientInfo *ni;

@property (strong, nonatomic) IBOutlet UILabel *nameField;
@property (strong, nonatomic) IBOutlet UILabel *amountField;
@property (strong, nonatomic) IBOutlet UILabel *unitField;
@property (strong, nonatomic) IBOutlet UILabel *dvField;

- (void)setNutrient:(NutrientInfo *)ni andAmount:(double)amount;

@end
