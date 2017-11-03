//
//  SetTargetsViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 31/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "SetTargetsViewController.h"
#import "SetGenderViewController.h"
#import "Utils.h"

@implementation SetTargetsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 
- (void) viewWillAppear:(BOOL)animated {
   [super viewWillAppear: animated];
   [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)start:(id)sender {
//   SetGenderViewController *vc = [[SetGenderViewController alloc] initWithNibName:@"SetGenderView" bundle:[NSBundle mainBundle]];
    SetGenderViewController* genderVC = (SetGenderViewController*)[Utils newViewControllerWithId:@"setGenderVC"];
    genderVC.diaryVC = self.diaryVC;

   [self.navigationController pushViewController:genderVC animated:YES];
}

@end
