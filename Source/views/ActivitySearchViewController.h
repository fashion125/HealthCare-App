//
//  ActivitySearchViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiaryEntry.h"
#import "Exercise.h"
#import "DiaryViewController.h"

@interface ActivitySearchViewController  : UIViewController <UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate, UITableViewDelegate> {
   UISearchBar *searchBar;
   UITableView *resultsTable;
   NSArray *results;
   DiaryViewController *__unsafe_unretained diaryVC;
}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *resultsTable;
@property (strong) NSArray *results; 
@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (strong, nonatomic) IBOutlet UITextField *searchbar;
@property (strong, nonatomic) IBOutlet UIImageView *searchbarBack;
@property (strong, nonatomic) IBOutlet UIView *tapView;

@end
