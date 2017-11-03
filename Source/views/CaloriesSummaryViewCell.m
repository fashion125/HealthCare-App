//
//  CaloriesSummaryViewCell.m
//  Cronometer
//
//  Created by choe on 7/26/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "CaloriesSummaryViewCell.h"
#import "CaloryInfoView.h"
#import "CaloryDeficitView.h"
#import "CMPopTipView.h"

#define image_size 18
#define labels_height 21
#define protein_width 42
#define fat_width 20
#define carbs_width 35

#define bmr_width 28
#define activity_width 42
#define exercise_width 50

@interface CaloriesSummaryViewCell()

@property (strong, readwrite) Summary* summary;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (strong, nonatomic) IBOutlet UIImageView *proteinImage;
@property (strong, nonatomic) IBOutlet UILabel *proteinLabel;
@property (strong, nonatomic) IBOutlet UIImageView *fatImage;
@property (strong, nonatomic) IBOutlet UILabel *fatLabel;
@property (strong, nonatomic) IBOutlet UIImageView *carbsImage;
@property (strong, nonatomic) IBOutlet UILabel *carbsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *alcoholImage;

@property (strong, nonatomic) IBOutlet UIImageView *bmrImage;
@property (strong, nonatomic) IBOutlet UILabel *bmrLabel;
@property (strong, nonatomic) IBOutlet UIImageView *activityImage;
@property (strong, nonatomic) IBOutlet UILabel *activityLabel;
@property (strong, nonatomic) IBOutlet UIImageView *exerciseImage;
@property (strong, nonatomic) IBOutlet UILabel *exerciseLabel;

