//
//  PMTodoListDetailViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/16/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BButton.h"
#import "SLGlowingTextField.h"
#import "FTWButton.h"
#import "PMPriorityViewController.h"
#import "PMTodoListTableViewController.h"
#import "PMPresetTaskTableViewController.h"
#import "PMAppDelegate.h"
#import "TodoList.h"
#import "PresetTask.h"
#import "PMPresetTaskTableViewController.h"
#import "MBProgressHUD.h"

@class PMTodoListDetailViewController;

@protocol PMTodoListDetailViewControllerDelegate <NSObject>

-(void)reloadTodoListTable;

@end

@interface PMTodoListDetailViewController : UIViewController<UIPopoverControllerDelegate, PMPriorityViewControllerDelegate, PMPresetTaskTableViewControllerDelegate, PMTodoListTableViewControllerDelegate>
//buttons
- (IBAction)btnTodoListDone:(UIBarButtonItem *)sender;
- (IBAction)btnAddTaskButton:(BButton *)sender;
- (IBAction)btnAddPresetTaskButton:(BButton *)sender;



@property (weak, nonatomic) IBOutlet BButton *btnAddTaskOutlet;
@property (weak, nonatomic) IBOutlet BButton *btnAddPresetTaskOutlet;

//text feilds
@property (weak, nonatomic) IBOutlet SLGlowingTextField *txtTodoTask;
@property (weak, nonatomic) IBOutlet SLGlowingTextField *txtPresetTask;

@property(nonatomic, strong)UIPopoverController *popover;

//Labels
@property (weak, nonatomic) IBOutlet UILabel *lblTaskPriority;
@property (weak, nonatomic) IBOutlet UILabel *lblEstTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEstTimeUnit;
@property (weak, nonatomic) IBOutlet UILabel *lblEstTimeValue;

@property (weak, nonatomic) IBOutlet UINavigationItem *todoNavItem;

- (IBAction)estTimeSlider:(UISlider *)sender;

//tables
@property (weak, nonatomic) IBOutlet UITableView *todoListTable;
@property (weak, nonatomic) IBOutlet UITableView *presetTaskTable;

@property (strong,nonatomic) PMTodoListTableViewController *todoListTVC;
@property (strong,nonatomic) PMPresetTaskTableViewController *presetTaskTVC;


//Database
@property (strong, nonatomic)NSString *projectName;

//Delegate
@property (strong, nonatomic)id<PMTodoListDetailViewControllerDelegate> delegate;


@end
