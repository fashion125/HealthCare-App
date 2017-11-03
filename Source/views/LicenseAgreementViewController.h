//
//  LicenseAgreementViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 2014-03-03.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LicenseAgreementViewController : BaseViewController <UIWebViewDelegate>


@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *agreeButton;

- (IBAction)agreeClicked:(id)sender;

@end
