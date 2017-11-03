//
//  AddExerciseViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "AddExerciseViewController.h"

#import "WebQuery.h"
#import "Formatter.h"
#import "Utils.h"

@implementation AddExerciseViewController
@synthesize saveButton;
@synthesize exerciseName;
@synthesize amount;
@synthesize amountSlider;
@synthesize calories; 

@synthesize diaryVC, exercise;
 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.exercise = [[Exercise alloc] init];
       exercise.minutes = 15;
       exercise.weightInLbs = [[WebQuery singleton] weightInPounds];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) initExercise {
    if (self) {
        self.exercise = [[Exercise alloc] init];
        exercise.minutes = 15;
        exercise.weightInLbs = [[WebQuery singleton] weightInPounds];
    }
}
- (void) activity: (Activity *) activity {   
   exercise.aId = activity.aId;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    if (self.exercise.entryId != 0) {
      self.title= @"Edit Exercise";
        [self.btnSave setTitle: @"EDIT EXERCISE" forState:UIControlStateNormal];
   } else {
       self.title= @"Add Exercise";
       [self.btnSave setTitle: @"ADD EXERCISE" forState:UIControlStateNormal];
   }
   self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target:self action:@selector(save:)];
//   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];

   exerciseName.text = [exercise description];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.dlgView addGestureRecognizer: tap];
   [self updateValues];
    if ([Utils isIPhone6] || [Utils isIPhone6s] || [Utils isIPhone5] || [Utils isIPhone5s] || [Utils isIPad]) {
        [self.amount becomeFirstResponder];
    }
}
-(void)dismissKeyboard {
    [self.amount resignFirstResponder];
}
- (void)viewDidUnload {
   [self setExerciseName:nil];
   [self setAmount:nil];
   [self setAmountSlider:nil];
   [self setCalories:nil];    
   [self setSaveButton:nil];
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) updateValues: (BOOL)includeAmount {
   
   if (includeAmount) {  
      amount.placeholder = [Formatter formatAmount: round([exercise minutes])];
   } else {
       amount.placeholder = @"15";
   }
   calories.text = [NSString stringWithFormat: @"burns %@ calories", [Formatter formatAmount: -[exercise calories]]];
    if ([[WebQuery singleton] getPreferredWeightUnit] == 1) {
        self.weightLabel.text = [NSString stringWithFormat: @"Based on your current weight of %ld kg", (long)round([[WebQuery singleton] weightInKg])];
    } else {
        self.weightLabel.text = [NSString stringWithFormat: @"Based on your current weight of %ld lbs", (long)round([[WebQuery singleton] weightInPounds])];
    }
//   self.amount.textColor = [UIColor blackColor];
//   if (exercise.minutes > [amountSlider maximumValue]) {
//      [amountSlider setMaximumValue: exercise.minutes];
//   }
//   [amountSlider setValue: exercise.minutes ]; 
   [saveButton setEnabled:TRUE];
} 

- (void) updateValues {
   [self updateValues: TRUE];
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
   if (theTextField == amount) {        
      NSNumber *val = [Formatter numberFromString: amount.text];
      if (val) {
         [amount resignFirstResponder];
      } else {
         return NO;
      }
   } 
   return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField { 
   NSNumber *val = [Formatter numberFromString:textField.text];
   exercise.minutes = [val longValue];
   [self updateValues];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
   NSNumber *val = [Formatter numberFromString:str];
   if (val) {
      exercise.minutes = [val longValue]; 
      [self updateValues: FALSE];
   } else { 
      [saveButton setEnabled:FALSE];          
      self.amount.textColor = [UIColor redColor];
   }
   return YES;
}

- (IBAction) sliderValueChanged:(UISlider *)sender {  
   exercise.minutes =  5*(round([amountSlider value]/5));
   [self updateValues];
}  

- (IBAction)cancel:(id)sender {   
   [self.navigationController popViewControllerAnimated:YES]; 
}

- (IBAction)save:(id)sender {   
   [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
   
   if ([amount isFirstResponder]) {
      [amount resignFirstResponder];
   }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.btnSave.enabled = NO;
   
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      if (exercise.entryId == 0) {
         exercise.day = [diaryVC currentDay];
         [diaryVC setOrderForNewDiaryEntry: exercise];
         [[WebQuery singleton] addExercise: exercise];
         dispatch_async(dispatch_get_main_queue(), ^{         
            [self.diaryVC entryAdded: exercise];
             [self.navigationController popToViewController: self.diaryVC animated:YES];
             self.navigationItem.rightBarButtonItem.enabled = YES;
             self.btnSave.enabled = YES;
         });
      } else {
         [[WebQuery singleton] editExercise: exercise];
         dispatch_async(dispatch_get_main_queue(), ^{         
            [self.diaryVC entryChanged: exercise];
             [self.navigationController popToViewController: self.diaryVC animated:YES];
             self.navigationItem.rightBarButtonItem.enabled = YES;
             self.btnSave.enabled = YES;
         });
      }
   }); 
 }

@end