@end
@implementation CaloriesSummaryViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setPositions: (UIImageView*) img label: (UILabel*) label img_size: (int) img_size label_size: (int) label_size main_size: (float) main_size {
    
    if (main_size >= label_size+img_size) {
        
        img.hidden = NO;
        if (label != nil) {
            label.hidden = NO;
            CGPoint point = label.layer.position;
            CGPoint point1 = img.layer.position;
            CGRect rect = label.frame;
            rect.size.width = label_size;
            point1.x = (main_size-img_size-label_size)*1.0/2.0 + img_size*1.0/2.0;
            
            point.x = point1.x + (img_size + label_size)*1.0/2.0;
            img.layer.position = point1;
            label.frame = rect;
            label.layer.position = point;
            
        } else {
            CGPoint point = img.layer.position;
            point.x = -(img_size - main_size)*1.0/2.0 + img_size*1.0/2.0;
            img.layer.position = point;
        }
    } else if (main_size >= img_size && main_size < label_size+img_size) {
        
//        img.hidden = NO;
//        if (label != nil) {
//            label.hidden = NO;
//            CGPoint point = label.layer.position;
//            CGPoint point1 = img.layer.position;
//            CGRect rect = label.frame;
//            rect.size.width = main_size-img_size;
//            point1.x = (main_size-img_size-rect.size.width)*1.0/2.0 + img_size*1.0/2.0;
//            
//            point.x = point1.x + (img_size + rect.size.width)*1.0/2.0;
//            label.frame = rect;
//            img.layer.position = point1;
//            label.layer.position = point;
//            
//            
//        } else {
//            CGPoint point = img.layer.position;
//            point.x = -(img_size - main_size)*1.0/2.0 + img_size*1.0/2.0;
//            img.layer.position = point;
//        }
        
        img.hidden = NO;
        if (label != nil) label.hidden = YES;
        CGPoint point = img.layer.position;
        point.x = -(img_size - main_size)*1.0/2.0 + img_size*1.0/2.0;
        img.layer.position = point;
    } else if (main_size >= img_size*3.0/4.0 && main_size < img_size) {
        
        img.hidden = NO;
        if (label != nil) label.hidden = YES;
        CGPoint point = img.layer.position;
        point.x = -(img_size - main_size)*1.0/2.0 + img_size*1.0/2.0;
        img.layer.position = point;
    } else {
        img.hidden = YES;
        if (label != nil) label.hidden = YES;
    }
}
-(void)drawRect:(CGRect)rect {
    if (_summary == nil) return;
    [self setSummary:_summary again: NO];
}
//-(void)setSummaryAgain : (Summary*) summary {
//    
//    _summary = summary;
//    
//    self.rltBarView1.layer.cornerRadius = 5;
//    self.rltBarView1.layer.masksToBounds = YES;
//    self.rltBarView2.layer.cornerRadius = 5;
//    self.rltBarView2.layer.masksToBounds = YES;
//    
//    [self.deficitButton setTitle: [NSString stringWithFormat:@"%.1f", [summary.consumed deficit_kcal] ] forState: UIControlStateNormal];
//    
//    self.proteinWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed protein_percent]/100;
//    [self setPositions: self.proteinImage label:self.proteinLabel img_size:image_size label_size:protein_width main_size:self.proteinWidth.constant];
//    self.fatWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed fat_percent]/100;
//    [self setPositions: self.fatImage label:self.fatLabel img_size:image_size label_size:fat_width main_size:self.fatWidth.constant];
//    self.carbsWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed carbs_percent]/100;
//    [self setPositions: self.carbsImage label:self.carbsLabel img_size:image_size label_size:carbs_width main_size:self.carbsWidth.constant];
//    self.alcoholsWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed alcohol_percent]/100;
//    [self setPositions: self.alcoholImage label:nil img_size:image_size label_size:0 main_size:self.alcoholsWidth.constant];
//    
//    [self.consumedLabel setText: [NSString stringWithFormat: @"%d kcal", (int)round([summary.consumed total])]];
//    [self.burnedLabel setText: [NSString stringWithFormat: @"%d kcal", (int)round([summary.burned total])]];
//    
//    [self.surplusButton setTitle: [NSString stringWithFormat:@"%.1f", [summary.burned surplus_kcal] ] forState: UIControlStateNormal];
//    
//    self.bmrWidth.constant = self.rltBarView2.frame.size.width * [summary.burned bmr_percent]/100;
//    [self setPositions: self.bmrImage label:self.bmrLabel img_size:image_size label_size:bmr_width main_size:self.bmrWidth.constant];
//    self.activityWidth.constant = self.rltBarView2.frame.size.width * [summary.burned activity_percent]/100;
//    [self setPositions: self.activityImage label:self.activityLabel img_size:image_size label_size:activity_width main_size:self.activityWidth.constant];
//    self.exerciseWidth.constant = self.rltBarView2.frame.size.width * [summary.burned exercise_percent]/100;
//    [self setPositions: self.exerciseImage label:self.exerciseLabel img_size:image_size label_size:exercise_width main_size:self.exerciseWidth.constant];
//    
//    
////    dispatch_async(dispatch_get_main_queue(), ^{
////        [self.rltBarView1 setNeedsLayout];
////        [self.rltBarView1 setNeedsDisplay];
////        [self.rltBarView2 setNeedsLayout];
////        [self.rltBarView2 setNeedsDisplay];
////        [self setNeedsLayout];
////        [self setNeedsDisplay];
////    });
//}
-(void) setSubViews: (UIView*) view image: (UIImageView*) image button: (UIButton*) button rect: (CGRect) rect {
    view.frame = rect;
    CGRect imgRect = image.frame;
    imgRect.origin = CGPointMake(0, 0);
    imgRect.size = rect.size;
    image.frame = imgRect;
    CGRect btnRect = button.frame;
    btnRect.origin = CGPointMake(0, 0);
    btnRect.size = rect.size;
    button.frame = btnRect;
}
- (CGFloat) widthForButton: (UIButton*) button {
    if (button == nil || [button titleLabel] == nil) return 1;
    NSString* str = [NSString stringWithFormat:@"%@l", [[button titleLabel] text]];
    CGSize textSize = [str sizeWithAttributes:@{NSFontAttributeName:[[button titleLabel] font]}];
    return textSize.width;
}

-(void)setSummary : (Summary*) summary again: (BOOL) again{

    _summary = summary;
    
    self.rltBarView1.layer.cornerRadius = 5;
    self.rltBarView1.layer.masksToBounds = YES;
    self.rltBarView2.layer.cornerRadius = 5;
    self.rltBarView2.layer.masksToBounds = YES;
    
    [self.deficitButton setTitle: [NSString stringWithFormat:@"%.1f", [summary.consumed deficit_kcal] ] forState: UIControlStateNormal];
    
    self.proteinWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed protein_percent]/100;
    [self setPositions: self.proteinImage label:self.proteinLabel img_size:image_size label_size:protein_width main_size:self.proteinWidth.constant];

