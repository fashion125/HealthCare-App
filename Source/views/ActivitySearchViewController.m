//
//  ActivitySearchViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "ActivitySearchViewController.h" 
#import "AddExerciseViewController.h" 
#import "FoodSearchTableViewCell.h"
#import "WebQuery.h" 
#import "Utils.h"
#import "SWNinePatchImageFactory.h"

@implementation ActivitySearchViewController
 
static NSArray* topActivities = nil;

@synthesize resultsTable;
@synthesize searchBar;
@synthesize results; 
@synthesize diaryVC;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
  
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
} 

- (void)didReceiveMemoryWarning {
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   Activity *hit = [results objectAtIndex: [indexPath row]];
   if (hit != nil) {
//      AddExerciseViewController *aViewController = [[AddExerciseViewController alloc] initWithNibName:@"AddExerciseViewController" bundle:[NSBundle mainBundle]];
       AddExerciseViewController* addExerciseVC = (AddExerciseViewController*) [Utils newViewControllerWithId:@"addExerciseVC"  In: @"Main1"];
      addExerciseVC.diaryVC = diaryVC;
       [addExerciseVC initExercise];
      [addExerciseVC activity: hit];
   
      [self.navigationController pushViewController: addExerciseVC animated:YES];
   }
}

- (void) loadTopActivities {
   if (!topActivities) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         NSArray *res = [[WebQuery singleton] topActivities];
         dispatch_async(dispatch_get_main_queue(), ^{
            topActivities = res;
            [self loadTopActivities];
         });
      });
   } else if (!self.results) {
      self.results = [topActivities copy];
      [self.resultsTable reloadData];
   }
} 


#pragma mark - View lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
   // Do any additional setup after loading the view from its nib.
   [self loadTopActivities];
    UIImage* resizableImage = [SWNinePatchImageFactory createResizableNinePatchImageNamed:@"searchbox1.9"];
    [self.searchbarBack setImage: resizableImage];
   [self.searchbar becomeFirstResponder];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.tapView addGestureRecognizer:tap];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidShow:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidHide:)
//                                                 name:UIKeyboardDidHideNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        id _obj = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect _keyboardFrame = CGRectNull;
        if ([_obj respondsToSelector:@selector(getValue:)]) [_obj getValue:&_keyboardFrame];
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.resultsTable setContentInset:UIEdgeInsetsMake(0.f, 0.f, _keyboardFrame.size.height, 0.f)];
        } completion:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.resultsTable setContentInset:UIEdgeInsetsZero];
        } completion:nil];
    }];
}

- (void)viewDidUnload {
   [self setSearchBar:nil];
   [self setResultsTable:nil];
   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}
-(void)dismissKeyboard {
    [self.searchbar resignFirstResponder];
}
- (void)keyboardDidShow: (NSNotification *) notif{
    // Do something here
    
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    
}
 
#pragma mark -


- (void) search: (NSString *)str {
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      self.results = [[WebQuery singleton] findActivities: str];
      dispatch_async(dispatch_get_main_queue(), ^{
         [self.resultsTable reloadData];
      });
   });
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   // TODO: Replace with custom activity cell
   static NSString *CellIdentifier = @"resueActivitySearchTableViewCell";
	
   FoodSearchTableViewCell *cell = (FoodSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
   if (cell == nil) {      
      NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil]; 
      for (id currentObject in topLevelObjects) {
         if(currentObject && [currentObject isKindOfClass:[FoodSearchTableViewCell class]]) {
            cell = (FoodSearchTableViewCell *)currentObject;
            break;
         }
      }
      cell.accessoryType = UITableViewCellAccessoryNone;
   }
   
   if (self.results != nil && self.results.count > indexPath.row) {       
      Activity *hit = [results objectAtIndex:indexPath.row];
      cell.title.text = [hit description];
       cell.subtitle.text = hit.category;
   }
   return cell;
}

#pragma mark -
#pragma mark search bar delegate calls

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {   
   [self.navigationController popViewControllerAnimated:YES]; 
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   if ([searchText length] >= 3) {
      [self search: searchText];
   } else {
      self.results = [NSArray array];
      [self.resultsTable reloadData];
   }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString* searchText = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([searchText length] >= 3) {
        [self search: searchText];
    } else if ([searchText length] <= 0) {
        self.results = [topActivities copy];
        [self.resultsTable reloadData];
        
    } else {
        self.results = [topActivities copy];
        [self.resultsTable reloadData];
        //        self.results = [NSArray array];
        //        [self.resultsTable reloadData];
    }    return YES;
}
#pragma mark -




@end
