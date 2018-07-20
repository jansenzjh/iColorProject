//
//  PMViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/4/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLNoteViewController.h"
#import "PMProjectPannelViewController.h"
#import "PMAppDelegate.h"
#import "Projects.h"
#import "FTWButton.h"
#import "PMEditNewProjectViewController.h"
#import "SDBrowserViewController.h"

@interface PMViewController : KLNoteViewController<NSFetchedResultsControllerDelegate, PMProjectPannelViewControllerDelegate, SDBrowserViewControllerDelegate>

@property (strong, nonatomic)NSMutableArray *projectList;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong)NSString *browserURL;

-(void)reloadProjectsView;

@end
