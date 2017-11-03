//
//  EditNutrientViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 2014-07-19.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NutrientInfo.h"
#import "Food.h"

@interface EditNutrientViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *amountBox;
@property (strong, nonatomic) IBOutlet UITextField *dvBox;
@property (strong, nonatomic) IBOutlet UILabel *unitLabel;
@property (strong, nonatomic) IBOutlet UILabel *dvLabel;

//@property (nonatomic, strong) Food *food;
@property (nonatomic, strong) NutrientInfo *nutrient;
@property (nonatomic, strong) NSMutableDictionary* dictAmounts;

@end
