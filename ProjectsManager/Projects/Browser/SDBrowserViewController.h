//
//  SDBrowserViewController.h
//  SimpleDrawing
//
//  Created by Jansen on 11/14/12.
//  Copyright (c) 2012 Nathanial Woolls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMProjectListLiteViewController.h"

@class SDBrowserViewController;

@protocol SDBrowserViewControllerDelegate <NSObject>

-(void)browserViewController:(SDBrowserViewController *)viewController wasDismissed:(BOOL) success;

@end

@interface SDBrowserViewController : UIViewController<UIWebViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UIWebView *webViewbser;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *webTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtURL;
- (IBAction)btnFinishBrowse:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *lastURL;

@property (assign)id <SDBrowserViewControllerDelegate> delegate;

-(UIImage *)imageFromBrowser;
@end
