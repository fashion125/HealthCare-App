//
//  AddBiometricViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiaryViewController.h"
#import "Biometric.h"

@interface AddBiometricViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (strong) NSArray *metrics;
@property (strong) Biometric *biometric;
@property (readwrite) long metricSelectedIndex;
@property (nonatomic, strong) IBOutlet UITextField *amount;
@property (strong, nonatomic) IBOutlet UIButton *measureButton;
@property (nonatomic, strong) IBOutlet UIPickerView *metricPicker;
@property (strong, nonatomic) IBOutlet UIView *dlgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)initBiometric ;

@end
 
