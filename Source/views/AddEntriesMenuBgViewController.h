//
//  AddEntriesMenuViewController.h
//  Cronometer
//
//  Created by choe on 11/6/15.
//  Copyright © 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEntriesMenuBgViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *blurView;
@property (strong, nonatomic) id diaryVC;

- (void)cancel;
- (void)addServing;
- (void)addExercise;
- (void)addBiometric;
- (void)addNotes;
- (void)rearrangeEntries;
@end
