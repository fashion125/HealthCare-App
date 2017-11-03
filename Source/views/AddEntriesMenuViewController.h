//
//  AddEntriesMenuViewController.h
//  Cronometer
//
//  Created by choe on 11/6/15.
//  Copyright © 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEntriesMenuViewController : UIViewController

@property (strong, nonatomic) id bgVC;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *addFoodButton;
@property (strong, nonatomic) IBOutlet UIButton *addExerciseButton;
@property (strong, nonatomic) IBOutlet UIButton *addBiometricButton;
@property (strong, nonatomic) IBOutlet UIButton *addNoteButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addFoodButtonTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addExerciseButtonTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addBiometricButtonTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addNotesButtonTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rearrangeButtonTop;

@end
