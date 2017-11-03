

#import "SetWeightViewController.h"
#import "WebQuery.h"
#import "SetAgeViewController.h"
#import "Formatter.h"

#import "HealthKitService.h"
#import "Utils.h"

@implementation SetWeightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
    
    
    if ([[HealthKitService sharedInstance] isServiceAccessible])
    {
        HKQuantitySample * userWeight = [[HealthKitService sharedInstance] usersWeight];
        if (userWeight != nil) {
            
            
            NSLog(@"user weight: %@", userWeight);
            
            NSLocale * userLocal = [NSLocale currentLocale];
            
            NSLog(@"userloacle NSLocaleUsesMetricSystem: %@", [userLocal objectForKey:NSLocaleUsesMetricSystem]);
            if ([[userLocal objectForKey:NSLocaleUsesMetricSystem] boolValue] == YES) {
                self.units.selectedSegmentIndex = 1;
            }else{
                self.units.selectedSegmentIndex = 0;
            }
            
            self.weightSlider.value = ([userWeight.quantity doubleValueForUnit:[HKUnit gramUnit]] / 1000.0f );
            
        }
        
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];/////// dismiss keyboard
    [self.view addGestureRecognizer: tap];
    
  
   [self weightChanged:nil];
    if (self.diaryVC != nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        
        if ([[WebQuery singleton] getPreferredWeightUnit] == 1) {
            self.units.selectedSegmentIndex = 1;
            
        } else {
            self.units.selectedSegmentIndex = 0;
            
        }
        self.weightSlider.value = [[WebQuery singleton] weightInKg];
        [self weightChanged: self.weightSlider];
    }
    
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popToViewController:(UIViewController*)self.diaryVC animated:YES];
}

-(void)dismissKeyboard {
    [self.weightField resignFirstResponder];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
    
    
}
- (void)viewDidUnload { 
   [self setUnits:nil];
   [self setWeightSlider:nil];
   [self setWeightField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   dispatch_async(dispatch_get_main_queue(), ^{
      [self weightValueChanged:textField];
   });
   return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
   if (theTextField == self.weightField) {
      NSNumber *val = [Formatter numberFromString:theTextField.text];
      if (val) {
         [self.weightField resignFirstResponder];
         return YES;
      } else {
         return NO;
      }
   }
   return YES;
} 


- (IBAction)weightValueChanged:(id)sender {
   NSNumber *val = [Formatter numberFromString:self.weightField.text];
   if (val) {
       float val1 = [val floatValue];
       if (self.units.selectedSegmentIndex == 0) {
           val1 = val1 * 0.45359237038;
       }
      [self.weightSlider setValue: val1];
      self.weightField.textColor = [UIColor blackColor];
   } else {
      //self.weightField.textColor = [UIColor redColor];
   }
}

- (IBAction)weightChanged:(id)sender {
   float val = [self.weightSlider value];
   if ([self.units selectedSegmentIndex] == 0) {
      val = val / 0.45359237038;
   }
   self.weightField.text = [NSString stringWithFormat:@"%.1f", val];   
}
- (IBAction)unitChanged:(id)sender {
    float val = [self.weightSlider value];
    if ([self.units selectedSegmentIndex] == 0) {
        val = val / 0.45359237038;
    }
    self.weightField.text = [NSString stringWithFormat:@"%.1f", val];
}

- (IBAction)showNext:(id)sender {
   float weightInKg = [self.weightSlider value];
   [WebQuery singleton].weightInKg = weightInKg;
    [[Crashlytics sharedInstance] setObjectValue:@(weightInKg) forKey:@"WeightValueFloat"];
    [[Crashlytics sharedInstance] setObjectValue:[NSString stringWithFormat:@"%f",weightInKg] forKey:@"WeightValueStr"];
    
   [[WebQuery singleton] setPref:@"weightInKG" withValue:[NSString stringWithFormat:@"%f",weightInKg]];
   if ([self.units selectedSegmentIndex] == 0) {
      [[WebQuery singleton] setPref:@"pref.weight.unit" withValue:@"2"];
      [[WebQuery singleton] setPref:@"weightUnit" withValue:@"Pounds"];
   } else {
      [[WebQuery singleton] setPref:@"pref.weight.unit" withValue:@"1"];
      [[WebQuery singleton] setPref:@"weightUnit" withValue:@"Kilograms"];
   }
   
    SetAgeViewController* setAgeVC = (SetAgeViewController*)[Utils newViewControllerWithId:@"setAgeVC"];
    setAgeVC.diaryVC = self.diaryVC;
   [self.navigationController  pushViewController:setAgeVC animated:YES];
}

@end
