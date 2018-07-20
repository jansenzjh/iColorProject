//
//  SDBrowserViewController.m
//  SimpleDrawing
//
//  Created by Jansen on 11/14/12.
//  Copyright (c) 2012 Nathanial Woolls. All rights reserved.
//

#import "SDBrowserViewController.h"
#import "UIActionSheet+BlocksKit.h"
#import "MBProgressHUD.h"

@interface SDBrowserViewController ()
@property UIImage *returnImage;
@end

@implementation SDBrowserViewController


@synthesize loadingIndicator;
@synthesize txtURL;
@synthesize webTitle;
@synthesize webViewbser;
@synthesize url;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"browser project list"]) {
        PMProjectListLiteViewController *pjltvc = [segue destinationViewController];
        [pjltvc setPageName: self.webTitle.text];
        [pjltvc setUrl:self.txtURL.text];
        [pjltvc setWebView:self.webViewbser];
    }
}

#pragma mark - UIWebView Methods and Delegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    
	loadingIndicator.hidden = FALSE;
	[loadingIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *currentURL = webView.request.URL.absoluteString;
	self.txtURL.text = currentURL;
	loadingIndicator.hidden = TRUE;
	[loadingIndicator stopAnimating];
	webTitle.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if ([error code] != -999) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		[alert show];
	}
    
	[self webViewDidFinishLoad:webView];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSString *urlString;
	
	if ([textField.text rangeOfString:@"://"].length == 0) {
		urlString = [NSString stringWithFormat:@"http://%@", textField.text];
	} else {
		urlString = textField.text;
	}
	
	self.url = [NSURL URLWithString:urlString];
	[webViewbser loadRequest:[[NSURLRequest alloc]initWithURL:self.url]];
	[textField resignFirstResponder];
	return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[textField becomeFirstResponder];
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField.text isEqualToString:@""]) {
		textField.text = [[[webViewbser request] URL] absoluteString];
	}
}
#pragma mark - Get image to drawing view

-(UIImage *)imageFromBrowser{
    return self.returnImage;
}

#pragma mark - GestureRecognizer

-(void)initializeGesture{
    UILongPressGestureRecognizer *gs = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    gs.minimumPressDuration = 1;
    gs.delegate = self;
    [self.view addGestureRecognizer:gs];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        //pop actionsheet
        
        self.returnImage = [self getImageOnLocation:[gestureRecognizer locationInView:self.view]];
        if(self.returnImage){
            [self showBrowserPrompt];
            NSLog(@"Long press detected.");
        }
    }
}    

-(UIImage *)getImageOnLocation:(CGPoint) location{
//    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//    bool pageFlag = [userDefaults boolForKey:@"pageDirectionRTLFlag"];
//    NSLog(@"pageFlag tapbtnRight %d", pageFlag);
    
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", location.x, location.y];
    //NSLog([NSString stringWithFormat:@"%f %f", location.x, location.y ]);
    NSString *urlToSave = [webViewbser stringByEvaluatingJavaScriptFromString:imgURL];
    NSLog(@"urlToSave :%@",urlToSave);
    if (urlToSave.length < 5){
        [self showMessageHUD: NSLocalizedString(@"browser image error", nil)];
        return nil;
    }
    NSURL * imageURL = [NSURL URLWithString:urlToSave];
    
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    return [UIImage imageWithData:imageData];
}

-(void)showBrowserPrompt{
    UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"use this image", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"yes", nil) handler:^{
        [self.delegate browserViewController:self wasDismissed:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil) handler:nil];
    [sheet showInView:self.view];
}


-(void)showMessageHUD:(NSString *)message{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    hud.labelText = message;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud show:YES];
    [hud hide:YES afterDelay:1.5];
}

#pragma mark - View life cycle

-(void)viewDidDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.returnImage = [[UIImage alloc]init];
    loadingIndicator.hidden = TRUE;
    txtURL.delegate = self;
    webViewbser.userInteractionEnabled = TRUE;
    webViewbser.delegate = self;
    [webViewbser loadRequest:[[NSURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:[self getDefaultWebsite]]]];
    //[self showMessageHUD:NSLocalizedString(@"browser start hint", nil)];
    //[self initializeGesture];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
}

-(NSString *)getDefaultWebsite{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if (self.lastURL) {
        return self.lastURL;
    }else if ([language isEqualToString:@"zh"]) {
        return @"http://www.baidu.com/";
    }else{
        return @"https://www.google.com/";
    }
}


- (void)viewDidUnload {
    [self setLoadingIndicator:nil];
    [self setWebTitle:nil];
    [self setTxtURL:nil];
    [self setWebViewbser:nil];
    [super viewDidUnload];
}
- (IBAction)btnFinishBrowse:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate browserViewController:self wasDismissed:YES];
    }];
}
@end
