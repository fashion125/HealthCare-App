//
//  AddServingViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 28/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "AddServingViewController.h"

#import "TargetSummaryViewController.h"
#import "WebQuery.h"
#import "NutrientInfo.h"
#import "Formatter.h"
#import "Toolbox.h"
#import "Utils.h"

#define TAG_DEFAULT        0
#define TAG_MEASURE_LIST   1

@implementation AddServingViewController
@synthesize proteinLabel;
@synthesize carbsLabel;
@synthesize fatLabel;

@synthesize measureButton;
@synthesize macroChart;
@synthesize amount, foodNameLabel, sliderBar, caloriesLabel, serving, diaryVC, measureChooser, categoryLabel, addRecipeVC;

static NSString* const disclosureCell = @"DisclosureCell";
static NSString* const measureCell = @"MeasureCell";
 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.serving = [[Serving alloc] init];
   }
   return self;
}


- (void)didReceiveMemoryWarning {
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
    isLoaded = NO;
   // self.serving = [[Serving alloc] init];
   if (self.serving.entryId != 0) {
      [self.btnSave setTitle: @"EDIT SERVING" forState: UIControlStateNormal] ;

   } else {
      [self.btnSave setTitle:@"ADD SERVING" forState:UIControlStateNormal] ;

   }
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.dlgView addGestureRecognizer: tap];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    if ([Utils isIPhone6] || [Utils isIPhone6s] /*|| [Utils isIPhone5] || [Utils isIPhone5s]*/ || [Utils isIPad]) {
        
        [self.amount becomeFirstResponder];
    }

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isLoaded == NO && self.serving.entryId==0) {
        [self.btnMoreDetails setEnabled: NO];
        [self.measureButton setEnabled: NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Food *food = [[WebQuery singleton] getFood: self.serving.foodId];///Here, I will work to get SearchHit object for checking if custom or not later
            [self.serving amount: 1 withMeasure: food.prefMeasureId];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.foodNameLabel.text = food.name;
                self.categoryLabel.text = [food categoryName];
                [self updateValues: FALSE];
                [self updatePieChart];
                [measureChooser reloadData];
                isLoaded = YES;
                [self.btnMoreDetails setEnabled: YES];
                [self.measureButton setEnabled: YES];
            });
        });
    }
}
-(void)dismissKeyboard {
    [self.amount resignFirstResponder];
}
- (void)viewDidUnload {
   [self setFoodNameLabel:nil];
   [self setCategoryLabel:nil];
   [self setAmount:nil];
   [self setSliderBar:nil];
   [self setCaloriesLabel:nil];
   [self setMeasureButton:nil];
   [self setMacroChart:nil];
   [self setProteinLabel:nil];
   [self setCarbsLabel:nil];
   [self setFatLabel:nil];
   [super viewDidUnload]; 
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self.macroChart setThinArcs];
    
   if (serving.entryId != 0) {///Here, I will work to get SearchHit object for checking if custom or not later
      self.foodNameLabel.text = [[serving food] name];
      self.categoryLabel.text = [[serving food] categoryName];
  //    self.amount.text = nil;
      self.amount.placeholder = [Formatter formatAmount: [serving amount]];
      [self updateValues: FALSE];
      [self updatePieChart];
   } else {      
      self.amount.placeholder = [Formatter formatAmount:1.0];
   }

//   [amount becomeFirstResponder];
   [measureChooser reloadData];
   [super viewWillAppear: animated];
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation button was pressed. Do some stuff
        //[self.navigationController popViewControllerAnimated:NO];
    }
    [super viewWillDisappear:animated];
}
- (void) updateValues {
    [self updateValues: TRUE];
}

