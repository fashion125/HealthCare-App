//
//  FoodSearchTableViewCell.h
//  Cronometer
//
//  Created by Boris Esanu on 22/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodSearchTableViewCell : UITableViewCell {
   UILabel *title;
   UILabel *subtitle;
}


@property (nonatomic, strong) IBOutlet UILabel *title;
 
@property (nonatomic, strong) IBOutlet UILabel *subtitle;

@end
