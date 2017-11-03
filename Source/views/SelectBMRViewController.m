//
//  SelectBMRViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 7/16/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "SelectBMRViewController.h"
#import "SettingViewController.h"

@interface SelectBMRViewController ()
@property (readwrite, strong) NSIndexPath* lastIndexPath;
@property (readwrite) double mSetBmr;
@end

@implementation SelectBMRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mSetBmr = ((SettingViewController*)self.setting).mSetBmr;
    self.title = @"Select your BMR";
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
    return [self.mBMRValues count];
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = @"reuseBMR";
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
    UILabel* label = (UILabel*)[cell viewWithTag:7160];
    [label setText:[self.mBMRTitles objectAtIndex:indexPath.row]];
    
    if (self.lastIndexPath==nil) {
        NSInteger irow = indexPath.row;
        if (self.mSetBmr == [[self.mBMRValues objectAtIndex:irow] doubleValue]) {
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
    ((SettingViewController*)(self.setting)).mSetBmr = [[self.mBMRValues objectAtIndex:indexPath.row] doubleValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        [((SettingViewController*)(self.setting)) refreshData];
    });
}
@end
