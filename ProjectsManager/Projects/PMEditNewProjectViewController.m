//
//  PMEditNewProjectViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/5/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMEditNewProjectViewController.h"

@interface PMEditNewProjectViewController ()

@property NSArray *typeOptionsName;

@property (nonatomic, strong) FTWButton *btnPriority;

@property (nonatomic, strong) FTWButton *btnType;

//model parameter
@property (nonatomic, strong) NSString *pjName;
@property (nonatomic, strong) NSString *pjDesc;
@property (nonatomic, strong) NSString *pjPriority;
@property (nonatomic, strong) NSString *pjType;
@property (nonatomic, strong) NSString *pjTimeNeedText;
@property (nonatomic, strong) NSNumber *pjTimeNeedValue;
@property (nonatomic, strong) NSDate *pjDueDate;

@end

@implementation PMEditNewProjectViewController

@synthesize delegate;
@synthesize priorityDropdownView;
@synthesize btnPriority;
@synthesize btnType;
@synthesize popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.txtProjName becomeFirstResponder];
	
    [self localizeUILabel];
    
    [self initializeDueDatePicker];
    
    [self initializeTimeNeedSegment];
    
    [self initializePriorityButton];
    
    [self initializeTypeButton];
    
    [self initSelfData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)localizeUILabel{
    self.theNavItem.title = NSLocalizedString(@"new project", nil);
    self.lblProjName.text = NSLocalizedString(@"project name", nil);
    self.lblProjDesc.text = NSLocalizedString(@"project description", nil);
    self.lblProjPriority.text = NSLocalizedString(@"priority", nil);
    self.lblProjType.text = NSLocalizedString(@"type", nil);
    self.lblProjDueDate.text = NSLocalizedString(@"due date", nil);
    self.lblProjTimeNeed.text = NSLocalizedString(@"time need", nil);
}


-(void)saveProjectToDatabase{
    
    NSManagedObjectContext* managedObjectContext = [(PMAppDelegate *)[[UIApplication sharedApplication]delegate] managedObjectContext];
    Projects *proj = [NSEntityDescription insertNewObjectForEntityForName:@"Projects" inManagedObjectContext:managedObjectContext];
    
    proj.name = self.txtProjName.text;
    proj.desc = self.txtProjDesc.text;
    proj.type = self.pjType;
    proj.priority = self.pjPriority;
    proj.projStartDate = [NSDate date];
    proj.projModifiedDate = [NSDate date];
    proj.projDueDate = self.pjDueDate;
    proj.timeNeedText = self.pjTimeNeedText;
    proj.timeNeedValue = self.pjTimeNeedValue;
    [managedObjectContext save:nil];
}


#pragma mark - ActionSheet AlertSheet HUD

- (IBAction)btnCancelEditNewProject:(UIBarButtonItem *)sender {
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"cancel comfrim", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"back to edit", nil)
                                         destructiveButtonTitle:NSLocalizedString(@"cancel this edit", nil)
                                              otherButtonTitles:NSLocalizedString(@"back to edit", nil), nil];
    
    [action showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showInfoHUD:(NSString*)message delay:(float)delaySecond {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    hud.labelText = message;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud show:YES];
    [hud hide:YES afterDelay:delaySecond];
    
}

#pragma mark - Initialization

-(void)initSelfData{
    //self.pjName = @"";
    //self.pjDesc = @"";
    self.pjPriority = @"";
    self.pjType = @"";
    self.pjTimeNeedText = @"Weeks";
    self.pjTimeNeedValue = [NSNumber numberWithInt:1];
    self.pjDueDate = [NSDate date];
}

-(void)initializeDueDatePicker{
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startSunday];
    self.calendar = calendar;
    calendar.delegate = self;
    calendar.shouldFillCalendar = YES;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    [calendar setDateBackgroundColor:[UIColor grayColor]];
    calendar.frame = CGRectMake(200, 350, 240, 200);
    [self.view addSubview:calendar];
}

-(void)initializeTimeNeedSegment{
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                                            @[NSLocalizedString(@"weeks", nil),
                                            NSLocalizedString(@"days", nil),
                                            NSLocalizedString(@"hours", nil),
                                            NSLocalizedString(@"minutes", nil)]];
    [segmentedControl setSelectionIndicatorHeight:4.0f];
    [segmentedControl setBackgroundColor:[UIColor darkGrayColor]];
    [segmentedControl setTextColor:[UIColor whiteColor]];
    [segmentedControl setSelectionIndicatorMode:HMSelectionIndicatorFillsSegment];
    [segmentedControl setSegmentEdgeInset:UIEdgeInsetsMake(0, 6, 0, 6)];
    [segmentedControl setCenter:CGPointMake(370, 280)];
    [segmentedControl setTag:1];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}



