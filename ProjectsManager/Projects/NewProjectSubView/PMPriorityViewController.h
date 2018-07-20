//
//  PMPriorityViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/9/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTWButton.h"

@protocol PMPriorityViewControllerDelegate <NSObject>

-(void)prioritySelected:(NSString *)title;

@end

@interface PMPriorityViewController : UIViewController

@property (nonatomic, strong) id<PMPriorityViewControllerDelegate> delegate;

@end
