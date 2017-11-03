//
//  HealthKitPermissionViewController.m
//  Cronometer
//
//  Created by Frank Mao on 2014-11-20.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import "HealthKitPermissionViewController.h"

@interface HealthKitPermissionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *promptTextView;

@end

@implementation HealthKitPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.isPostLoginMode) {
        
        
        self.titleLabel.text = @"Health App Hint";
        
        UIFont * font = [UIFont fontWithName:@"Avenir Medium" size:17];
        NSDictionary * attrsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    font,NSFontAttributeName,
                                    [UIColor colorWithRed:57/255.0f
                                                    green:145/255.0f
                                                     blue:217/255.0f
                                                    alpha:1.0f],NSForegroundColorAttributeName,
                                                                          nil ];
        NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:@"Cronometer can now export your health data to Apple's Health App! Tap the Actions button in the lower right to set the data you'd like to share with the Health App. \n\nNote that Cronometer will only share the most recent data. Exporting historic data will be part of a future release. \n\nThanks for using Cronometer!"
                                                                          attributes:attrsDict];
        self.promptTextView.attributedText = attrString;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onOK:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
