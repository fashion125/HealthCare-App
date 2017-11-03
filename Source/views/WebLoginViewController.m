//
//  WebLoginViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 2012-12-27.
//  Copyright (c) 2012 cronometer.com. All rights reserved.
//

#import "WebLoginViewController.h"

@interface WebLoginViewController ()

@end

@implementation WebLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Web Login";   
}

- (void)viewDidUnload {
   self.webView.delegate = nil;
   [self setDomain:nil];
   [self setUrl:nil];
   [self setWebView:nil];
   [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated {
   [self.navigationController setNavigationBarHidden:NO];
   [super viewDidAppear: animated];

   NSLog(@"Loading URL: %@ %@", self.webView, self.url);
   self.spinner.hidden = NO;
   [self.spinner startAnimating];
   self.webView.delegate = self;
   self.webView.scalesPageToFit = YES;
   [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl delegate:(id<WebLoginDelegate>)aDelegate {
   self.url = [NSURL URLWithString:authenticateUrl];
   self.delegate = aDelegate;
   self.domain = [[NSURL URLWithString:authenticateUrl] host];
   NSLog(@"Loading URL: %@", self.url);
}

- (NSString*)getTokenFromCookie {
   NSHTTPCookie *cookie;
   NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
   for (cookie in [cookieJar cookies]) {
      if ([[cookie domain] isEqualToString:self.domain]) {
         if ([[cookie name] isEqualToString:@"mosestoken"]) {
            [cookieJar deleteCookie:cookie];
            return [cookie value];
         }
      }
   }
   return nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
   [self.spinner stopAnimating];
   self.spinner.hidden = YES;
   NSString* token = [self getTokenFromCookie];
   if (token != nil) {
      NSLog(@"Got token %@", token);
      [self.delegate gotToken:token];
   }
}

@end