-(void) setFood: (long) foodId {
    self.serving.foodId = foodId;
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
- (IBAction)save:(id)sender { 
   [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
   
   NSString *amountText = amount.text; 
   if (amountText == nil || [amountText isEqualToString:@""]) {
      amountText = amount.placeholder;
   }
   
   NSNumber *val = [Formatter numberFromString: amountText];
   [serving amount: [val doubleValue] withMeasure: serving.mId];
   
   __weak __typeof__(self) wself = self;
    if (wself.addRecipeVC != nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.btnSave.enabled = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            // FIXME -- only on success!
            [wself.addRecipeVC addIngredient: wself.serving];
            [wself.navigationController popToViewController: wself.addRecipeVC animated:YES];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.btnSave.enabled = YES;
        });
        
    } else if (wself.diaryVC != nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.btnSave.enabled = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (wself.serving.entryId == 0) {
                wself.serving.day = [wself.diaryVC currentDay];
                [wself.diaryVC setOrderForNewDiaryEntry: wself.serving];
                [[WebQuery singleton] addServing: wself.serving];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // FIXME -- only on success!
                    [wself.diaryVC entryAdded: wself.serving];
                    [wself.navigationController popToViewController: wself.diaryVC animated:YES];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    self.btnSave.enabled = YES;
                });
            } else {
                [[WebQuery singleton] editServing:wself.serving];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // FIXME -- only on success!

                    [wself.diaryVC entryChanged: wself.serving];
                    [wself.navigationController popToViewController: wself.diaryVC animated:YES];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    self.btnSave.enabled = YES;

                });
            }
        });
    }
   
}

- (IBAction)cancel:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
}



- (void)textFieldDidEndEditing:(UITextField *)textField {
   [amount resignFirstResponder];
   NSNumber *val = [Formatter numberFromString: textField.text];
   if (val) {
      [serving amount: [val doubleValue]];
   }
   [self updateValues];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
   NSNumber *val = [Formatter numberFromString:str];
   if (val) {
      [serving amount: [val doubleValue]];
      [self updateValues: FALSE];
   } else {
      [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
      self.amount.textColor = [UIColor redColor];
   }
   return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
   if (theTextField == amount) { 
      NSNumber *val = [Formatter numberFromString:theTextField.text];
      if (val) { 
         [self save: nil];
      } else {
         return NO;
      }
   } 
   return YES;
}
 
// updates UI based on current serving
- (void) updateValues: (BOOL)includeAmount {
   if (includeAmount) {     
      amount.text = [Formatter formatAmount: [serving amount]];  
   }
   self.amount.textColor = [UIColor blackColor];   
   [self.navigationItem.rightBarButtonItem setEnabled:TRUE];
   
   [self.measureButton setTitle: [[serving measure] description]  forState: UIControlStateNormal];
   
   self.caloriesLabel.text = [Formatter formatAmount: [serving calories]];
   self.proteinLabel.text = [Formatter formatAmount: [serving nutrientAmount: PROTEIN]];
   self.carbsLabel.text = [Formatter formatAmount: [serving nutrientAmount: CARBOHYDRATES]];
   self.fatLabel.text = [Formatter formatAmount: [serving nutrientAmount: LIPIDS]];
   
   [sliderBar setMaximumValue: MAX([[serving measure] isGrams]?100:2, serving.amount)]; 
   [sliderBar setValue: [serving amount]];
   
//   [[self amount] selectAll: self];
} 


- (void) updatePieChart {
   double p = [serving nutrientAmount: CALORIES_FROM_PROTEIN];
   double c = [serving nutrientAmount: CALORIES_FROM_CARBOHYDRATES];
   double f = [serving nutrientAmount: CALORIES_FROM_LIPIDS];
   double a = [serving nutrientAmount: CALORIES_FROM_ALCOHOL];

    [self.macroChart clearSlices];
    [self.macroChart setThinArcs];
 
    [self.macroChart addSlice: p color: [PieChart greenColor]];
    [self.macroChart addSlice: c color:  [PieChart blueColor]];
    [self.macroChart addSlice: f color:  [PieChart redColor]];
    [self.macroChart addSlice: a color: [UIColor yellowColor ] ];
}

- (IBAction)showNutrients:(id)sender {
//   TargetSummaryViewController *vc = [[TargetSummaryViewController alloc] initWithNibName:@"TargetSummaryViewController" bundle:[NSBundle mainBundle]];
    TargetSummaryViewController* targetSummaryVC = (TargetSummaryViewController*)[Utils newViewControllerWithId:@"targetSummaryVC" In: @"Main1"];
   targetSummaryVC.title = [serving foodName];
    [targetSummaryVC setIsFromDiary: NO];
    targetSummaryVC.serving = serving;
    targetSummaryVC.foodSearchVC = self.foodSearchVC;
    targetSummaryVC.diaryVC = self.diaryVC;
   [self.navigationController pushViewController:targetSummaryVC animated:YES];

   // make sure nutrients are loaded, then refresh table view
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[WebQuery singleton] loadNutrients];
      dispatch_async(dispatch_get_main_queue(), ^{
         [targetSummaryVC loadData];
         [targetSummaryVC setAmountsFromServing:serving];
      });
   });   
}