- (void)initializePriorityButton {
    btnPriority = [[FTWButton alloc] init];
	
	btnPriority.frame = CGRectMake(200, 165, 120, 30);
	[btnPriority addGrayStyleForState:UIControlStateNormal];
	[btnPriority setText:NSLocalizedString(@"please select", nil) forControlState:UIControlStateNormal];
    [btnPriority addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnPriority];
}

- (void)initializeTypeButton {
    btnType = [[FTWButton alloc] init];
	
	btnType.frame = CGRectMake(200, 215, 120, 30);
	[btnType addGrayStyleForState:UIControlStateNormal];	
	[btnType setText:NSLocalizedString(@"please select", nil) forControlState:UIControlStateNormal];
	[btnType addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnType];
}

-(void)popPriorityView{
    PMPriorityViewController *controller = [[PMPriorityViewController alloc]init];
    controller.delegate = self;
    popover = [[UIPopoverController alloc]initWithContentViewController:controller];
    popover.popoverContentSize = CGSizeMake(120, 300);
    popover.delegate = self;
    [popover presentPopoverFromRect:CGRectMake(200, 165, 120, 30) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}

-(void)popTypeView{
    PMTypeViewController *controller = [[PMTypeViewController alloc]init];
    controller.delegate = self;
    popover = [[UIPopoverController alloc]initWithContentViewController:controller];
    popover.popoverContentSize = CGSizeMake(120, 230);
    popover.delegate = self;
    [popover presentPopoverFromRect:CGRectMake(200, 215, 120, 30) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}


#pragma mark - Drop Down Selector Delegate

- (void)dropDownControlViewWillBecomeActive:(LHDropDownControlView *)view  {
    //self.tableView.scrollEnabled = NO;
}

- (void)dropDownControlView:(LHDropDownControlView *)view didFinishWithSelection:(id)selection {
    
    NSString *indexString = [NSString stringWithFormat:@"%@", selection ? : NULL];
    
    if (indexString) {
        priorityDropdownView.title = [NSString stringWithFormat:@"%@", [self.typeOptionsName objectAtIndex:[indexString intValue]] ? : NSLocalizedString(@"please select", nil)];
    }
}

#pragma mark - CKCalendarDelegate

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    self.pjDueDate = date;
}

#pragma mark - Delegate

-(void)typeSelected:(NSString *)title{
    self.pjType = title;
    [self.btnType setText:title forControlState:UIControlStateNormal];
    [self.btnType setBackgroundColor:[self getColorByPriorityLetter:@"C3"] forControlState:UIControlStateNormal];
    [self.popover dismissPopoverAnimated:YES];
}

-(void)prioritySelected:(NSString *)title{
    self.pjPriority = title;
    [self.btnPriority setText:title forControlState:UIControlStateNormal];
    [self.btnPriority setBackgroundColor:[self getColorByPriorityLetter:title] forControlState:UIControlStateNormal];
    [self.popover dismissPopoverAnimated:YES];
}


- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
	//NSLog(@"Selected index %i ", segmentedControl.selectedSegmentIndex);
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            self.pjTimeNeedText = NSLocalizedString(@"weeks", nil);
            break;
        case 1:
            self.pjTimeNeedText = NSLocalizedString(@"days", nil);
            break;
        case 2:
            self.pjTimeNeedText = NSLocalizedString(@"hours", nil);
            break;
        case 3:
            self.pjTimeNeedText = NSLocalizedString(@"minutes", nil);
            break;
        default:
            break;
    }
}

#pragma mark - Files|Directory

-(void)createDirectoryForProject{
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.txtProjName.text];
    //NSLog(path);
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
		}
	}
}

#pragma mark - Button Handler

