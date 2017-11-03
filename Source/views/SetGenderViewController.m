//
//  SetGenderViewController
//  Cronometer
//
//  Created by Boris Esanu on 31/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "SetGenderViewController.h"
#import "WebQuery.h"
#import "SetHeightViewController.h"
#import "HealthKitService.h"
#import "Utils.h"

@implementation SetGenderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[HealthKitService sharedInstance] isServiceAccessible]) {
        
        HKBiologicalSex   gender = [[HealthKitService sharedInstance] getUsersGender];
        
        switch (gender) {
            case HKBiologicalSexNotSet:
                
                break;
            case HKBiologicalSexMale:
                [self male:nil];
                break;
                
            case HKBiologicalSexFemale:
                self.maleButton.enabled = NO;
                
            default:
                break;
        }
    }
    if (self.diaryVC != nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
    
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popToViewController:(UIViewController*)self.diaryVC animated:YES];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
    
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)male:(id)sender{
   [[WebQuery singleton] setPref:@"gender" withValue:@"Male"];
   [[WebQuery singleton] setPref:@"status" withValue:@"Normal"];
   [self showNext];
}

- (IBAction)female:(id)sender{
   [[WebQuery singleton] setPref:@"gender" withValue:@"Female"];
   [[WebQuery singleton] setPref:@"status" withValue:@"Normal"];
   [self showNext];
}

- (IBAction)femalePreggers:(id)sender{
   [[WebQuery singleton] setPref:@"gender" withValue:@"Female"];
   [[WebQuery singleton] setPref:@"status" withValue:@"Pregnant"];
   [self showNext];
}

- (IBAction)femaleMilky:(id)sender{   
   [[WebQuery singleton] setPref:@"gender" withValue:@"Female"];
   [[WebQuery singleton] setPref:@"status" withValue:@"Lactating"];
   [self showNext];
}


- (void) showNext {
    SetHeightViewController* setHeightVC = (SetHeightViewController*)[Utils newViewControllerWithId:@"setHeightVC"];
    setHeightVC.diaryVC = self.diaryVC;
   [self.navigationController pushViewController:setHeightVC animated:YES];
}

@end
