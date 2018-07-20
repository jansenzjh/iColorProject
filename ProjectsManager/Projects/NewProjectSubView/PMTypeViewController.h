//
//  PMTypeViewController.h
//  ProjectsManager
//
//  Created by Jansen on 1/11/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTWButton.h"

@protocol PMTypeViewControllerDelegate <NSObject>

-(void)typeSelected:(NSString *)title;

@end

@interface PMTypeViewController : UIViewController

@property (nonatomic, strong) id<PMTypeViewControllerDelegate> delegate;

@end
