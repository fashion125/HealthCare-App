//
//  LicenseAgreementViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 2014-03-03.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import "LicenseAgreementViewController.h"
#import "LoginViewController.h"
#import "WebQuery.h"

@implementation LicenseAgreementViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      // Custom initialization
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.navigationItem.title = @"License Agreement";
   [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void)viewDidUnload {
   self.webView.delegate = nil;
   [self setWebView:nil];
   [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated {
   [self.navigationController setNavigationBarHidden:NO];
   [super viewDidAppear: animated];
   
   self.webView.delegate = self;
   [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://cronometer.com/license.html"]]];
   self.agreeButton.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
   self.agreeButton.enabled = YES;
}


- (IBAction)agreeClicked:(id)sender {
   [self.navigationItem setHidesBackButton:NO animated:NO];
   [[WebQuery singleton] setPref:@"l1" withValue:@"true"];
    [LoginViewController showPostLoginView: self.navigationController];
}


@end
