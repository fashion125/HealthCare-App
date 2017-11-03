//
//  AddNoteViewController.h
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiaryViewController.h"
#import "Note.h"

@interface AddNoteViewController : UIViewController <UITextViewDelegate> {
   UITextView *noteTextView;
   DiaryViewController *__unsafe_unretained diaryVC;
   Note *note;
}

@property (unsafe_unretained) DiaryViewController *diaryVC;
@property (nonatomic, strong) IBOutlet UITextView *noteTextView;
@property (readwrite, strong) Note *note;
@property (strong, nonatomic) IBOutlet UIView *dlgView;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (void) initNote;
@end
