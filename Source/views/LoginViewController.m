//
//  LoginViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 08/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "LoginViewController.h" 
#import "CronometerAppDelegate.h"
#import "LicenseAgreementViewController.h"
#import "CreateAccountViewController.h"  
#import "SetTargetsViewController.h"
#import "WebQuery.h"
#import "Toolbox.h"
#import "HealthKitService.h"
#import "HealthKitPermissionViewController.h"
#import "Utils.h"

@interface LoginViewController ()
@property (nonatomic, strong) NSString* webUrl;

@end

@implementation LoginViewController

@synthesize saveBox;
@synthesize username;
@synthesize loginButton;
@synthesize spinner;
@synthesize password;

static LoginViewController *sharedInstance = nil;

+ (LoginViewController *) singleton {
   return sharedInstance;
}  

 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       // Custom initialization        
    }
    sharedInstance = self;
    return self;
}

- (void)dealloc { 
   // sharedInstance = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
    sharedInstance = self;

    self.scrollView.frame = self.view.frame;
    self.scrollView.contentSize = [UIScreen mainScreen].bounds.size;
    
    [self.view addSubview:self.scrollView];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
   
   NSString *login = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];   
   if (login != nil) {
      [username setText: login]; 
   } 
   NSString *pwd = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];   
   if (pwd != nil) {
      [password setText: pwd]; 
   }
   [self.spinner setHidden:true];
}

- (void)viewDidUnload {
   [self setUsername:nil];
   [self setLoginButton:nil];
   [self setPassword:nil];
   [self setSpinner:nil];
   [self setSaveBox:nil]; 
   [super viewDidUnload]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
   if (theTextField == username) {
      [password becomeFirstResponder];
   }
   if (theTextField == password) {
       [self doLogin:nil]; 
      [password resignFirstResponder];
   }
   return YES;
}

- (IBAction)doFacebookLogin:(id)sender {
   if (!FBSession.activeSession.isOpen) {
      CronometerAppDelegate *appDelegate = (CronometerAppDelegate *)[[UIApplication sharedApplication] delegate];
      [appDelegate openSessionWithAllowLoginUI:YES];
   } else {
      NSString* token = FBSession.activeSession.accessTokenData.accessToken;
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [[WebQuery singleton] facebookLogin: token];
         dispatch_async(dispatch_get_main_queue(), ^{
            [self onLoginDone];
         });
      });
   }
}

- (IBAction)doGoogleLogin:(id)sender {
   [self doWebLogin:@"https://cronometer.com/login?op=Google&mobile_login=true"];
}

- (IBAction)doYahooLogin:(id)sender {
   [self doWebLogin:@"https://cronometer.com/login?op=Yahoo&mobile_login=true"];
}

- (void)doWebLogin:(NSString *)url {
   /*WebLoginViewController *webViewController = [[WebLoginViewController alloc] initWithNibName:@"WebLoginViewController" bundle:[NSBundle mainBundle]];
   [webViewController loadAuthenticateUrl:url delegate:self];
   [self.navigationController pushViewController:webViewController animated:YES];*/
    self.webUrl = url;
    [self performSegueWithIdentifier:@"SSID_LoginToWebLogin" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SSID_LoginToWebLogin"]) {
        WebLoginViewController *wvc = [segue destinationViewController];
        [wvc loadAuthenticateUrl: self.webUrl delegate: self];
        
    }
}
- (void)gotToken:(NSString *)token {
   NSLog(@"**************************************************************");
   NSLog(@"Got Token %@", token);
   NSArray *bits = [token componentsSeparatedByString: @"_"];
   if ([bits count] == 2) {
      unsigned long long userId;
      unsigned long long sessionKey;
      
      NSScanner *scanner = nil;
      
      scanner = [NSScanner scannerWithString:bits[0]];
      [scanner scanHexLongLong: &userId];
      
      scanner = [NSScanner scannerWithString:bits[1]];
      [scanner scanHexLongLong:&sessionKey];
      
      if (userId != 0 && sessionKey != 0) {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[WebQuery singleton] relogin: sessionKey user: (NSInteger)userId];
            dispatch_async(dispatch_get_main_queue(), ^{               
               [self onLoginDone];
            });
         });
      }
   }
}

- (void) viewWillAppear:(BOOL)animated {
   [self.navigationController setNavigationBarHidden:YES];
   [super viewWillAppear: animated];
}

 

- (IBAction)doLogin:(id)sender {
   [self.loginButton setEnabled: false];
   [self.spinner setHidden:false];
   [self.spinner startAnimating];
       
   NSString *login = username.text;
   NSString *pwd = password.text;
   
   [[NSUserDefaults standardUserDefaults] setObject: login forKey:@"username"];
   [[NSUserDefaults standardUserDefaults] setObject:   pwd forKey:@"password"]; 
       
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[WebQuery singleton] login: login password: pwd]; 
      dispatch_async(dispatch_get_main_queue(), ^{ 
         [self onLoginDone];
      });
   });
}

