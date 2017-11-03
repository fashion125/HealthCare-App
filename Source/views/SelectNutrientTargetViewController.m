//
//  SelectNutrientTargetViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 7/15/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "SelectNutrientTargetViewController.h"
#import "SettingViewController.h"
#import "WebQuery.h"
#import "NutrientInfo.h"

@interface SelectNutrientTargetViewController ()
@property (readwrite, strong) NSIndexPath* lastIndexPath;
@property (readwrite) long scrolled_index;
@end

@implementation SelectNutrientTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Select Nutrient Target";
    
    self.nutrients = [[WebQuery singleton] getNutrients];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.nutrientTargetTable scrollToRowAtIndexPath: self.lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    });
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
    return 35;//tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.nutrients count];
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = @"reuseNutrientTarget";
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
    NutrientInfo* ni = (NutrientInfo*)[self.nutrients objectAtIndex:indexPath.row];
    
    [label setText: [ni description]];
    
    if (self.lastIndexPath==nil) {
        if (ni.nId == self.nutrientKey) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastIndexPath = indexPath;
        }
    } else if (self.lastIndexPath != nil) {
        if ([indexPath compare: self.lastIndexPath] == NSOrderedSame) {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        NutrientInfo* ni = (NutrientInfo*)[self.nutrients objectAtIndex:indexPath.row];
        [((SettingViewController*)(self.setting)) resetNutrientTarget:self.index withValue: ni.nId];
        [((SettingViewController*)(self.setting)) refreshData];
    });
}

@end
