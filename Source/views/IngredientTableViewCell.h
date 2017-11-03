//
//  IngredientTableViewCell.h
//  Cronometer
//
//  Created by Boris Esanu on 7/11/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddRecipeViewController.h"

@interface IngredientTableViewCell : UITableViewCell
@property (readwrite, assign) NSInteger rowIndex;
@property (readwrite, strong) AddRecipeViewController* addRecipe;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *measureLabel;
@property (strong, nonatomic) IBOutlet UIButton *removeButton;
@property (strong, nonatomic) IBOutlet UIView *measureView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *measureWidth;

- (IBAction)pressRemove:(id)sender;
- (void) hideAll;
- (void) setIngredient: (NSInteger)row_index serving:(Serving*) serving;
@end
