//
//  EditNutrientViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 2014-07-19.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import "EditNutrientViewController.h"
#import "Formatter.h"

@interface EditNutrientViewController ()

@end

@implementation EditNutrientViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title =  self.nutrient.name;
    self.unitLabel.text = self.nutrient.unit;
    double val = [self.dictAmounts[@(self.nutrient.nId)] doubleValue];//[self.food nutrientAmount: self.nutrient.nId];
    if (val != 0) {
       self.amountBox.text = [Formatter formatAmount: val];
       [self setDVFromAmount: val];
    }
    if (self.nutrient.rdi == 0) {
       self.dvBox.hidden = YES;
       self.dvLabel.hidden = YES; 
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSave:)];
}

- (IBAction)onCancel:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender {
    
    if (nil != self.amountBox && ![self.amountBox.text isEqualToString:@""] ) {
        [self setAmount:self.amountBox.text save: YES];
    } else if (nil != self.dvBox && ![self.dvBox.text isEqualToString:@""]) {
        [self setDV:self.dvBox.text save: YES];
    } else {
        
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
   [self.amountBox becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   [textField resignFirstResponder];
   if (textField == self.amountBox) {
       [self setAmount:self.amountBox.text save: NO];
   } else if (textField == self.dvBox) {
       [self setDV:self.dvBox.text save: NO];
   }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
   if (textField == self.amountBox) {
       [self setAmount:str save: NO];
   } else if (textField == self.dvBox) {
       [self setDV:str save: NO];
   }
   return YES;
}

- (void)setDVFromAmount: (double)val {
   if (self.nutrient.rdi != 0) {
      self.dvBox.text = [Formatter formatAmount: 100 * val / self.nutrient.rdi];
      self.dvBox.textColor = [UIColor blackColor];
   }
}

- (void)setAmountFromDV: (double)val {
   self.amountBox.text = [Formatter formatAmount: self.nutrient.rdi * val / 100.0];
   self.amountBox.textColor = [UIColor blackColor];
}

- (void)setAmount:(NSString *)str save:(BOOL) save{
   NSNumber *val = [Formatter numberFromString:str];
   if (val) {
      [self setDVFromAmount: [val doubleValue]];
      self.amountBox.textColor = [UIColor blackColor];
      [self.navigationItem.leftBarButtonItem setEnabled:TRUE];
       if (save) {
           self.dictAmounts[@(self.nutrient.nId)] = val;//[self.food setNutrient:self.nutrient.nId toAmount:[val doubleValue]];
       }
   } else {
      [self.navigationItem.leftBarButtonItem setEnabled:FALSE];
      self.amountBox.textColor = [UIColor redColor];
   }
}

- (void)setDV:(NSString *)str save:(BOOL) save{
   NSNumber *val = [Formatter numberFromString:str];
   if (val) {
      [self setAmountFromDV: [val doubleValue]];
      self.dvBox.textColor = [UIColor blackColor];
      [self.navigationItem.leftBarButtonItem setEnabled:TRUE];
      double amount = self.nutrient.rdi * [val doubleValue] / 100.0;
       if (save) {
           self.dictAmounts[@(self.nutrient.nId)] = @(amount);//[self.food setNutrient:self.nutrient.nId toAmount: amount];
       }
   } else {
      [self.navigationItem.leftBarButtonItem setEnabled:FALSE];
      self.dvBox.textColor = [UIColor redColor];
   }
}

@end
