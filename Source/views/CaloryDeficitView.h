//
//  CaloryDeficitView.h
//  Cronometer
//
//  Created by choe on 9/6/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaloryDeficitView : UIView
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;

+ (id)contentView;
- (void)setValues: (id)summary name:(NSString*) nameg;
@end
