//
//  AddEntriesMenuViewController.m
//  Cronometer
//
//  Created by choe on 11/6/15.
//  Copyright © 2015 cronometer.com. All rights reserved.
//

#import "AddEntriesMenuBgViewController.h"
#import "AddEntriesMenuViewController.h"
#import "DiaryViewController.h"
#import "SWNinePatchImageFactory.h"
#import "Utils.h"

@interface AddEntriesMenuBgViewController ()

@end

@implementation AddEntriesMenuBgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.blurView.backgroundColor = [UIColor blackColor];
    
    AddEntriesMenuViewController* vc = (AddEntriesMenuViewController*) [Utils newViewControllerWithId:@"AddEntriesMenuViewController" In: @"Main"];
        
    vc.view.backgroundColor = [UIColor clearColor];
    vc.bgVC = self;
    [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)cancel {
    [self dismissViewControllerAnimated:NO completion: nil];
}
- (void)addServing {
    DiaryViewController* vc = (DiaryViewController*)self.diaryVC;
    [self dismissViewControllerAnimated:NO completion: ^ {
        [vc addServing: nil];
    }];
}
- (void)addExercise {
    DiaryViewController* vc = (DiaryViewController*)self.diaryVC;
    [self dismissViewControllerAnimated:NO completion: ^ {
        [vc addExercise: nil];
    }];
}
- (void)addBiometric {
    DiaryViewController* vc = (DiaryViewController*)self.diaryVC;
    [self dismissViewControllerAnimated:NO completion: ^ {
        [vc addBiometric: nil];
    }];
}
- (void)addNotes {
    DiaryViewController* vc = (DiaryViewController*)self.diaryVC;
    [self dismissViewControllerAnimated:NO completion: ^ {
        [vc addNote: nil];
    }];
}
- (void)rearrangeEntries {
    DiaryViewController* vc = (DiaryViewController*)self.diaryVC;
    [self dismissViewControllerAnimated:NO completion: ^ {
        [vc rearrangeEntries];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
