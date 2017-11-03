//
//  PushNoAnimation.m
//  Cronometer
//
//  Created by Boris Esanu on 7/2/15.
//  Copyright (c) 2015 cronometer.com. All rights reserved.
//

#import "PushNoAnimation.h"

@implementation PushNoAnimation

- (void)perform {
    UIViewController *source = self.sourceViewController;
    UIViewController *destination = self.destinationViewController;
    [source.navigationController pushViewController:destination animated:NO];
}

@end
