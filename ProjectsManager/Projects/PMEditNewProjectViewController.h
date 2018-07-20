//
//  PMEditNewProjectViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/5/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SLGlowingTextField.h"
#import "Projects.h"
#import "PMAppDelegate.h"
#import "PMViewController.h"
#import "LHDropDownControlView.h"
#import "CKCalendarView.h"
#import "HMSegmentedControl.h"
#import "FTWButton.h"
#import "PMPriorityViewController.h"
#import "PMTypeViewController.h"
#import "PMAppDelegate.h"


@class PMEditNewProjectViewController;

@protocol PMEditNewProjectViewControllerDelegate <NSObject>

-(void)reloadProjectsView;

@end

@interface PMEditNewProjectViewController : UIViewController<UIActionSheetDelegate, LHDropDownControlViewDelegate, CKCalendarDelegate, UIPopoverControllerDelegate, PMPriorityViewControllerDelegate, PMTypeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblTNAmount;
- (IBAction)TNSlider:(UISlider *)sender;


//label
@property (weak, nonatomic) IBOutlet UILabel *lblProjName;
@property (weak, nonatomic) IBOutlet UILabel *lblProjDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblProjPriority;
@property (weak, nonatomic) IBOutlet UILabel *lblProjType;
@property (weak, nonatomic) IBOutlet UILabel *lblProjTimeNeed;
@property (weak, nonatomic) IBOutlet UILabel *lblProjDueDate;

- (IBAction)btnFinishEditNewProject:(UIBarButtonItem *)sender;
- (IBAction)btnCancelEditNewProject:(UIBarButtonItem *)sender;

//Text Field
@property (weak, nonatomic) IBOutlet SLGlowingTextField *txtProjName;
@property (weak, nonatomic) IBOutlet SLGlowingTextField *txtProjDesc;


//Delegate
@property (strong, nonatomic)id<PMEditNewProjectViewControllerDelegate> delegate;

@property (strong, nonatomic)LHDropDownControlView *priorityDropdownView;
@property(nonatomic, weak) CKCalendarView *calendar;
@property(nonatomic, strong)UIPopoverController *popover;

//- (void)showReminder:(NSString *)text;
@property (weak, nonatomic) IBOutlet UINavigationItem *theNavItem;

@end
