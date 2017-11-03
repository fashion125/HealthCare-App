//
//  EditTargetViewController.m
//  Cronometer
//
//  Created by Frank Mao on 2014-10-01.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import "EditTargetViewController.h"


@interface EditTargetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *minimumTextField;
@property (weak, nonatomic) IBOutlet UITextField *maximumTextField;
@property (weak, nonatomic) IBOutlet UILabel *nutrientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *unit1Label;
@property (weak, nonatomic) IBOutlet UILabel *unit2Label;
@end

@implementation EditTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Edit Target";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onApply:)];
    
    if (self.nutrientInfo) {
        self.nutrientNameLabel.text = self.nutrientInfo.name;
        self.unit1Label.text = self.unit2Label.text = self.nutrientInfo.unit;

    }
    
    if (self.targetToEdit && self.nutrientInfo) {
        self.minimumTextField.text = [NSString stringWithFormat:@"%.0f", self.targetToEdit.min.floatValue];
        
        self.maximumTextField.text = [NSString stringWithFormat:@"%.0f", self.targetToEdit.max.floatValue];
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onReset:(id)sender {
    Target * suggestTarget = [[WebQuery singleton] suggestTarget:self.targetToEdit.nutrientId];

    self.minimumTextField.text = [NSString stringWithFormat:@"%.0f", suggestTarget.min.floatValue];
    
    self.maximumTextField.text = [NSString stringWithFormat:@"%.0f", suggestTarget.max.floatValue];
    
}

- (IBAction)onCancel:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onApply:(id)sender {
    self.targetToEdit.min = [NSNumber numberWithFloat:[self.minimumTextField.text floatValue]];
    self.targetToEdit.max = [NSNumber numberWithFloat:[self.maximumTextField.text floatValue]];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL success = [[WebQuery singleton] editTarget:self.targetToEdit];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                
                //[self dismissViewControllerAnimated:YES completion:NULL];
                [self.navigationController popViewControllerAnimated:YES];
                [self.delegate onTargetEditSuccess];
                
            }else{
                
                [Toolbox showMessage:[WebQuery singleton].lastError withTitle:@"Error"];
            }
        });
    });

    

    
}
@end
