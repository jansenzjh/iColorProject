//
//  PMTodoListTableViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/17/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TodoList.h"
#import "PMAppDelegate.h"
#import "PMCustomCell.h"

@class PMTodoListDetailViewController;
@protocol PMTodoListTableViewControllerDelegate <NSObject>

-(void)reloadTodoListTable;

@end

@interface PMTodoListTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

//@property (nonatomic, strong)NSMutableArray *todoList;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong)NSString *projName;

@property (strong, nonatomic)id<PMTodoListTableViewControllerDelegate> delegate;

@end
