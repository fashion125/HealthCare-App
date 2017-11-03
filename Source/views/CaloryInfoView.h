//
//  CaloryInfoView.h
//  Cronometer
//
//  Created by choe on 8/6/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaloryInfoView : UIView
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *totalWidth;

+ (id)contentView;
- (void)setValues: (id)summary name:(NSString*) nameg;
@end
