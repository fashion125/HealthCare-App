 

#import "SetAgeViewController.h"
#import "LoginViewController.h"
#import "WebQuery.h"
#import "Day.h"
#import "DiaryViewController.h"
#import "HealthKitService.h"

@implementation SetAgeViewController

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
   
    NSDate * dateOfBirth = [[HealthKitService sharedInstance] getUsersDateOfBirth];
    if (dateOfBirth != nil) {
        [self.date setDate: dateOfBirth ];
 
    }else{
    
       [self.date setDate: [NSDate dateWithTimeIntervalSinceNow:(-365*30.5*24*60*60)]];
       
    }
    [self.date setMaximumDate: [NSDate dateWithTimeIntervalSinceNow:-24*60*60]];
    [self.date setMinimumDate: [NSDate dateWithTimeIntervalSinceNow:-365*120*24*60*60]];
   
   [self dateChanged:nil];
    if (self.diaryVC != nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *date = [self.date date];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString* dt = [[WebQuery singleton] getPref:@"birthdate" defaultTo:[dateFormatter stringForObjectValue:date]];
        NSLog(@"%@", dt);
        NSDate* newdate = [dateFormatter dateFromString: dt];
        [self.date setDate: newdate];
        long years = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                      fromDate:newdate
                                                        toDate:[NSDate date] options:0] year];
        self.ageLabel.text = [NSString stringWithFormat:@"%ld years old", years];

    }
    
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popToViewController:(UIViewController*)self.diaryVC animated:YES];
}

- (void)viewDidUnload {  
   [self setDate:nil];
   [self setAgeLabel:nil];
   [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
    
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
- (void) showNext:(id)sender {
   
   NSDate *date = [self.date date];

   // TODO: validate
   
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateFormat:@"yyyy-MM-dd"];  
   
   [[WebQuery singleton] setPref:@"birthdate" withValue:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]]];
   
   [[WebQuery singleton] suggestTargets];
   
    [LoginViewController showPostLoginView:self.navigationController];
}

- (IBAction)dateChanged:(id)sender {   
   NSDate *date = [self.date date];
   long years = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                      fromDate:date
                                                        toDate:[NSDate date] options:0] year];
   self.ageLabel.text = [NSString stringWithFormat:@"%ld years old", years];
}


@end
