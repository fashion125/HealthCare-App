//
//  AddExerciseViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Activity.h"
#import "Exercise.h"
#import "ActivitySearchViewController.h"

@interface AddExerciseViewController : UIViewController <UITextFieldDelegate> {
    DiaryViewController *__unsafe_unretained diaryVC;
   Exercise *exercise;
   UIBarButtonItem *saveButton;
   UILabel *exerciseName;
   UITextField *amount;
   UISlider *amountSlider;
   UILabel *calories; 
}


@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (strong) Exercise *exercise;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIView *dlgView;

@property (nonatomic, strong) IBOutlet UILabel *exerciseName;
@property (nonatomic, strong) IBOutlet UITextField *amount;
@property (nonatomic, strong) IBOutlet UISlider *amountSlider;
@property (nonatomic, strong) IBOutlet UILabel *calories;  
@property (strong, nonatomic) IBOutlet UILabel *weightLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;


- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (void) updateValues;
- (void) activity: (Activity *) activity;
- (void) initExercise;
@end
