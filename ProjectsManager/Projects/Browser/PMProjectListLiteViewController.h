//
//  PMProjectListLiteViewController.h
//  ProjectsManager
//
//  Created by Jansen on 2/10/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMAppDelegate.h"
#import "Projects.h"
#import "NDHTMLtoPDF.h"
#import "PMCustomCell.h"

@interface PMProjectListLiteViewController : UITableViewController<NDHTMLtoPDFDelegate>

@property (strong,nonatomic)NSMutableArray *projList;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectProj;
@property (strong,nonatomic)NSString *selectedProjName;
@property (strong,nonatomic)NSString *url;
@property (strong,nonatomic)NSString *pageName;
@property (strong,nonatomic)NDHTMLtoPDF *PDFCreator;

@property (strong, nonatomic)UIWebView *webView;
- (IBAction)btnDone:(UIBarButtonItem *)sender;


@end
