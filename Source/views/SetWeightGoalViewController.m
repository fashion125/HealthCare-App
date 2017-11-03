//
//  SetWeightGoalViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 7/15/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "SetWeightGoalViewController.h"
#import "SettingViewController.h"

@interface SetWeightGoalViewController ()
@property (readwrite, strong) NSIndexPath* lastIndexPath;
@property (readwrite) double mWeightGoal;
@end

@implementation SetWeightGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Set your weight goal";
    self.mWeightGoal = ((SettingViewController*)(self.setting)).mWeightGoal;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (self.currentQuestion == 4)
    //        return 96;
    //    if ([UIScreen is35Inch]) {
    //        return 76;
    //    }
    return 44;//tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mWeightGoalValues count];
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = @"reuseWeightGoalsCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:reuseId owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if(currentObject && [currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (UITableViewCell *)currentObject;
                break;
            }
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    UILabel* label = (UILabel*)[cell viewWithTag:7150];
    [label setText:[self.mWeightGoalTitles objectAtIndex:indexPath.row]];

    if (self.lastIndexPath==nil) {
        NSInteger irow = indexPath.row;
        if (self.mWeightGoal == [[self.mWeightGoalValues objectAtIndex:irow] doubleValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastIndexPath = indexPath;
        }
    } else if (self.lastIndexPath != nil) {
        if ([indexPath compare:self.lastIndexPath] == NSOrderedSame) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.lastIndexPath = indexPath;
    [tableView reloadData];
    ((SettingViewController*)(self.setting)).mWeightGoal = [[self.mWeightGoalValues objectAtIndex:indexPath.row] doubleValue];

    dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            [((SettingViewController*)(self.setting)) refreshData];
    });
}

@end