//    CGRect proteinRect = self.proteinView.frame;
//    proteinRect.origin = CGPointMake(0, 0);//self.rltBarView1.frame.origin;//
//    proteinRect.size = CGSizeMake(self.rltBarView1.frame.size.width * [summary.consumed protein_percent]/100, self.rltBarView1.frame.size.height);
//    [self setSubViews:self.proteinView image:self.proteinBgImage button:self.proteinButton rect:proteinRect];
//    [self setPositions: self.proteinImage label:self.proteinLabel img_size:image_size label_size:protein_width main_size:proteinRect.size.width];
    
    self.fatWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed fat_percent]/100;
    [self setPositions: self.fatImage label:self.fatLabel img_size:image_size label_size:fat_width main_size:self.fatWidth.constant];
//    CGRect fatRect = self.fatView.frame;
//    fatRect.origin = CGPointMake(proteinRect.origin.x+proteinRect.size.width, proteinRect.origin.y);
//    fatRect.size = CGSizeMake(self.rltBarView1.frame.size.width * [summary.consumed fat_percent]/100, self.rltBarView1.frame.size.height);
//    [self setSubViews:self.fatView image:self.fatBgImage button:self.fatButton rect:fatRect];
//    [self setPositions: self.fatImage label:self.fatLabel img_size:image_size label_size:fat_width main_size:fatRect.size.width];
   
    self.carbsWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed carbs_percent]/100;
    [self setPositions: self.carbsImage label:self.carbsLabel img_size:image_size label_size:carbs_width main_size:self.carbsWidth.constant];
//    CGRect carbsRect = self.carbsView.frame;
//    carbsRect.origin = CGPointMake(fatRect.origin.x+fatRect.size.width, fatRect.origin.y);
//    carbsRect.size = CGSizeMake(self.rltBarView1.frame.size.width * [summary.consumed carbs_percent]/100, self.rltBarView1.frame.size.height);
//    [self setSubViews:self.carbsView image:self.carbsBgImage button:self.carbsButton rect:carbsRect];
//    [self setPositions: self.carbsImage label:self.carbsLabel img_size:image_size label_size:carbs_width main_size: carbsRect.size.width];
    
    self.alcoholsWidth.constant = self.rltBarView1.frame.size.width * [summary.consumed alcohol_percent]/100;
    [self setPositions: self.alcoholImage label:nil img_size:image_size label_size:0 main_size:self.alcoholsWidth.constant];
//    CGRect alcoholsRect = self.alcoholsView.frame;
//    alcoholsRect.origin = CGPointMake(carbsRect.origin.x+carbsRect.size.width, carbsRect.origin.y);
//    alcoholsRect.size = CGSizeMake(self.rltBarView1.frame.size.width * [summary.consumed alcohol_percent]/100, self.rltBarView1.frame.size.height);
//    [self setSubViews:self.alcoholsView image:self.alcoholsBgImage button:self.alcoholsButton rect:alcoholsRect];
//    [self setPositions: self.alcoholImage label:nil img_size:image_size label_size:0 main_size:alcoholsRect.size.width];
    
//    float deficitWidth = proteinRect.size.width + fatRect.size.width + carbsRect.size.width + alcoholsRect.size.width;
//    deficitWidth = self.rltBarView1.frame.size.width - deficitWidth;
//    CGRect deficitRect = self.deficitButton.frame;
//    deficitRect.origin = CGPointMake(alcoholsRect.origin.x + alcoholsRect.size.width, alcoholsRect.origin.y);
//    deficitRect.size = CGSizeMake(deficitWidth, self.rltBarView1.frame.size.height);
//    self.deficitButton.frame = deficitRect;
    
    [self.consumedLabel setText: [NSString stringWithFormat: @"%d kcal", (int)round([summary.consumed total])]];
    [self.burnedLabel setText: [NSString stringWithFormat: @"%d kcal", (int)round([summary.burned total])]];
    
    [self.surplusButton setTitle: [NSString stringWithFormat:@"%.1f", [summary.burned surplus_kcal] ] forState: UIControlStateNormal];
    
    self.bmrWidth.constant = self.rltBarView2.frame.size.width * [summary.burned bmr_percent]/100;
    [self setPositions: self.bmrImage label:self.bmrLabel img_size:image_size label_size:bmr_width main_size:self.bmrWidth.constant];
    self.activityWidth.constant = self.rltBarView2.frame.size.width * [summary.burned activity_percent]/100;
    [self setPositions: self.activityImage label:self.activityLabel img_size:image_size label_size:activity_width main_size:self.activityWidth.constant];
    self.exerciseWidth.constant = self.rltBarView2.frame.size.width * [summary.burned exercise_percent]/100;
    [self setPositions: self.exerciseImage label:self.exerciseLabel img_size:image_size label_size:exercise_width main_size:self.exerciseWidth.constant];
    
    if ([self widthForButton: self.deficitButton] >= self.deficitButton.frame.size.width) {
        [self.deficitButton setTitle: @"" forState: UIControlStateNormal];
    }
    if ([self widthForButton: self.surplusButton] >= self.surplusButton.frame.size.width) {
        [self.surplusButton setTitle: @"" forState: UIControlStateNormal];
    }

    if (again == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.proteinView setNeedsDisplay];
