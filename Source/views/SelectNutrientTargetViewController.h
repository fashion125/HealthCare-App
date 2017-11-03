//
//  SelectNutrientTargetViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 7/15/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectNutrientTargetViewController: UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *nutrientTargetTable;
@property (readwrite, strong) id setting;
@property (readwrite, strong) NSArray* nutrients;
@property (readwrite) long nutrientKey;
@property (readwrite) long index;
@end
