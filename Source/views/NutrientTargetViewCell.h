//
//  NutrientTargetViewCell.h
//  Cronometer
//
//  Created by choe on 8/1/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"

@interface NutrientTargetViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress0;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel0;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel0;

@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress1;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel1;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel1;

@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress2;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel2;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel2;

@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress3;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel3;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel3;

@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress4;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel4;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel4;

@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress5;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel5;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel5;

@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress6;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel6;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel6;

@property (strong, nonatomic) IBOutlet KAProgressLabel *kaProgress7;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel7;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel7;

- (void) setTargets : (NSArray*) diaryEntries;

@end
