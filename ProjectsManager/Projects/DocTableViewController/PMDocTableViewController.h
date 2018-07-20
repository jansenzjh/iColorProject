//
//  PMDocTableViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/25/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@class PMDocTableViewController;

@protocol PMDocTableViewControllerDelegate <NSObject>

-(void)presentPreviewController:(QLPreviewController *)controller;

-(void)reloadDocListTable;

@end

@interface PMDocTableViewController : UITableViewController<QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (strong, nonatomic)NSMutableArray *docList;
@property (strong, nonatomic)NSString *projName;

@property(strong, nonatomic)id<PMDocTableViewControllerDelegate> delegate;

-(void)reloadDocList;

@end
