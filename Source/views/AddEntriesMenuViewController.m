//
//  AddEntriesMenuViewController.m
//  Cronometer
//
//  Created by choe on 11/6/15.
//  Copyright © 2015 cronometer.com. All rights reserved.
//

#import "AddEntriesMenuViewController.h"
#import "AddEntriesMenuBgViewController.h"
#import "DiaryViewController.h"
#import "SWNinePatchImageFactory.h"
#import "Utils.h"

@interface AddEntriesMenuViewController ()

@end

@implementation AddEntriesMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIImage* resizableImage = [SWNinePatchImageFactory createResizableNinePatchImageNamed:@"add_diary_item_button_bg.9"];
//
//    [self.addFoodButton setBackgroundImage:resizableImage forState:UIControlStateNormal];
//    [self.addExerciseButton setBackgroundImage:resizableImage forState:UIControlStateNormal];
//    [self.addBiometricButton setBackgroundImage:resizableImage forState:UIControlStateNormal];
//    [self.addNoteButton setBackgroundImage:resizableImage forState:UIControlStateNormal];
//    [self.cancelButton setBackgroundImage:resizableImage forState:UIControlStateNormal];
    if ([Utils isIPhone4_or_less]) {
        self.addFoodButtonTop.constant = 45;
        self.cancelButtonBottom.constant = 75;
        self.addExerciseButtonTop.constant = 5;
        self.addBiometricButtonTop.constant = 5;
        self.addNotesButtonTop.constant = 5;
        self.rearrangeButtonTop.constant = 5;
    } else if ([Utils isIPhone6]) {
        self.addFoodButtonTop.constant = 120;
        self.cancelButtonBottom.constant = 120;
        
    } else if ([Utils isIPhone6s]) {
        self.addFoodButtonTop.constant = 140;
        self.cancelButtonBottom.constant = 140;
        
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
//        self.blurView.backgroundColor = [UIColor clearColor];
//        
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        blurEffectView.frame = self.blurView.bounds;
//        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        [self.blurView addSubview:blurEffectView];
//    }
//    else {
//        self.blurView.backgroundColor = [UIColor blackColor];
//    }
//    self.blurView.backgroundColor = [UIColor blackColor];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(id)sender {
    AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*)self.bgVC;
    [self dismissViewControllerAnimated:YES completion: ^ {
        [vc cancel];
    }];
}
- (IBAction)addServing:(id)sender {
    AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*)self.bgVC;
    [self dismissViewControllerAnimated:YES completion: ^ {
        [vc addServing];
    }];
}
- (IBAction)addExercise:(id)sender {
    AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*)self.bgVC;
    [self dismissViewControllerAnimated:YES completion: ^ {
        [vc addExercise];
    }];
}
- (IBAction)addBiometric:(id)sender {
    AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*)self.bgVC;
    [self dismissViewControllerAnimated:YES completion: ^ {
        [vc addBiometric];
    }];
}
- (IBAction)addNotes:(id)sender {
    AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*)self.bgVC;
    [self dismissViewControllerAnimated:YES completion: ^ {
        [vc addNotes];
    }];
}

- (IBAction)rearrangeEntries:(id)sender {
    AddEntriesMenuBgViewController* vc = (AddEntriesMenuBgViewController*)self.bgVC;
    [self dismissViewControllerAnimated:YES completion: ^ {
        [vc rearrangeEntries];
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