- (IBAction) sliderValueChanged:(UISlider *)sender {
   [serving amount: round([sliderBar value]*10.0)/10.0];
   [self updateValues];
} 

#pragma mark -
#pragma mark NavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
   if (viewController == self) {
      [self.measureChooser deselectRowAtIndexPath:[measureChooser indexPathForSelectedRow] animated:NO];
   }
}

#pragma mark -
#pragma mark TableViews Datasource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   if (tableView.tag == TAG_MEASURE_LIST) {
      if (serving) {
         Food *food = [[WebQuery singleton] getFood: serving.foodId];
         return [[food measures] count];
      } 
      return 0;
   } else {
      return 1;
   }
}

- (NSString *) formatGrams:(double)grams {
//   if (grams < 2) {
//      return [NSString stringWithFormat:@"%.00f g", grams];
//   } else {
      return [NSString stringWithFormat:@"%.0f g", grams];
//   }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:measureCell];
   cell.textLabel.text = @"?";
   if (tableView.tag == TAG_MEASURE_LIST) {
      cell = [tableView dequeueReusableCellWithIdentifier:measureCell];
      if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:measureCell];
      }
      if (serving) {
         Food *food = [[WebQuery singleton] getFood: serving.foodId];
         Measure *thisMeasure = [[food measures] objectAtIndex: indexPath.row];
         cell.textLabel.text = [thisMeasure description];
         if (!thisMeasure.isGrams && !thisMeasure.volumetric) {
            cell.detailTextLabel.text = [self formatGrams: [thisMeasure grams]];
         }
         if (thisMeasure == [serving measure]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
         }
      } else {
         cell.textLabel.text = @"?";
      }
   } else {
      cell = [tableView dequeueReusableCellWithIdentifier:disclosureCell];
      if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:disclosureCell];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      cell.textLabel.text = [serving.measure description];
      if (!serving.measure.isGrams) {
         cell.detailTextLabel.text = [self formatGrams: [serving.measure grams]];
      }
   }
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (tableView.tag == TAG_MEASURE_LIST) {
      Food *food = [[WebQuery singleton] getFood: serving.foodId];
      Measure *measure = [[food measures] objectAtIndex: indexPath.row];
      [serving amount: [serving amount] withMeasure: measure.mId];
      [self updateValues];      
      [self.navigationController popViewControllerAnimated: YES];
   } else {
      [self showMeasureChooser: self];
   }
}

-(void) showMeasureChooser:(id)sender {
   UITableView *mView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
   mView.delegate = self;
   mView.dataSource = self;
   UIViewController *measureController = [[UIViewController alloc] init];
//   measureController.title = @"Unit";
    
    measureController.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];measureController.view = mView;
   measureController.view.tag = TAG_MEASURE_LIST;
   [self.navigationController pushViewController:measureController animated:YES];
}



@end
