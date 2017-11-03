//
//  FoodSearchTableViewCell.m
//  Cronometer
//
//  Created by Boris Esanu on 22/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "FoodSearchTableViewCell.h"

@implementation FoodSearchTableViewCell
@synthesize title;
@synthesize subtitle;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
