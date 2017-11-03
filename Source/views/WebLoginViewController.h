//
//  WebLoginViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 2012-12-27.
//  Copyright (c) 2012 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WebLoginDelegate <NSObject>
@required
- (void)gotToken:(NSString *)token;
@end


@interface WebLoginViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
 
@property (strong, nonatomic) id delegate;

@property (strong, nonatomic) NSString *domain;

@property (strong, nonatomic) NSURL *url;

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl delegate:(id<WebLoginDelegate>)aDelegate;

@end

