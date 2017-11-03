//
//  AddNoteViewController.m
//  Cronometer
//
//  Created by Boris Esanu on 29/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "AddNoteViewController.h"

#import "WebQuery.h"
#import "Utils.h"

@implementation AddNoteViewController

@synthesize noteTextView;
@synthesize diaryVC;
@synthesize note;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.note = [[Note alloc] init];
    }
    return self;
}

- (void) initNote{
    if (self) {
        self.note = [[Note alloc] init];
    }
}
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    self.dlgView.layer.cornerRadius = 5;
    self.dlgView.layer.masksToBounds = YES;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo-title-navbar"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.dlgView addGestureRecognizer: tap];

   if (self.note.entryId != 0) {
      self.titleLabel.text = @"Edit Note";
       [self.btnSave setTitle:@"EDIT NOTE" forState:UIControlStateNormal];
   } else {
      self.titleLabel.text = @"Add Note to Diary";
       [self.btnSave setTitle:@"ADD NOTE" forState:UIControlStateNormal];
   }
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target:self action:@selector(save:)];
//   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    noteTextView.text = note.text;
    if ([Utils isIPhone6] || [Utils isIPhone6s] || [Utils isIPhone5] || [Utils isIPhone5s] || [Utils isIPad]) {
        
        [noteTextView becomeFirstResponder];
    }

}
-(void)dismissKeyboard {
    [self.noteTextView resignFirstResponder];
}
- (void)viewDidUnload {
   [self setNote:nil];
   [self setNoteTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)save:(id)sender {
   [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
   
    note.text = noteTextView.text;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.btnSave.enabled = NO;
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      if (note.entryId == 0) {
         note.day = [diaryVC currentDay];
         [diaryVC setOrderForNewDiaryEntry: note];
         [[WebQuery singleton] addNote: note];
         dispatch_async(dispatch_get_main_queue(), ^{         
            [self.diaryVC entryAdded: note];
            [self.navigationController popToViewController: self.diaryVC animated:YES];
             
             self.navigationItem.rightBarButtonItem.enabled = YES;
             self.btnSave.enabled = YES;
         });
      } else {
         [[WebQuery singleton] editNote: note];
         dispatch_async(dispatch_get_main_queue(), ^{         
            [self.diaryVC entryChanged: note];
             [self.navigationController popToViewController: self.diaryVC animated:YES];
             self.navigationItem.rightBarButtonItem.enabled = YES;
             self.btnSave.enabled = YES;
         });
      }
   }); 
}

 - (IBAction)cancel:(id)sender {
   [self.navigationController popViewControllerAnimated: YES]; 
}

 

@end
