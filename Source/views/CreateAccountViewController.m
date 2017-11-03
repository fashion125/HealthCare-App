
//
//  CreateAccountViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 31/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "LoginViewController.h"
#import "SetTargetsViewController.h"
#import "Toolbox.h"
#import "WebQuery.h"
#import "HealthKitService.h"

@interface CreateAccountViewController()
@property (weak, nonatomic) IBOutlet UIButton *connectToHealthKitButton;

@end

@implementation CreateAccountViewController

@synthesize password;
@synthesize confirmField;
@synthesize email;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.scrollView.frame = self.view.frame;
    self.scrollView.contentSize = [UIScreen mainScreen].bounds.size;
    
   self.title= @"Create Account";
   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    
    self.connectToHealthKitButton.hidden = ![HKHealthStore isHealthDataAvailable];
        
    
}

- (void)viewDidUnload {
   [self setPassword:nil];
   [self setEmail:nil];
   [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (void) viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)doConnectToHealthKit:(id)sender {
    [[HealthKitService sharedInstance] setupPermission];
}

- (IBAction)doCreate:(id)sender {  
   [self resignFirstResponder];
    
   if (![self.password.text isEqualToString:self.password2.text]) {
      [Toolbox showMessage: [WebQuery singleton].lastError withTitle: @"Passwords don't match"];
      return;
   }
   
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[WebQuery singleton] createAccount:email.text password:password.text];
      dispatch_async(dispatch_get_main_queue(), ^{
         if ([[WebQuery singleton] isLoggedIn]) {
            [[NSUserDefaults standardUserDefaults] setObject: email.text forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject: password.text forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLong: [[WebQuery singleton] userId] ] forKey: @"uid"];
            [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLongLong:[[WebQuery singleton] sessionKey] ] forKey:@"authkey"];
            [[NSUserDefaults standardUserDefaults] synchronize];

             [LoginViewController showPostLoginView:self.navigationController];
         } else {
            [Toolbox showMessage: [WebQuery singleton].lastError withTitle: @"Account Creation Failed"];
         }
      });
   });

   
}

- (IBAction)cancel:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
   if (theTextField == email) {
      [theTextField resignFirstResponder];
   }
   if (theTextField == password) {
      [email becomeFirstResponder]; 
   }
   return YES;
}



@end
