//
//  IngredientTableViewCell.m
//  Cronometer
//
//  Created by Boris Esanu on 7/11/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "IngredientTableViewCell.h"

@implementation IngredientTableViewCell
@synthesize addRecipe, rowIndex;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) hideAll {
    self.measureLabel.hidden = YES;
    self.removeButton.hidden = YES;
    self.measureView.hidden = YES;
    self.nameLabel.hidden = YES;
}
- (CGFloat) widthForLabel: (UILabel*) label {
    if (label == nil) return 1;
    NSString* str = [NSString stringWithFormat:@"%@l", [label text]];
    CGSize textSize = [str sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    return textSize.width;
}
- (void) setIngredient: (NSInteger)row_index serving:(Serving*) serving {
    self.measureView.layer.cornerRadius = 3;
    self.measureView.layer.masksToBounds = YES;
    self.rowIndex = row_index;
    self.measureLabel.hidden = NO;
    self.removeButton.hidden = NO;
    self.measureView.hidden = NO;
    self.nameLabel.hidden = NO;
    
    if (serving != nil) {
        self.nameLabel.text = [serving foodName];
        //self.sizeLabel.text = [NSString stringWithFormat: @"%.1f", [serving grams]/[[serving  measure] grams]];
        self.measureLabel.text = [NSString stringWithFormat: @"%.1f %@", [serving grams]/[[serving  measure] grams], [serving measure].name];
        CGFloat width = [self widthForLabel:self.measureLabel];
        self.measureWidth.constant = width + 10;
    }
}
- (IBAction)pressRemove:(id)sender {
    [addRecipe removeIngredientAt: rowIndex];
}
@end

