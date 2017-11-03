//
//  CaloriesSummaryViewCell.h
//  Cronometer
//
//  Created by choe on 7/26/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Diary.h"

@interface CaloriesSummaryViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *consumedLabel;
@property (strong, nonatomic) IBOutlet UILabel *burnedLabel;
@property (strong, nonatomic) IBOutlet UIView *rltBarView1;
@property (strong, nonatomic) IBOutlet UIView *rltBarView2;
@property (strong, nonatomic) IBOutlet UIView *proteinView;
@property (strong, nonatomic) IBOutlet UIButton *proteinButton;
@property (strong, nonatomic) IBOutlet UIImageView *proteinBgImage;
@property (strong, nonatomic) IBOutlet UIImageView *fatBgImage;
@property (strong, nonatomic) IBOutlet UIButton *fatButton;
@property (strong, nonatomic) IBOutlet UIView *fatView;
@property (strong, nonatomic) IBOutlet UIView *carbsView;
@property (strong, nonatomic) IBOutlet UIImageView *carbsBgImage;
@property (strong, nonatomic) IBOutlet UIButton *carbsButton;
@property (strong, nonatomic) IBOutlet UIView *alcoholsView;
@property (strong, nonatomic) IBOutlet UIButton *alcoholsButton;
@property (strong, nonatomic) IBOutlet UIImageView *alcoholsBgImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fatWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *proteinWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carbsWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bmrWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *activityWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *exerciseWidth;
@property (strong, nonatomic) IBOutlet UIButton *deficitButton;
@property (strong, nonatomic) IBOutlet UIButton *surplusButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *alcoholsWidth;

-(void)setSummary : (Summary*) summary again: (BOOL) again;
@end