- (IBAction)btnFinishEditNewProject:(UIBarButtonItem *)sender {
    self.pjName = self.txtProjName.text;
    self.pjDesc = self.txtProjDesc.text;
    
    if (![self checkInputValidation]){
        [self showInfoHUD:NSLocalizedString(@"invalid info", nil) delay:2];
        return;
    }
    if ([self isDuplicateProject]) {
        [self showInfoHUD:NSLocalizedString(@"duplicate error", nil) delay:2];
        return;
    }
    [self saveProjectToDatabase];
    
    [self createDirectoryForProject];
    
    [self scheduleNotification];
    
    [self.delegate reloadProjectsView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) buttonTapped:(id)sender {
	if (sender == btnPriority) {
        [self popPriorityView];
	}else if (sender == btnType){
        [self popTypeView];
    }
	
}

- (IBAction)TNSlider:(UISlider *)sender {
    NSInteger progressAsInt = (int)roundf(sender.value);
    self.pjTimeNeedValue = [NSNumber numberWithInt:progressAsInt];
    self.lblTNAmount.text = [NSString stringWithFormat:@"%d", progressAsInt];
}

#pragma mark - Helper

-(BOOL)isDuplicateProject{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Projects" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", self.pjName];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if ([objects count] == 0) {
        return FALSE;
    } else {
        return TRUE;
    }
}

-(BOOL)checkInputValidation{
    if(self.pjName.length == 0 || self.pjDesc.length == 0){
        return NO;
    }
    if(![self isPriorityValid]){
        return NO;
    }
    if(self.pjType.length == 0){
        return NO;
    }
    if(self.pjTimeNeedText.length == 0){
        return NO;
    }
    return YES;
}

-(BOOL)isPriorityValid{
    if([self string:@"A" IsInString:self.pjPriority]){
        return TRUE;
    }else if([self string:@"B" IsInString:self.pjPriority]){
        return TRUE;
    }else if([self string:@"C" IsInString:self.pjPriority]){
        return TRUE;
    }else{
        return FALSE;
    }
}

BOOL isNumeric(NSString *s)
{
    NSScanner *sc = [NSScanner scannerWithString: s];
    if ( [sc scanFloat:NULL] )
    {
        return [sc isAtEnd];
    }
    return NO;
}




-(UIColor *)getColorByPriorityLetter:(NSString *)priority{
    if(priority.length > 2 || priority.length == 0){
        return NULL;
    }else if ([priority rangeOfString:@"A1" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    }else if ([priority rangeOfString:@"A2" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:1 green:0.4 blue:0 alpha:1];
    }else if ([priority rangeOfString:@"A3" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:1 green:0.725 blue:0 alpha:1];
    }else if ([priority rangeOfString:@"B1" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
    }else if ([priority rangeOfString:@"B2" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:0.785 green:1 blue:0 alpha:1];
    }else if ([priority rangeOfString:@"B3" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    }else if ([priority rangeOfString:@"C1" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:0 green:1 blue:0.5 alpha:1];
    }else if ([priority rangeOfString:@"C2" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
    }else if ([priority rangeOfString:@"C3" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:0 green:0.785 blue:1 alpha:1];
    }else{
        return [UIColor whiteColor];
    }
}

-(NSString *)formatThisDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm"];
    return [dateFormatter stringFromDate:date];
}

-(BOOL)string:(NSString *)str IsInString:(NSString *)string{
    NSRange range = [string rangeOfString:str];
    if (range.location < 10) {
        return TRUE;
    }else return FALSE;
}

#pragma mark - Notifications

- (void)scheduleNotification{
        
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [self.pjDueDate dateByAddingTimeInterval:-3600];
    notif.timeZone = [NSTimeZone defaultTimeZone];
    
    NSString *remindText = [NSString stringWithFormat:@"%@", NSLocalizedString(@"notif body", nil)];
    notif.alertBody = remindText;
    notif.alertAction = NSLocalizedString(@"detail", nil);
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = 1;
    notif.repeatInterval = 0;
    
//    NSInteger index = [self.scheduleControl selectedSegmentIndex];
//    switch (index)
//    {
//        case 1:
//            notif.repeatInterval = NSMinuteCalendarUnit;
//            break;
//        case 2:
//            notif.repeatInterval = NSHourCalendarUnit;
//            break;
//        case 3:
//            notif.repeatInterval = NSDayCalendarUnit;
//            break;
//        case 4:
//            notif.repeatInterval = NSMonthCalendarUnit;
//            break;
//        default:
//            notif.repeatInterval = 0;
//            break;
//    }
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:remindText
                                                         forKey:kRemindMeNotificationDataKey];
    notif.userInfo = userDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    [notif release];
}

- (void)showReminder:(NSString *)text
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"reminder", nil)
                                                        message:text delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

@end
