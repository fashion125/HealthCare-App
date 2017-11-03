
//
//  AddBiometricViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "AddBiometricViewController.h"

#import "Toolbox.h"
#import "Formatter.h"
#import "WebQuery.h"
#import "HealthKitService.h"
#import "Utils.h"

@implementation AddBiometricViewController
@synthesize amount;
@synthesize metricPicker;
@synthesize diaryVC;
@synthesize metrics;
@synthesize biometric;
@synthesize measureButton;
@synthesize metricSelectedIndex;

static NSString* const disclosureCell = @"DisclosureCell";
static NSString* const measureCell = @"MeasureCell";

#define TAG_BIOMETRIC_MEASURE_LIST 2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.metrics = [[WebQuery singleton] getMetrics];
       // Default to Weight Metric:
       self.biometric = [[Biometric alloc] init];
       self.biometric.mId = 1;
       self.biometric.uId = [[WebQuery singleton] getPreferredWeightUnit];
       self.biometric.amount = [[WebQuery singleton] weightInPreferredUnit];
    }
    return self;
}
- (void)initBiometric {
    if (self) {
        metricSelectedIndex = 0;
        self.metrics = [[WebQuery singleton] getMetrics];
        // Default to Weight Metric:
        self.biometric = [[Biometric alloc] init];
        self.biometric.mId = 1;
        self.biometric.uId = [[WebQuery singleton] getPreferredWeightUnit];
        self.biometric.amount = [[WebQuery singleton] weightInPreferredUnit];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    
   if (self.biometric.entryId != 0) {
      self.titleLabel.text = @"Edit Biometric";
       [self.btnSave setTitle: @"EDIT BIOMETRIC" forState:UIControlStateNormal];
   } else {
       self.titleLabel.text = @"Add Measurement to Diary";
       [self.btnSave setTitle: @"ADD BIOMETRIC" forState:UIControlStateNormal];
   }
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
    
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target:self action:@selector(save:)];
//   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
   
   
//    if (metrics != nil && [metrics count] > 0) {
//        Metric *metric = [metrics objectAtIndex:0];
//        [measureButton setTitle: metric.name forState:UIControlStateNormal];
//    }
    
    // set spinner to current metric:
    for (int row = 0; row < [metrics count]; row++) {
       Metric *metric = [metrics objectAtIndex:row];
       if (metric.mId == self.biometric.mId) {
           metricSelectedIndex = row;
           Metric *metric = [metrics objectAtIndex:metricSelectedIndex];
           [measureButton setTitle: metric.name forState:UIControlStateNormal];
          int r2 = 0;
          for (Unit *u in [metric units]) {
             if (u.uId == self.biometric.uId) {
                [metricPicker selectRow: r2 inComponent:0 animated: FALSE];
                 
                 [self pickerView:metricPicker didSelectRow:r2 inComponent:0];
             }
             r2++;
          }
       }
    }
   [metricPicker reloadAllComponents];
    if (self.biometric.entryId != 0) {
        self.amount.text = [Formatter formatAmount: [biometric amount]];
    } else {
        self.amount.text = @"";
        self.amount.placeholder = [Formatter formatAmount: [biometric amount]];
//        [self updateUnitPicker];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.dlgView addGestureRecognizer: tap];
    if ([Utils isIPhone6] || [Utils isIPhone6s] || [Utils isIPad]) {
        [self.amount becomeFirstResponder];        
    }

}
-(void)dismissKeyboard {
    [self.amount resignFirstResponder];
}
- (void)viewDidUnload {
    [self setAmount:nil];
    [self setMetricPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)save:(id)sender { 
   if (metricPicker.numberOfComponents <= 0) return;

    long metricIndex = metricSelectedIndex;//[metricPicker selectedRowInComponent:0];
   Metric *metric = [metrics objectAtIndex: metricIndex];
   
   long unitIndex = [metricPicker selectedRowInComponent:0];
   Unit *unit = [[metric units] objectAtIndex: unitIndex];

   [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
   
    NSNumber *val = [Formatter numberFromString: ([amount.text isEqualToString: @""] ? amount.placeholder : amount.text)];
   

   biometric.mId = metric.mId;
   biometric.uId = unit.uId;
   biometric.amount = [val doubleValue];

    __weak __typeof__(self) wself = self;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.btnSave.enabled = NO;
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      if (wself.biometric.entryId == 0) {
         wself.biometric.day = [wself.diaryVC currentDay];
         [wself.diaryVC setOrderForNewDiaryEntry: wself.biometric];
         [[WebQuery singleton] addBiometric: wself.biometric];
         dispatch_async(dispatch_get_main_queue(), ^{         
            [wself.diaryVC entryAdded: wself.biometric];
             [wself.navigationController popToViewController: wself.diaryVC animated:YES];
             self.navigationItem.rightBarButtonItem.enabled = YES;
             self.btnSave.enabled = YES;
         });
      } else {
         [[WebQuery singleton] editBiometric: wself.biometric];
         dispatch_async(dispatch_get_main_queue(), ^{         
            [wself.diaryVC entryChanged: wself.biometric];
             [wself.navigationController popToViewController: wself.diaryVC animated:YES];
             self.navigationItem.rightBarButtonItem.enabled = YES;
             self.btnSave.enabled = YES;
         });
      }
   }); 
}

- (IBAction)cancel:(id)sender {
   [self.navigationController popViewControllerAnimated: YES]; 
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
   if (theTextField == amount) { 
      NSNumber *val = [Formatter numberFromString:amount.text];
      if (!val) {         
         return NO;
      } else {
         [amount resignFirstResponder];
      }
   } 
   return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height < 500) {
      [Toolbox moveView: self.view up: -70];
   }
}

