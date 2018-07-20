//
//  PMPresetTaskTableViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/18/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresetTask.h"
#import "PMAppDelegate.h"

@class PMPresetTaskTableViewController;

@protocol PMPresetTaskTableViewControllerDelegate <NSObject>

-(void)reloadPresetTaskTable;

-(void)copyTaskToTodoList:(NSString*)task;

@end

@interface PMPresetTaskTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)NSMutableArray *todoList;

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

//@property (nonatomic, strong)NSString *projName;

@property (strong, nonatomic)id<PMPresetTaskTableViewControllerDelegate> delegate;
@end
