//
//  MTBViewController.h
//  MTBBarcodeScannerExample
//
//  Created by Mike Buss on 2/8/14.
//
//

#import <UIKit/UIKit.h>

@interface BarcodeScanViewController : UIViewController
@property(readwrite) NSString* scanned_result;
@property(readwrite) id foodSearchVC;
@end
