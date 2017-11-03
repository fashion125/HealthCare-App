//
//  LoginViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 08/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiaryViewController.h"
#import "WebLoginViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, WebLoginDelegate>  {
    
   UITextField *username;
   UIButton *loginButton;
   UIActivityIndicatorView *spinner;
   UITextField *password;    
   UISwitch *saveBox;
}

+ (LoginViewController *) singleton;

+ (void)showPostLoginView:(UINavigationController *)navigationController;

- (IBAction)doFacebookLogin:(id)sender;
- (IBAction)doGoogleLogin:(id)sender;
- (IBAction)doYahooLogin:(id)sender;
- (IBAction)doLogin:(id)sender;
- (IBAction)createAccount:(id)sender;
- (void)onLoginDone;

@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UISwitch *saveBox;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end
