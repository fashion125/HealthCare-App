//
//  DiaryOptsViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 31/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "DiaryOptsViewController.h"

@implementation DiaryOptsViewController

@synthesize datePicker;  
@synthesize diary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) updateTitle {
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];       
   [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  // self.navBar.topItem.title =  [dateFormatter stringFromDate: [datePicker date]]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker.date = [diary.currentDay convertToDate];
    [self updateTitle];
}

- (void)viewDidUnload {
   [self setDatePicker:nil];   
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)changeDay:(id)sender {
   [diary loadDay: [Day dayFromDate: [datePicker date]]];
   [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)logout:(id)sender {   
   [self.navigationController popToRootViewControllerAnimated: YES];
   [diary logout];
}

- (IBAction)cancel:(id)sender {
   [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)today:(id)sender {
   [datePicker setDate: [NSDate date]];
   [self updateTitle];
}

- (IBAction)dateChanged:(id)sender {
    [self updateTitle];
}

@end
