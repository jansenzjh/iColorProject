//
//  PMNoteViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/22/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMNoteView.h"
#import "ProjectNote.h"
#import "PMAppDelegate.h"
#import <MessageUI/MessageUI.h>

@class PMNoteViewController;
@protocol PMNoteViewControllerDelegate <NSObject>

-(void)updatePannelNote:(NSString *)note;

@end


@interface PMNoteViewController : UIViewController<MFMailComposeViewControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet PMNoteView *txtViewNote;
@property (strong, nonatomic)NSString *projName;
@property (strong, nonatomic)ProjectNote *theNote;

//Buttons
- (IBAction)btnSaveNote:(UIButton *)sender;
- (IBAction)btnEmailNote:(UIButton *)sender;

//Delegate
@property (strong, nonatomic)id<PMNoteViewControllerDelegate>delegate;

@end