- (void)updateUnitPicker {
    Metric *metric = [metrics objectAtIndex: metricSelectedIndex];
    
    if (metric.mId == 1) {
        long uId = [[WebQuery singleton] getPreferredWeightUnit];

        int r2 = 0;
        for (Unit *u in [metric units]) {
            if (u.uId == uId) {
                [metricPicker selectRow: r2 inComponent:0 animated: FALSE];
            }
            r2++;
        }
    } else if (metric.mId == 2) {
        long uId = [[WebQuery singleton] getPreferredHeightUnit];
        
        int r2 = 0;
        for (Unit *u in [metric units]) {
            if (u.uId == uId) {
                [metricPicker selectRow: r2 inComponent:0 animated: FALSE];
            }
            r2++;
        }
    }

    long unitIndex = [metricPicker selectedRowInComponent:0];
    Unit *unit = [[metric units] objectAtIndex: unitIndex];

    NSLog(@"selected: %@ %@", metric, unit);
    self.amount.text = @"";
    self.amount.placeholder = @"0";

    if (self.biometric.entryId == 0) {

         if ([[HealthKitService sharedInstance] isServiceAccessible]) {

             if (metric.mId == 1) { //weight
                 HKQuantitySample * userWeight = [[HealthKitService sharedInstance] usersWeight];
                 if (userWeight != nil) {

                     NSLog(@"user weight: %@", userWeight);

                     // metric
                     if (unit.uId == 1) {
                         float kg =  ([userWeight.quantity doubleValueForUnit:[HKUnit gramUnit]] / 1000.0f);
                         self.amount.text = [NSString stringWithFormat:@"%.1f", kg];
                     } else {
                         float pounds = ([userWeight.quantity doubleValueForUnit:[HKUnit poundUnit]]);
                         self.amount.text = [NSString stringWithFormat:@"%.1f", pounds];
                     }
                 }
             } else if (metric.mId == 2) { //height
                 HKQuantitySample * usersHeight = [[HealthKitService sharedInstance] usersHeight];
                 if (usersHeight != nil) {

                     NSLog(@"user height: %@", usersHeight);
                     // metric
                     if (unit.uId == 3) {
                         float cm =  ([usersHeight.quantity doubleValueForUnit:[HKUnit meterUnit]] * 100.0f);
                         self.amount.text = [NSString stringWithFormat:@"%.1f", cm];
                     } else {
                         float inch = ([usersHeight.quantity doubleValueForUnit:[HKUnit inchUnit]]);
                         self.amount.text = [NSString stringWithFormat:@"%.1f", inch];
                     }
                 }
             }
         } else {
             if (metric.mId == 1) { //weight
                 double userWeight = [[WebQuery singleton] weightInPreferredUnit];
                 NSLog(@"user weight: %f", userWeight);
                 self.amount.text = [NSString stringWithFormat:@"%.1f", userWeight];//                 }
             } else if (metric.mId == 2) { //height
                 double usersHeight = [[WebQuery singleton] heightInPreferredUnit];
                 NSLog(@"user height: %f", usersHeight);
                 // metric
                 self.amount.text = [NSString stringWithFormat:@"%.1f", usersHeight];
             }
             
         }
     }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height < 500) {
      [Toolbox moveView: self.view up: 70];
   }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
   if (component == 0)
      return 210;
   return 90;
}
 
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//   if (component == 0) {
//      // TODO: Rememeber last unit chosen for each metric.
//      [metricPicker reloadComponent:1];
//   }
    
    

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
   return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//   if (component == 0) {
