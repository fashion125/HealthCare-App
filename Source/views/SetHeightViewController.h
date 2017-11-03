

#import <UIKit/UIKit.h>

@interface SetHeightViewController : BaseViewController {

}

@property (strong, nonatomic) IBOutlet UISegmentedControl *units;
@property (strong, nonatomic) IBOutlet UISlider *heightSlider;
@property (strong, nonatomic) IBOutlet UITextField *heightField;
@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (readwrite) id diaryVC;

- (IBAction)heightChanged:(id)sender;

- (IBAction)showNext:(id)sender;

@end
