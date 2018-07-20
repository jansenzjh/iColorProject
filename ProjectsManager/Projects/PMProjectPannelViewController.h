//
//  PMProjectPannelViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/4/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMAppDelegate.h"
#import "Projects.h"
#import "KOTabs.h"
#import "KOTabView.h"
#import "BButton.h"
#import "PMTodoListDetailViewController.h"
#import "iCarousel.h"
#import "TimeClock.h"
#import "PMTimeClockTableViewController.h"
#import "PMNoteView.h"
#import "PMNoteViewController.h"
#import <MessageUI/MessageUI.h>
#import "KioskDropboxPDFBrowserViewController.h"
#import "PMDocTableViewController.h"
#import <QuickLook/QuickLook.h>
#import "NDHTMLtoPDF.h"
#import "SDMapViewController.h"


typedef NS_OPTIONS(NSUInteger, DBDatabaseUpdateStatus) {
    DBDatabaseUpdateStatusUpdate = 0,
    DBDatabaseUpdateStatusDelete = 1
};

@class PMProjectPannelViewController;

@protocol PMProjectPannelViewControllerDelegate <NSObject>

-(void)reloadProjectAfterDelete;

@end

@interface PMProjectPannelViewController : UIViewController<PMTodoListDetailViewControllerDelegate, UITextViewDelegate, PMNoteViewControllerDelegate, MFMailComposeViewControllerDelegate, KioskDropboxPDFBrowserViewControllerUIDelegate, DBRestClientDelegate, PMDocTableViewControllerDelegate,UIActionSheetDelegate, NDHTMLtoPDFDelegate, SDMapViewControllerDelegate>

//Title Labels

@property (weak, nonatomic) IBOutlet UILabel *lblProjPriority;
@property (weak, nonatomic) IBOutlet UILabel *lblProjType;
@property (weak, nonatomic) IBOutlet UILabel *lblProjTimeNeed;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeSpent;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeSpentTextValue;
@property (weak, nonatomic) IBOutlet UILabel *lblProjDueDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDaysLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblTaskNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblTaskTotalhour;
@property (weak, nonatomic) IBOutlet UILabel *lblTaskTotalhourValueUnit;


//Value Lables
@property (weak, nonatomic) IBOutlet UILabel *lblProjNameValue;
@property (weak, nonatomic) IBOutlet UILabel *lblProjDescValue;
@property (weak, nonatomic) IBOutlet BButton *btnProjPriorityValueOutlet;
@property (weak, nonatomic) IBOutlet UILabel *lblProjTypeValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTNValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTNTextValue;
@property (weak, nonatomic) IBOutlet UILabel *lblProjDueDateValue;
@property (weak, nonatomic) IBOutlet UILabel *lblDaysLeftValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTaskNumberValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTaskTotalhourValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeSpentNumberValue;


#pragma mark - buttons
//time clock button
@property (nonatomic, strong) FTWButton *btnTimeClock;
@property (nonatomic, strong) FTWButton *btnCamera;


//todolist button
@property (weak, nonatomic) IBOutlet BButton *btnAddTodoListOutlet;
- (IBAction)btnAddTodoList:(BButton *)sender;


//budget button
//@property (weak, nonatomic) IBOutlet BButton *btnBudgetOutlet;
//- (IBAction)btnBudget:(BButton *)sender;

//document button
@property (weak, nonatomic) IBOutlet BButton *btnDocOutlet;
- (IBAction)btnDoc:(BButton *)sender;

//email button
- (IBAction)btnEmailNote:(UIButton *)sender;


#pragma mark - Tables
@property (weak, nonatomic) IBOutlet UITableView *timeClockTable;
@property (strong, nonatomic) PMTimeClockTableViewController *timeClockTVC;

@property (weak, nonatomic) IBOutlet UITableView *docTable;
@property (strong, nonatomic) PMDocTableViewController *docTVC;

//segue

//Carousel
@property (weak, nonatomic) IBOutlet iCarousel *carousel;


//Note
@property (weak, nonatomic) IBOutlet PMNoteView *txtNoteView;

//Delegate
@property (strong, nonatomic)id<PMProjectPannelViewControllerDelegate>delegate;

//PDF
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

//HUD
@property (nonatomic,strong) MBProgressHUD *HUD;

@end
