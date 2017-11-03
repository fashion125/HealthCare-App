//
//  EditTargetViewController.h
//  Cronometer
//
//  Created by Frank Mao on 2014-10-01.
//  Copyright (c) 2014 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Target.h"
#import "NutrientInfo.h"

@protocol EditTargetViewControllerDelegate <NSObject>

- (void)onTargetEditSuccess;

@end
@interface EditTargetViewController : UIViewController

@property (strong, nonatomic) Target * targetToEdit;
@property (strong, nonatomic) NutrientInfo * nutrientInfo;
@property (strong, nonatomic) id<EditTargetViewControllerDelegate> delegate;
@end
