//
//  CreateAccountViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 31/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateAccountViewController : UIViewController <UITextFieldDelegate> {
   UITextField *password;
   UITextField *email;
}


- (IBAction)doCreate:(id)sender;
- (IBAction)cancel:(id)sender;


@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UITextField *password2;
@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) UITextField *confirmField;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end
