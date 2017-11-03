//
//  DiaryOptsViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 31/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoodSearchViewController.h"

@interface DiaryOptsViewController : UIViewController {
   UIDatePicker *datePicker;
   UINavigationBar *navBar; 
}

- (IBAction)logout:(id)sender;
- (IBAction)cancel:(id)sender; 
- (IBAction)today:(id)sender;
- (IBAction)changeDay:(id)sender;
- (IBAction)dateChanged:(id)sender;

@property (unsafe_unretained) DiaryViewController *diary;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;  

@end
