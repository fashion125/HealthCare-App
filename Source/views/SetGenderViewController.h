//
//  SetGenderViewController
//  Cronometer
//
//  Created by Boris Esanu on 31/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetGenderViewController : BaseViewController {

}

- (IBAction)male:(id)sender;
- (IBAction)female:(id)sender;
- (IBAction)femalePreggers:(id)sender;
- (IBAction)femaleMilky:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (readwrite) id diaryVC;
@end
