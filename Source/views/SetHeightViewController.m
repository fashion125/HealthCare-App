

#import "SetHeightViewController.h"
#import "WebQuery.h"
#import "SetWeightViewController.h"
 
#import "HealthKitService.h"
#import "Utils.h"

@interface SetHeightViewController()

@property (nonatomic, strong) HealthKitService * healthKitService;

@end

@implementation SetHeightViewController

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
        HKQuantitySample * userHeight = [[HealthKitService sharedInstance] usersHeight];
        if (userHeight != nil) {
            
            
            NSLog(@"user height: %@", userHeight);
            
            NSLocale * userLocal = [NSLocale currentLocale];
            
            NSLog(@"userloacle NSLocaleUsesMetricSystem: %@", [userLocal objectForKey:NSLocaleUsesMetricSystem]);
            if ([[userLocal objectForKey:NSLocaleUsesMetricSystem] boolValue] == YES) {
                self.units.selectedSegmentIndex = 1;
            }else{
                self.units.selectedSegmentIndex = 0;
            }
            
            self.heightSlider.value = ([userHeight.quantity doubleValueForUnit:[HKUnit meterUnit]] * 100.0f );
            
        }
        
    }
    
    [self heightChanged:nil];
    if (self.diaryVC != nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        if ([[WebQuery singleton] getPreferredHeightUnit] == 3) {
            self.units.selectedSegmentIndex = 1;

        } else {
            self.units.selectedSegmentIndex = 0;

        }
        self.heightSlider.value = [[WebQuery singleton] heightInCM];
        [self heightChanged: self.heightSlider];
    }
    
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popToViewController:(UIViewController*)self.diaryVC animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidUnload {
   [self setUnits:nil];
   [self setHeightSlider:nil];
   [self setHeightField:nil];
   [self setHeightLabel:nil];
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
- (void) showNext:(id)sender {   
   // save settings
   long cm = round([self.heightSlider value]);

    [[Crashlytics sharedInstance] setObjectValue:@(cm) forKey:@"HeightValueLong"];
    [[Crashlytics sharedInstance] setObjectValue:[NSString stringWithFormat:@"%ld",cm] forKey:@"HeightValueStr"];
   [[WebQuery singleton] setPref:@"heightInCM" withValue:[NSString stringWithFormat:@"%ld",cm]];
   [WebQuery singleton].heightInCM = cm;
   if ([self.units selectedSegmentIndex] == 0) {
      [[WebQuery singleton] setPref:@"pref.height.unit" withValue:@"2"]; //seems not in use
      [[WebQuery singleton] setPref:@"heightUnit" withValue:@"Inches"];
   } else {   
      [[WebQuery singleton] setPref:@"pref.height.unit" withValue:@"1"]; //seems not in use
      [[WebQuery singleton] setPref:@"heightUnit" withValue:@"Centimeters"];
   }
   
    SetWeightViewController* setWeightVC = (SetWeightViewController*)[Utils newViewControllerWithId:@"setWeightVC"];
    setWeightVC.diaryVC = self.diaryVC;
   [self.navigationController pushViewController:setWeightVC animated:YES];
}
 
- (IBAction)heightChanged:(id)sender {
   float val = [self.heightSlider value];
   long cm = round(val);
   long inches = cm / 2.53999996;
   long feet = inches / 12;
   inches = inches - feet*12;
   if ([self.units selectedSegmentIndex] == 0) {
      self.heightLabel.text = [NSString stringWithFormat:@"%ld' %ld\"", feet, inches];
   } else {
      self.heightLabel.text = [NSString stringWithFormat:@"%ld cm",  cm];
   }
}
- (IBAction)unitChanged:(id)sender {
    float val = [self.heightSlider value];
    long cm = round(val);
    long inches = cm / 2.53999996;
    long feet = inches / 12;
    inches = inches - feet*12;
    if ([self.units selectedSegmentIndex] == 0) {
        self.heightLabel.text = [NSString stringWithFormat:@"%ld' %ld\"", feet, inches];
    } else {
        self.heightLabel.text = [NSString stringWithFormat:@"%ld cm",  cm];
    }
}

@end