//            [self.rltBarView1 setNeedsLayout];
//            [self.rltBarView1 setNeedsDisplay];
//            [self.rltBarView2 setNeedsLayout];
//            [self.rltBarView2 setNeedsDisplay];
//            [self setNeedsLayout];
            [self setNeedsDisplay];
//            [self updateConstraintsIfNeeded];
        });
    }
}
- (IBAction)pressProtein:(id)sender {
        [self showPopTipView: sender name: @"PROTEIN"];
}
- (IBAction)pressFat:(id)sender {
        [self showPopTipView: sender name: @"FAT"];
}
- (IBAction)pressCarbs:(id)sender {
        [self showPopTipView: sender name: @"CARBS"];
}
- (IBAction)pressAlcohol:(id)sender {
        [self showPopTipView: sender name: @"ALCOHOL"];
}
- (IBAction)pressDeficit:(id)sender {
    [self showPopTipViewWithoutPercent: sender name: @"CALORIC DEFICIT"];
}
- (IBAction)pressBMR:(id)sender {
    
    [self showPopTipView: sender name: @"BMR"];
}
- (IBAction)pressActivity:(id)sender {
        [self showPopTipView: sender name: @"ACTIVITY"];
}
- (IBAction)pressExercise:(id)sender {
        [self showPopTipView: sender name: @"EXERCISE"];
}
- (IBAction)pressSurplus:(id)sender {
    
    [self showPopTipViewWithoutPercent: sender name: @"CALORIC SURPLUS"];
}
- (void)showPopTipViewWithoutPercent: (id)sender name:(NSString*) name {
    [self dismissAllPopTipViews];
    if (self.visiblePopTipViews == nil) {
        self.visiblePopTipViews = [NSMutableArray array];
    }
    if (sender == self.currentPopTipViewTarget) {
        // Dismiss the popTipView and that is all
        self.currentPopTipViewTarget = nil;
    }
    else {
        CMPopTipView *popTipView;
        CaloryDeficitView* infoView = nil;
        infoView = [CaloryDeficitView contentView];
        [infoView setValues: self.summary name: name];
        
        popTipView = [[CMPopTipView alloc] initWithCustomView:infoView];
        popTipView.delegate = (id<CMPopTipViewDelegate>)self;
        
        //        popTipView.animation = arc4random() % 2;
        popTipView.borderWidth = 0;
        popTipView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
        popTipView.hasGradientBackground = NO;
        
        popTipView.has3DStyle = NO;//(BOOL)(arc4random() % 2);
        popTipView.borderWidth = 0;
        popTipView.cornerRadius = 7;
        
        popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:3.0];
        
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            [popTipView presentPointingAtView:button inView:self animated:YES];
        }
        [self.visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
    }
}
- (void)showPopTipView: (id)sender name:(NSString*) name {
    [self dismissAllPopTipViews];
    if (self.visiblePopTipViews == nil) {
        self.visiblePopTipViews = [NSMutableArray array];
    }
    if (sender == self.currentPopTipViewTarget) {
        // Dismiss the popTipView and that is all
        self.currentPopTipViewTarget = nil;
    }
    else {
        CMPopTipView *popTipView;
        CaloryInfoView* infoView = nil;
        infoView = [CaloryInfoView contentView];
        [infoView setValues: self.summary name: name];
        
        popTipView = [[CMPopTipView alloc] initWithCustomView:infoView];
        popTipView.delegate = (id<CMPopTipViewDelegate>)self;
        
        //        popTipView.animation = arc4random() % 2;
        popTipView.borderWidth = 0;
        popTipView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
        popTipView.hasGradientBackground = NO;
        
        popTipView.has3DStyle = NO;//(BOOL)(arc4random() % 2);
        popTipView.borderWidth = 0;
        popTipView.cornerRadius = 7;
        
        popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:3.0];
        
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            [popTipView presentPointingAtView:button inView:self animated:YES];
        }
        [self.visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
    }

}
#pragma mark - CMPopTipViewDelegate methods
- (void)dismissAllPopTipViews
{
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
}
@end
