

#import <UIKit/UIKit.h>

@interface SetWeightViewController : BaseViewController {

}

@property (strong, nonatomic) IBOutlet UISegmentedControl *units;
@property (strong, nonatomic) IBOutlet UISlider *weightSlider;
@property (strong, nonatomic) IBOutlet UITextField *weightField;
@property (readwrite) id diaryVC;

- (IBAction)weightValueChanged:(id)sender;
 
- (IBAction)weightChanged:(id)sender;

- (IBAction)showNext:(id)sender;

@end
