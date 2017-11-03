//
//  MacroInfoView.h
//  Cronometer
//
//  Created by Boris Esanu on 7/18/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MacroInfoView : UIView

+ (id)contentView;

@property (strong, nonatomic) IBOutlet UILabel *proteinLabel;
@property (strong, nonatomic) IBOutlet UILabel *carbsLabel;
@property (strong, nonatomic) IBOutlet UILabel *lipidsLabel;
@property (strong, nonatomic) IBOutlet UILabel *alcoholLabel;

- (void) setValuesWith: (double) p carbs: (double) c lipids: (double)l alchol: (double) a;
@end
