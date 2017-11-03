//
//  MTBViewController.m
//  MTBBarcodeScannerExample
//
//  Created by Mike Buss on 2/8/14.
//
//

#import "BarcodeScanViewController.h"
#import "MTBBarcodeScanner.h"
#import "FoodSearchViewController.h"

@interface BarcodeScanViewController ()

@property (nonatomic, weak) IBOutlet UIView *previewView;

@property (nonatomic, strong) MTBBarcodeScanner *scanner;

@end

@implementation BarcodeScanViewController

#pragma mark - Lifecycle
- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = @"This app does not have permission to use the camera.\nPlease grant the permission.";
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = @"This device does not have a camera.";
    } else {
        message = @"An unknown error occurred.";
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Scanning Unavailable"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setOverlayView];
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
                for (AVMetadataMachineReadableCodeObject *code in codes) {
                    if (code.stringValue/* && [self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound*/) {
                        
                        NSLog(@"Found unique code: %@", code.stringValue);
                        self.scanned_result = code.stringValue;
                        [self dismissViewControllerAnimated:YES completion: ^ {
                            [((FoodSearchViewController*)self.foodSearchVC) scanned_result: self.scanned_result];
                        }];
                    }
               }
            }];
        } else {
            [self displayPermissionMissingAlert];
            self.scanned_result = nil;
            [self dismissViewControllerAnimated:YES completion: ^ {
//                [((FoodSearchViewController*)self.foodSearchVC) scanned_result: self.scanned_result];
            }];
        }
    }];
//    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
//        for (AVMetadataMachineReadableCodeObject *code in codes) {
//            if (code.stringValue/* && [self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound*/) {
//                
//                NSLog(@"Found unique code: %@", code.stringValue);
//                self.scanned_result = code.stringValue;
//                [self dismissViewControllerAnimated:YES completion: ^ {
//                    [((FoodSearchViewController*)self.foodSearchVC) scanned_result: self.scanned_result];
//                }];
//            }
//        }
//    }];
}
-(void) setOverlayView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat ratio = 0.8;
    
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth * 0.10, screenHeight)];
    [left setBackgroundColor:[UIColor blackColor]];
    [left setAlpha:0.6];
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * 0.10, 0, screenWidth * ratio, screenHeight - (screenWidth * ratio*0.75) - (screenHeight - (screenWidth * ratio*0.75)) / 2)];
    [top setBackgroundColor:[UIColor blackColor]];
    [top setAlpha:0.6];
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * 0.9, 0, screenWidth * 0.10, screenHeight)];
    [right setBackgroundColor:[UIColor blackColor]];
    [right setAlpha:0.6];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * 0.10, screenHeight - (screenHeight - screenWidth * ratio*0.75) / 2, screenWidth * ratio, screenHeight - (screenHeight - screenWidth * ratio*0.75) / 2)];
    [bottom setBackgroundColor:[UIColor blackColor]];
    [bottom setAlpha:0.6];
    
    UIView *frame_coloured = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * 0.10, screenHeight - (screenWidth * ratio*0.75) - (screenHeight - (screenWidth * ratio*0.75)) / 2, screenWidth * ratio, screenWidth * ratio*0.75)];
    [frame_coloured setBackgroundColor:[UIColor yellowColor]];
    [frame_coloured setAlpha:0.6];
    
    UIImageView * frame = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth * 0.10, screenHeight - (screenWidth * ratio*0.75) - (screenHeight - (screenWidth * ratio*0.75)) / 2, screenWidth * ratio, screenWidth * ratio*0.75)];
    frame.image = [UIImage imageNamed:@"barcode_frame.png"];
    frame.contentMode = UIViewContentModeScaleToFill;
    
    [self.previewView addSubview:left];
    [self.previewView  addSubview:top];
    [self.previewView  addSubview:right];
    [self.previewView  addSubview:bottom];
    [self.previewView  addSubview:frame];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
}
- (IBAction)cancelPressed:(id)sender {
    self.scanned_result = nil;
    [self dismissViewControllerAnimated:YES completion: nil];
}
- (IBAction)nutritionixLogoPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.nutritionix.com/api"]];
}

#pragma mark - Scanner

- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    }
    return _scanner;
}

#pragma mark - Scanning

- (void)startScanning {
    
}


@end
