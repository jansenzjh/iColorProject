//
//  PMTimeClockTableViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/20/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeClock.h"
#import "PMAppDelegate.h"
#import "BlocksKit.h"

@interface PMTimeClockTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong)NSString *projName;

@end
