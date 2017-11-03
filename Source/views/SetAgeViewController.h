

#import <UIKit/UIKit.h>

@interface SetAgeViewController : BaseViewController {

}
 
@property (strong, nonatomic) IBOutlet UIDatePicker *date;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (readwrite) id diaryVC;
- (IBAction)showNext:(id)sender;
- (IBAction)dateChanged:(id)sender;

@end