- (IBAction)createAccount:(id)sender {
//   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cronometer.com"]];
   /*CreateAccountViewController *vc = [[CreateAccountViewController alloc] initWithNibName:@"CreateAccountViewController" bundle:[NSBundle mainBundle]];
    
   [self.navigationController pushViewController:vc animated:YES];
    */
    return;
    
    
    // this is to test custom size view on ipad. on hold for now. waiting for designer new deisgn.
    /*vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    CGSize size = CGSizeMake(320, 480);


    
    [self.navigationController presentViewController:vc
                                            animated:YES completion:NULL];
    
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        vc.preferredContentSize = size;
    }else{
        CGPoint frameSize = CGPointMake(size.width, size.height);
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        vc.view.superview.frame = CGRectMake((screenWidth - size.width)/1, (screenHeight - frameSize.y)/1, size.width, frameSize.y);
        vc.view.superview.center = self.view.center;
    }*/

}

- (void)onLoginDone {
   [self.loginButton setEnabled: true];
   [self.spinner stopAnimating];   
   [self.spinner setHidden:true];
   if ([[WebQuery singleton] isLoggedIn]) {
      [LoginViewController showPostLoginView:self.navigationController];
       
       // skip this, the only 2 place to connect are 1. diary, 2. create new account.
//       if ([HKHealthStore isHealthDataAvailable]) {
//           
//           if ( [HealthKitService sharedInstance].healthStore != nil
//               && [HealthKitService sharedInstance].isServiceAccessible ) {
//
//           }else{
//               [[HealthKitService sharedInstance] setupPermissionWithCompletionBlock:^(BOOL success, NSError *error) {
//                   if (success) {
//                       
//                       dispatch_async(dispatch_get_main_queue(), ^{
//                           [self openHealthKitPermissionView];
//                       });
//                       
//                   }
//               }];
//               
//           }
//       }

       
   } else {
      [Toolbox showMessage: [WebQuery singleton].lastError withTitle: @"Login Failed"];
   }
}


- (void)openHealthKitPermissionView
{
    HealthKitPermissionViewController * vc = [[HealthKitPermissionViewController alloc] init];
    vc.isPostLoginMode = YES;
    
    [self presentViewController:vc animated:YES completion:NULL];
}

// normally show diary, but in some cases we need to show account setup stuff
+ (void) showPostLoginView:(UINavigationController *)navigationController {
   if ([[WebQuery singleton] isLoggedIn]) {
      if (![[WebQuery singleton] getBoolPref:@"l1" defaultTo:false]) {
          LicenseAgreementViewController *licenseVC = (LicenseAgreementViewController*)[Utils newViewControllerWithId:@"licenseAgreeVC"];
          [navigationController pushViewController:licenseVC animated:YES];
      } else {
         if ([[WebQuery singleton] needsAccountSetup]) {
            SetTargetsViewController *setTargetsVC = (SetTargetsViewController*)[Utils newViewControllerWithId:@"setTargetsVC"];
             setTargetsVC.diaryVC = nil;
            [navigationController pushViewController:setTargetsVC animated:YES];
         } else {
             UIViewController* diaryVC = [Utils newViewControllerWithId:@"diaryVC"];
             
            [navigationController pushViewController:diaryVC animated:YES];
         }
      }
   } else {
      [navigationController popToRootViewControllerAnimated:YES];
   }
}

- (void)doForgotPassword:(NSString*)emailAddress
{
 
    [self.forgotPasswordButton setEnabled: false];
    [self.spinner setHidden:false];
    [self.spinner startAnimating];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary* response = [[WebQuery singleton] resetPassword:emailAddress ];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([response[@"result"] isEqualToString:@"SUCCESS"]) {
                [self onForgotPasswordSuccess:emailAddress];
            }else{
                [self onForgotPasswordFail:response[@"error"]];
            }
        });
    });

    


    
 
}
- (void)onForgotPasswordSuccess:(NSString*)emailAddress {
    [self.forgotPasswordButton setEnabled: true];
    [self.spinner stopAnimating];
    [self.spinner setHidden:true];
    
    [Toolbox showMessage: [@"A password reset link has been emailed to " stringByAppendingString:emailAddress]
               withTitle: @"Message"];
    
}
- (void)onForgotPasswordFail:(NSString*)errorMessage {
    [self.forgotPasswordButton setEnabled: true];
    [self.spinner stopAnimating];
    [self.spinner setHidden:true];
    
    [Toolbox showMessage: errorMessage withTitle: @"Message"];
    
}
- (IBAction)popEmailInputAlertView:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Reset Password"
                                                     message:@"Enter the email associated with this account"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeEmailAddress;
    alertTextField.placeholder = @"Enter your email address";
    [alert show];
}


# pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
            UITextField * alertTextField = [alertView textFieldAtIndex:0];
        if (alertTextField.text.length == 0) {
            return;
        }else{
            // TODO: do email address validation
            [self doForgotPassword:alertTextField.text];
        }
    }
}


@end