//      return [metrics count];
//   } else {
    if (metrics == nil) {
        return 0;
    }
    if ([metrics count] <= metricSelectedIndex) {
        return 0;
    }
    Metric *metric = [metrics objectAtIndex: metricSelectedIndex];
    if (metric == nil) {
        return 0;
    } else {
        return [[metric units] count];
    }
   return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//   if (component == 0) {
//      Metric *metric = [metrics objectAtIndex: row];
//      return metric.name;
//   } else {
      Metric *metric = [metrics objectAtIndex: metricSelectedIndex];
      if (row < [[metric units] count]) {
         return [[[metric units] objectAtIndex: row] description];      
      } else {
         return @"?";
      }
//   }
}

#pragma mark -
#pragma mark TableViews Datasource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == TAG_BIOMETRIC_MEASURE_LIST) {
        if (metrics != nil) {
            return [metrics count];
        }
        return 0;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:measureCell];
    cell.textLabel.text = @"?";
    if (tableView.tag == TAG_BIOMETRIC_MEASURE_LIST) {
        cell = [tableView dequeueReusableCellWithIdentifier:measureCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:measureCell];
        }
        if (metrics != nil) {
            Metric *metric = [metrics objectAtIndex: indexPath.row];

            cell.textLabel.text = metric.name;
            if (metricSelectedIndex == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.text = @"?";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == TAG_BIOMETRIC_MEASURE_LIST) {
        if (metricSelectedIndex != indexPath.row) {
            metricSelectedIndex = indexPath.row;
            Metric *metric = [metrics objectAtIndex: indexPath.row];
            [measureButton setTitle:metric.name forState:UIControlStateNormal];
            [metricPicker reloadAllComponents];
//        Food *food = [[WebQuery singleton] getFood: serving.foodId];
//        Measure *measure = [[food measures] objectAtIndex: indexPath.row];
//        [serving amount: [serving amount] withMeasure: measure.mId];
//        [self updateValues];
        }
        [self.navigationController popViewControllerAnimated: YES];
        [self updateUnitPicker];
    } else {
//        [self showMeasureChooser: self];
    }
}
- (IBAction)selectMeasures:(id)sender {
    if (self.biometric.entryId > 0) {
        return;
    }
    UITableView *mView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    mView.delegate = self;
    mView.dataSource = self;
    UIViewController *measureController = [[UIViewController alloc] init];
    
    measureController.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];measureController.view = mView;
    measureController.view.tag = TAG_BIOMETRIC_MEASURE_LIST;
    [self.navigationController pushViewController:measureController animated:YES];
}

@end
