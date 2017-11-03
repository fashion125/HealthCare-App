//
//  SplashViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 30/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "SplashViewController.h"

#import "CronometerAppDelegate.h"
#import "LoginViewController.h"
#import "WebQuery.h"

@interface SplashViewController()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SplashViewController 
@synthesize spinner;

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

- (void)onLoginDone {
    [LoginViewController showPostLoginView:self.navigationController];
}

- (void)showLoginView {
    [self performSegueWithIdentifier:@"SSID_SplashToLogin" sender:self];
}

// execute this after a login attempt to transition to correct view
- (void) postLoginAttempt {
   dispatch_async(dispatch_get_main_queue(), ^{ 
      [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLongLong:[[WebQuery singleton] sessionKey] ] forKey:@"authkey"]; 
      [[NSUserDefaults standardUserDefaults] synchronize];
      if ([[WebQuery singleton] isLoggedIn]) {
         [self onLoginDone];         
      } else {
         [self showLoginView];
      }
   });
}

- (void) relogin {   
   long userId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] longValue]; 
   long long authKey = [[[NSUserDefaults standardUserDefaults] objectForKey:@"authkey"] longLongValue];
   
   if (userId != 0 && authKey != 0) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [[WebQuery singleton] relogin: authKey user: userId];
         [self postLoginAttempt];
      });
   } else {
      if (![self facebookLogin]) {  
         dispatch_async(dispatch_get_main_queue(), ^{ 
            [self showLoginView];
         });
      }
   }
}

- (BOOL) facebookLogin {
   if (FBSession.activeSession.isOpen) {
      NSString *token = FBSession.activeSession.accessTokenData.accessToken;
      // Submit token to web
      NSLog(@"Facebook=%@", token);
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [[WebQuery singleton] facebookLogin: token];
         [self postLoginAttempt];
      });
      
      return TRUE;
   } 
   return FALSE;
}


-(void) onLogout {
   [self showLoginView];
}

#pragma mark - View lifecycle


-(void)viewDidAppear: (BOOL)animated {
   [super viewDidAppear: animated];
   [self relogin];
    
    sleep(1); //show version number
}

- (void)viewDidLoad {
   [super viewDidLoad];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    

}

- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
