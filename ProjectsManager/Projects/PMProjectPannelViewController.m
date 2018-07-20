//
//  PMProjectPannelViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/4/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMProjectPannelViewController.h"

#define NUMBER_OF_LINE 6
#define KEYBOARD_HEIGHT 216

#define kPaperSizeA4 CGSizeMake(595,842)
#define kPaperSizeLetter CGSizeMake(612,792)

@interface PMProjectPannelViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *allTodoList;
@property BOOL _isCamera;
@property (strong) UIPopoverController *popoverController;


@end

@implementation PMProjectPannelViewController

//@synthesize btnBudgetOutlet;
@synthesize btnDocOutlet;
@synthesize btnAddTodoListOutlet;
@synthesize carousel;
@synthesize items;
@synthesize allTodoList;
@synthesize btnTimeClock;
@synthesize txtNoteView;
@synthesize docTable;
@synthesize docTVC;
@synthesize timeClockTable;
@synthesize timeClockTVC;
@synthesize btnCamera;
@synthesize popoverController = __popoverViewController;
@synthesize HUD;

- (void)awakeFromNib
{
    //set up data
    //your carousel should always be driven by an array of
    //data of some kind - don't store data in your item views
    //or the recycling mechanism will destroy your data once
    //your item views move off-screen
   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self initNavBar];
    
    [self localizeUILabel];
    
    [self populateValue:[self getProjectFromDatabase]];
    
    [self initButtons];
    
    [self initTimeClockButtonStyle];
    
    [self initTables];
    
    [self initCarousel];
    
    [self initNoteView];
    
    self._isCamera = FALSE;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"check todo list"]) {
        PMTodoListDetailViewController *todo = [segue destinationViewController];
        [todo setProjectName: self.title];
        [todo setDelegate:self];
    }else if ([[segue identifier]isEqualToString:@"note view"]){
        PMNoteViewController *note = [segue destinationViewController];
        [note setProjName:self.title];
        note.delegate = self;
    }else if ([[segue identifier]isEqualToString:@"map view segue"]){
        SDMapViewController *map = [segue destinationViewController];
        map.delegate = self;
    }
}


#pragma mark - Initialization

-(void)initNavBar{
    Projects *proj = [self getProjectFromDatabase];
    self.navigationController.navigationBar.tintColor = [self getColorByPriorityLetter:proj.priority];
    
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteAlert)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    
    UIBarButtonItem *backupButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"export", nil) style:UIBarButtonSystemItemAction target:self action:@selector(backupProject)];
    self.navigationItem.leftBarButtonItem = backupButton;
}

-(void)initNoteView{
    self.txtNoteView.delegate = self;
    self.txtNoteView.backgroundColor = [UIColor clearColor];
    [self getNoteByProjectName];
}

-(void)initTimeClockButtonStyle{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"TimeClock"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(projName = %@)", self.title];
    [request setPredicate:pred];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"start" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];

    if (objects != NULL && objects.count > 0) {
        TimeClock *tc = objects[0];
        if (tc.start != NULL && tc.end == NULL){
            [self.btnTimeClock setText:NSLocalizedString(@"clock status out", nil) forControlState:UIControlStateNormal];
            [self.btnTimeClock addDeleteStyleForState:UIControlStateNormal];
        }
    }else{
        [self.btnTimeClock setText:NSLocalizedString(@"clock status in", nil) forControlState:UIControlStateNormal];
        [self.btnTimeClock addBlueStyleForState:UIControlStateNormal];
    }
[self modifyTimeSpentLable:objects];
}

-(void)modifyTimeSpentLable:(NSArray *)tcList{
    float sum = 0;
    if (tcList.count > 0) {
        for (int i = 0; i < tcList.count; i++) {
            TimeClock *tc = tcList[i];
            if (tc.end != NULL) {
                NSDate* date1 = tc.start;
                NSDate* date2 = tc.end;
                NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
                double secondsInAnHour = 3600;
                float hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
                sum = sum + hoursBetweenDates;
                
            }
        }
    }
    self.lblTimeSpentNumberValue.text = [NSString stringWithFormat:@"%.1f", sum];
}

-(void)initCarousel{
    carousel.type = iCarouselTypeInvertedTimeMachine;
    allTodoList = [NSMutableArray arrayWithArray:[self getAllTodoListFromDatabase]];
    [carousel reloadData];
}

-(void)initTables{
    timeClockTVC = [[PMTimeClockTableViewController alloc]init];
    timeClockTVC.projName = self.title;
    [timeClockTable setDataSource:timeClockTVC];
    [timeClockTable setDelegate:timeClockTVC];
    timeClockTVC.view = timeClockTVC.tableView;
    
    docTVC = [[PMDocTableViewController alloc]init];
    docTVC.projName = self.title;
    [docTable setDataSource:docTVC];
    [docTable setDelegate:docTVC];
    docTVC.view = docTVC.tableView;
    docTVC.delegate = self;
}

-(void)initButtons{
    
    [btnAddTodoListOutlet setTitle:NSLocalizedString(@"todo list button", nil) forState:UIControlStateNormal];
    [btnAddTodoListOutlet setColor:[UIColor colorWithRed:0.28f green:0.57f blue:0.80f alpha:1.00f]];
    
//    [btnBudgetOutlet setTitle:NSLocalizedString(@"add budget button", nil) forState:UIControlStateNormal];
//    [btnBudgetOutlet setColor:[UIColor colorWithRed:0.28f green:0.57f blue:0.80f alpha:1.00f]];
    
    [btnDocOutlet setTitle:NSLocalizedString(@"add doc button", nil) forState:UIControlStateNormal];
    [btnDocOutlet setColor:[UIColor colorWithRed:0.28f green:0.57f blue:0.80f alpha:1.00f]];
    
    [self initBtnTimeClock];
    
    [self initBtnCamera];
}


- (void)initBtnCamera {
    btnCamera = [[FTWButton alloc] init];
	
	btnCamera.frame = CGRectMake(20, 646, 32, 32);
	[btnCamera addBlueStyleForState:UIControlStateNormal];
	[btnCamera addYellowStyleForState:UIControlStateSelected];
	
	[btnCamera setIcon:[UIImage imageNamed:@"camera.png"] forControlState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnCamera];
}

- (IBAction) cameraButtonTapped:(id)sender {
	[self showCameraPrompt];
}


#pragma mark - Tables
-(void)reloadDocTable{
    [self.docTVC reloadDocList];
    [self.docTable reloadData];
}


#pragma mark - Time Clock

-(void)initBtnTimeClock{
    btnTimeClock = [[FTWButton alloc]initWithFrame:CGRectMake(20, 380, 120, 30)];
    [btnTimeClock addBlueStyleForState:UIControlStateNormal];
    [btnTimeClock addYellowStyleForState:UIControlStateSelected];
    [btnTimeClock setText:NSLocalizedString(@"clock status in", nil) forControlState:UIControlStateNormal];
    [btnTimeClock addTarget:self action:@selector(timeClockActive:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnTimeClock];
}

- (IBAction)timeClockActive:(FTWButton *)sender {
    if ([[sender getButtonTitle] isEqualToString:NSLocalizedString(@"clock status in", nil)]){
        [self.btnTimeClock setText:NSLocalizedString(@"clock status out", nil) forControlState:UIControlStateNormal];
        //Clock in
        [self.btnTimeClock addDeleteStyleForState:UIControlStateNormal];
        [self clockInToDatabase];
        [self.timeClockTable reloadData];
    }else if ([[sender getButtonTitle] isEqualToString:NSLocalizedString(@"clock status out", nil)]){
        //Clock Out
        UIAlertView *alertView = [UIAlertView alertViewWithTitle:NSLocalizedString(@"clock status out", nil) message:NSLocalizedString(@"prompt clock out", nil)];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil)  handler:nil];
        [alertView addButtonWithTitle:NSLocalizedString(@"ok", nil)  handler:^{
            //Actually save to database
            [self.btnTimeClock setText:NSLocalizedString(@"clock status in", nil) forControlState:UIControlStateNormal];
            [self.btnTimeClock addBlueStyleForState:UIControlStateNormal];
            [self clockOutFromDatabaseWithComment:[alertView textFieldAtIndex:0].text];
            [self.timeClockTable reloadData];
        }];
        [alertView show];
    }
    
}

-(void)clockInToDatabase{
    NSManagedObjectContext* managedObjectContext = [(PMAppDelegate *)[[UIApplication sharedApplication]delegate] managedObjectContext];
    TimeClock *tc = [NSEntityDescription insertNewObjectForEntityForName:@"TimeClock" inManagedObjectContext:managedObjectContext];
    
    tc.projName = self.title;
    tc.start = [NSDate date];
    
    [managedObjectContext save:nil];
}

-(void)clockOutFromDatabaseWithComment:(NSString *)comment{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"TimeClock"inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(projName = %@)", self.title];
    [request setPredicate:pred];
    
    NSSortDescriptor *sortByStartDate = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
    [request setSortDescriptors:@[sortByStartDate]];
    
    TimeClock *match = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] != 0) {
        
        match = objects[0];
        match.end = [NSDate date];
        match.desc = comment;
        NSError *error;
        [context save:&error];
    }
}


#pragma mark - Email
-(void)emailExportedPDFFile{
    if ([MFMailComposeViewController canSendMail]) {
        NSString *path = [self writeReportToLocalHTML];
        NSData *pdfData = [NSData dataWithContentsOfFile:path];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:NSLocalizedString(@"email subject", nil)];
        [mailComposeViewController setMessageBody:NSLocalizedString(@"email with attach body", nil) isHTML:NO];
        [mailComposeViewController addAttachmentData:pdfData mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@%@", self.title,@".pdf"]];
        
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email error title", nil)
                                                        message:NSLocalizedString(@"email error message", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}




-(void)emailExportedTextFile{
    
    if ([MFMailComposeViewController canSendMail]) {
        NSString *data = [self getProjectDataToString];
        NSData *textFileContentsData = [data dataUsingEncoding:NSUTF8StringEncoding];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:NSLocalizedString(@"email subject", nil)];
        [mailComposeViewController setMessageBody:NSLocalizedString(@"email with attach body", nil) isHTML:NO];
        [mailComposeViewController addAttachmentData:textFileContentsData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"%@%@", self.title,@".txt"]];
        mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email error title", nil)
                                                        message:NSLocalizedString(@"email error message", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}



-(void)emailProjectWithData:(NSString *)data{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        [composer setSubject:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"email subject", nil), self.title]];
        composer.mailComposeDelegate = self;
        [composer setMessageBody:data isHTML:NO];
        //composer.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:composer animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email error title", nil)
                                                        message:NSLocalizedString(@"email error message", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)emailThisNote{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        [composer setMessageBody:txtNoteView.text isHTML:NO];
        composer.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:composer animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email error title", nil)
                                                        message:NSLocalizedString(@"email error message", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Helpers
-(NSString *)getPathWithProject:(NSString *)proj withFileName:(NSString *)fileName withPostfix:(NSString *)postfix{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@.%@", [paths objectAtIndex:0], proj, fileName, postfix];
    return filePath;
}


-(NSString *)writeReportToLocalHTML{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],@"index.html"];
    NSString *html = [self getProjectDataToStringHTML];
    //NSLog(html);
    //html = [NSString stringWithFormat:@"%@%@%@%@", html, html, html, html];
    [html writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:url
                                         pathForPDF:[@"~/Documents/report.pdf" stringByExpandingTildeInPath]
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(25, 25, 25, 25)];
    return self.PDFCreator.PDFpath;
}

-(void)getNoteByProjectName{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"ProjectNote"inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(projName = %@)", self.title];
    [request setPredicate:pred];
    ProjectNote *match = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] != 0) {
        match = objects[0];
        txtNoteView.text = match.note;
        NSError *error;
        [context save:&error];
    }
}


-(void)populateValue:(Projects *)proj{
    self.lblProjNameValue.text = proj.name;
    self.lblProjDescValue.text = proj.desc;
    
    //priority label
    self.btnProjPriorityValueOutlet.enabled = NO;
    [self.btnProjPriorityValueOutlet setTitle:proj.priority forState:UIControlStateDisabled];
    [self.btnProjPriorityValueOutlet setColor:[self getColorByPriorityLetter:proj.priority]];
    
    self.lblProjTypeValue.text = proj.type;
    self.lblTNValue.text = [NSString stringWithFormat:@"%@", proj.timeNeedValue];
    self.lblTNTextValue.text = proj.timeNeedText;
    self.lblProjDueDateValue.text = [self formatThisDate:proj.projDueDate withTime:NO];
    self.lblDaysLeftValue.text = [NSString stringWithFormat:@"%d", [self numberOfDaysUntil:proj.projDueDate]];
}

-(NSString *)formatThisDate:(NSDate *)date withTime:(BOOL)withTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (withTime){
        [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm"];
    }else{
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    return [dateFormatter stringFromDate:date];
}

-(NSString *)formatThisDateAsFileName:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    
    return [dateFormatter stringFromDate:date];
}

-(void)localizeUILabel{

    self.lblProjPriority.text = NSLocalizedString(@"priority", nil);
    self.lblProjType.text = NSLocalizedString(@"type", nil);
    self.lblProjDueDate.text = NSLocalizedString(@"due date", nil);
    self.lblTimeSpent.text = NSLocalizedString(@"time spent", nil);
    self.lblProjTimeNeed.text = NSLocalizedString(@"time need", nil);
    self.lblTimeSpentTextValue.text = NSLocalizedString(@"hours", nil);
    self.lblDaysLeft.text = NSLocalizedString(@"days left", nil);
    self.lblProjDueDate.text = NSLocalizedString(@"due date", nil);
    self.lblTaskNumber.text = NSLocalizedString(@"task number", nil);
    self.lblTaskTotalhour.text = NSLocalizedString(@"task total hour", nil);
    self.lblTaskTotalhourValueUnit.text = NSLocalizedString(@"hours", nil);
    
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

- (NSInteger)numberOfDaysUntil:(NSDate *)aDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:[NSDate date] toDate:aDate options:0];
    
    return [components day];
}

#pragma mark - Files Remove

-(void)removeAllFilesForProject:(NSString *)pName{
    int Count;
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.title]];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSError *error;
    for (Count = 0; Count < (int)[directoryContent count]; Count++){
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
            //Does file exist?
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]){	//Delete it
                NSLog(@"Delete file error: %@", error);
            }
        }
    }
}

#pragma mark - Camera and Image and Map Import

- (void) useCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)showPhotoPrompt {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    //[self.popoverController presentPopoverFromBarButtonItem:self.importButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [self.popoverController presentPopoverFromRect:self.btnCamera.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark - ActionSheet AlertSheet HUD

-(void)showCameraPrompt{
    UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"what would you like to import", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"camera", nil) handler:^{
        self._isCamera = TRUE;
        [self useCamera];
    }];
    [sheet addButtonWithTitle:NSLocalizedString(@"photo library", nil) handler:^{
        
        [self showPhotoPrompt];
        
    }];
    [sheet addButtonWithTitle:NSLocalizedString(@"import map", nil) handler:^{
        
        [self performSegueWithIdentifier:@"map view segue" sender:nil];
        
    }];
    [sheet setCancelButtonWithTitle:@"Cancel" handler:nil];
    [sheet showInView:self.view];
}

-(void)showExportPrompt{
    UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"title export project", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"email", nil) handler:^{
        
        [self exportToEmail];
    }];
    [sheet addButtonWithTitle:NSLocalizedString(@"text and email", nil) handler:^{
        
        [self emailExportedTextFile];
    }];
//    [sheet addButtonWithTitle:NSLocalizedString(@"pdf and email", nil) handler:^{
//        
//        [self emailExportedPDFFile];
//    }];
//    [sheet addButtonWithTitle:NSLocalizedString(@"pdf to dropbox", nil) handler:^{
//        
//        
//        
//    }];
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil)  handler:nil];
    [sheet showInView:self.view];
}

-(void)showDeleteAlert{
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"title delete comfirm", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                         destructiveButtonTitle:NSLocalizedString(@"comfrim delete all", nil)
                                              otherButtonTitles:NSLocalizedString(@"cancel", nil), nil];
    
    [action showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [self deleteProject];
    }
}


#pragma mark - Export and Delete




-(void)exportToEmail{
    NSString *data = [self getProjectDataToString];
    [self emailProjectWithData:data];
}


-(NSString *)getProjectDataToString{
    NSString *returnString = @"";
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProject: self.title fromEntity:@"Projects"]];
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProject: self.title fromEntity:@"TodoList"]];
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProject: self.title fromEntity:@"TimeClock"]];
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProject: self.title fromEntity:@"ProjectNote"]];
    returnString = [NSString stringWithFormat:@"%@ \n%@: %@",returnString, NSLocalizedString(@"report date", nil), [self formatThisDate:[NSDate date] withTime:YES]];
    
    return returnString;
}

-(NSString *)getProjectDataToStringHTML{
    NSString *returnString = @"";
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProjectHTML: self.title fromEntity:@"Projects"]];
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProjectHTML: self.title fromEntity:@"TodoList"]];
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProjectHTML: self.title fromEntity:@"TimeClock"]];
    returnString = [NSString stringWithFormat:@"%@ %@",returnString, [self getStringDataProjectHTML: self.title fromEntity:@"ProjectNote"]];
    returnString = [NSString stringWithFormat:@"%@ \n%@: %@",returnString, NSLocalizedString(@"report date", nil), [self formatThisDate:[NSDate date] withTime:YES]];
    
    return returnString;
}

-(void)backupProject{
    [self showExportPrompt];
}



-(void)deleteProject{
    [self removeProject:self.title fromEntity:@"TodoList"];
    [self removeProject:self.title fromEntity:@"ProjectNote"];
    [self removeProject:self.title fromEntity:@"TimeClock"];
    [self removeProject:self.title fromEntity:@"Projects"];
    [self removeAllFilesForProject:self.title];
    [self.delegate reloadProjectAfterDelete];
}

-(NSString *)exportProjectEntity:(Projects *)proj{
    NSString *returnString = @"";
    returnString = [NSString stringWithFormat:@"%@%@: %@\n",returnString, NSLocalizedString(@"project name", nil), proj.name];
    returnString = [NSString stringWithFormat:@"%@%@: %@\n",returnString, NSLocalizedString(@"project description", nil), proj.desc];
    returnString = [NSString stringWithFormat:@"%@%@: %@\n",returnString, NSLocalizedString(@"priority", nil), proj.priority];
    returnString = [NSString stringWithFormat:@"%@%@: %@\n",returnString, NSLocalizedString(@"type", nil), proj.type];
    returnString = [NSString stringWithFormat:@"%@%@: %@\n",returnString, NSLocalizedString(@"start date", nil), [self formatThisDate:proj.projStartDate withTime:NO]];
    returnString = [NSString stringWithFormat:@"%@%@: %@\n",returnString, NSLocalizedString(@"due date", nil), [self formatThisDate:proj.projDueDate withTime:NO]];
    returnString = [NSString stringWithFormat:@"%@%@: %@ %@\n",returnString, NSLocalizedString(@"est time need", nil), proj.timeNeedValue, proj.timeNeedText];
    returnString = [NSString stringWithFormat:@"%@%@: %d %@\n",returnString, NSLocalizedString(@"days left", nil), [self numberOfDaysUntil:proj.projDueDate], proj.timeNeedText];
    returnString = [NSString stringWithFormat:@"%@\n\n",returnString];
    return returnString;
}

-(NSString *)exportProjectEntityHTML:(Projects *)proj{
    NSString *returnString = @"";
    returnString = [NSString stringWithFormat:@"%@<div>%@: %@</div>\n",returnString, NSLocalizedString(@"project name", nil), proj.name];
    returnString = [NSString stringWithFormat:@"%@<div>%@: %@</div>\n",returnString, NSLocalizedString(@"project description", nil), proj.desc];
    returnString = [NSString stringWithFormat:@"%@<div>%@: %@</div>\n",returnString, NSLocalizedString(@"priority", nil), proj.priority];
    returnString = [NSString stringWithFormat:@"%@<div>%@: %@</div>\n",returnString, NSLocalizedString(@"type", nil), proj.type];
    returnString = [NSString stringWithFormat:@"%@<div>%@: %@</div>\n",returnString, NSLocalizedString(@"start date", nil), [self formatThisDate:proj.projStartDate withTime:NO]];
    returnString = [NSString stringWithFormat:@"%@<div>%@: %@</div>\n",returnString, NSLocalizedString(@"due date", nil), [self formatThisDate:proj.projDueDate withTime:NO]];
    returnString = [NSString stringWithFormat:@"%@<div>%@: %@ %@</div>\n",returnString, NSLocalizedString(@"est time need", nil), proj.timeNeedValue, proj.timeNeedText];
    returnString = [NSString stringWithFormat:@"%@<div>%@: %d %@</div>\n",returnString, NSLocalizedString(@"days left", nil), [self numberOfDaysUntil:proj.projDueDate], proj.timeNeedText];
    returnString = [NSString stringWithFormat:@"%@\n\n",returnString];
    return returnString;
}


#pragma mark - Database

-(NSString *)getStringDataProject:(NSString *)pName fromEntity:(NSString *)entityName{
    NSString *returnString = @"";
    
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    if ([entityName isEqualToString:@"Projects"]) {
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(name = %@)", pName];
        [request setPredicate:pred];
    }else{
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(projName = %@)", pName];
        [request setPredicate:pred];
    }
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] != 0) {
        if ([objects count] == 1 && [entityName isEqualToString:@"Projects"]) {
            returnString = [self exportProjectEntity:objects[0]];
        }else{
            returnString = [self convertToStringFromData:objects Enity:entityName];
        }
        
    }
    return returnString;
}

-(NSString *)convertToStringFromData:(NSArray *)data Enity:(NSString *)entityName{
    NSString *returnString = @"\n";
    if([entityName isEqualToString:@"TodoList"]){
        returnString = [NSString stringWithFormat:@"%@%@ \n", returnString, NSLocalizedString(@"todo list", nil)];
        for (int i = 0; i < data.count; i++) {
            TodoList *td = data[i];
            returnString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@\n", returnString, td.priority, [self formatThisDate:td.addDate withTime:YES], NSLocalizedString(@"est time need", nil), td.estTime, NSLocalizedString(@"hours", nil), td.desc, [td.isFinished boolValue]? NSLocalizedString(@"(finished)", nil):@""];
        }
    }else if([entityName isEqualToString:@"TimeClock"]){
        returnString = [NSString stringWithFormat:@"%@%@ \n", returnString, NSLocalizedString(@"time clock", nil)];
        for (int i = 0; i < data.count; i++) {
            TimeClock *tc = data[i];
            returnString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@: %@\n", returnString, NSLocalizedString(@"from", nil), [self formatThisDate:tc.start withTime:YES], NSLocalizedString(@"to", nil), [self formatThisDate:tc.end withTime:YES], NSLocalizedString(@"memo", nil), tc.desc];
        }
    }else if([entityName isEqualToString:@"ProjectNote"]){
        returnString = [NSString stringWithFormat:@"%@%@ \n", returnString, NSLocalizedString(@"note", nil)];
        for (int i = 0; i < data.count; i++) {
            ProjectNote *pn = data[i];
            returnString = [NSString stringWithFormat:@"%@ %@\n\n", returnString, pn.note];
        }
    }
    return returnString;
}


-(NSString *)getStringDataProjectHTML:(NSString *)pName fromEntity:(NSString *)entityName{
    NSString *returnString = @"";
    
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    if ([entityName isEqualToString:@"Projects"]) {
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(name = %@)", pName];
        [request setPredicate:pred];
    }else{
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(projName = %@)", pName];
        [request setPredicate:pred];
    }
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] != 0) {
        if ([objects count] == 1 && [entityName isEqualToString:@"Projects"]) {
            returnString = [self exportProjectEntityHTML:objects[0]];
        }else{
            returnString = [self convertToStringFromDataHTML:objects Enity:entityName];
        }
        
    }
    //NSLog(returnString);
    return returnString;
}


-(NSString *)convertToStringFromDataHTML:(NSArray *)data Enity:(NSString *)entityName{
    NSString *returnString = @"\n";
    if([entityName isEqualToString:@"TodoList"]){
        returnString = [NSString stringWithFormat:@"%@<div>%@ </div>\n", returnString, NSLocalizedString(@"todo list", nil)];
        for (int i = 0; i < data.count; i++) {
            TodoList *td = data[i];
            returnString = [NSString stringWithFormat:@"%@ <div>%@ %@ %@ %@ %@ %@ %@</div>\n", returnString, td.priority, [self formatThisDate:td.addDate withTime:YES], NSLocalizedString(@"est time need", nil), td.estTime, NSLocalizedString(@"hours", nil), td.desc, [td.isFinished boolValue]? NSLocalizedString(@"(finished)", nil):@""];
        }
    }else if([entityName isEqualToString:@"TimeClock"]){
        returnString = [NSString stringWithFormat:@"%@<div>%@ </div>\n", returnString, NSLocalizedString(@"time clock", nil)];
        for (int i = 0; i < data.count; i++) {
            TimeClock *tc = data[i];
            returnString = [NSString stringWithFormat:@"%@ <div>%@ %@ %@ %@ %@: %@</div>\n", returnString, NSLocalizedString(@"from", nil), [self formatThisDate:tc.start withTime:YES], NSLocalizedString(@"to", nil), [self formatThisDate:tc.end withTime:YES], NSLocalizedString(@"memo", nil), tc.desc];
        }
    }else if([entityName isEqualToString:@"ProjectNote"]){
        returnString = [NSString stringWithFormat:@"%@<div>%@ </div>\n", returnString, NSLocalizedString(@"note", nil)];
        for (int i = 0; i < data.count; i++) {
            ProjectNote *pn = data[i];
            returnString = [NSString stringWithFormat:@"%@ <div>%@</div>\n\n", returnString, pn.note];
        }
    }
    return returnString;
}


-(void)removeProject:(NSString *)pName fromEntity:(NSString *)entityName{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    if ([entityName isEqualToString:@"Projects"]) {
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(name = %@)", pName];
        [request setPredicate:pred];
    }else{
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(projName = %@)", pName];
        [request setPredicate:pred];
    }
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] != 0) {
        for (int i = 0; i < objects.count; i++) {
            [context deleteObject:[objects objectAtIndex:i]];
            NSError *error;
            [context save:&error];
        }
    }
}

-(void)updateTodoListTaskIsFinishedStatus:(TodoList *)task forUpdateStatus:(DBDatabaseUpdateStatus)dbDatabaseUpdateStatus{
    
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (dbDatabaseUpdateStatus == DBDatabaseUpdateStatusDelete) {
        [context deleteObject:task];
    }else if (dbDatabaseUpdateStatus == DBDatabaseUpdateStatusUpdate){
        NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"TodoList"inManagedObjectContext:context];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(desc = %@) AND (priority = %@) AND (projName = %@)", task.desc, task.priority, task.projName];
        [request setPredicate:pred];
        TodoList *match = nil;
        
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if ([objects count] != 0) {
            
            match = objects[0];
            match.isFinished = [NSNumber numberWithBool:YES];
            NSError *error;
            [context save:&error];
        }
    }
    [self reloadCarouselData];
}

-(Projects *)getProjectFromDatabase{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Projects" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", self.title];
    [request setPredicate:pred];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    return objects[0];
}

- (void)populateTaskRelativeLabels:(NSArray *)objects {
    int taskCount = 0;
    int sum = 0;
    for (int i = 0; i < objects.count; i++){
        TodoList *td = objects[i];
        if (![td.isFinished boolValue]) {
            sum = sum + [td.estTime intValue];
            taskCount = taskCount + 1;
        }
    }
    self.lblTaskTotalhourValue.text = [NSString stringWithFormat:@"%d", sum];
    self.lblTaskNumberValue.text = [NSString stringWithFormat:@"%d", taskCount];
}

-(NSArray *)getAllTodoListFromDatabase{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"TodoList" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(projName = %@)", self.title];
    [request setPredicate:pred];
    
    NSSortDescriptor *sortByIsFinished = [[NSSortDescriptor alloc] initWithKey:@"isFinished" ascending:YES];
    NSSortDescriptor *sortByPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
    
    [request setSortDescriptors:@[sortByIsFinished, sortByPriority]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    [self populateTaskRelativeLabels:objects];
    return objects;
}


#pragma mark - Buttons Events




- (IBAction)btnDoc:(BButton *)sender {
    [self didPressLink];
}

- (IBAction)btnAddTodoList:(BButton *)sender {
}

- (IBAction) btnMarkTaskFinish:(id)sender {
	//NSLog([NSString stringWithFormat:@"Button %i pressed", [carousel indexOfItemViewOrSubview:sender]]);
    TodoList *td = [self.allTodoList objectAtIndex:[carousel indexOfItemViewOrSubview:sender]];
    [self updateTodoListTaskIsFinishedStatus:td forUpdateStatus:DBDatabaseUpdateStatusUpdate];
    
}



- (IBAction)btnDeleteTaskTapped:(id)sender{
    //NSLog([NSString stringWithFormat:@"delete %i pressed", [carousel indexOfItemViewOrSubview:sender]]);
    TodoList *td = [self.allTodoList objectAtIndex:[carousel indexOfItemViewOrSubview:sender]];
    [self updateTodoListTaskIsFinishedStatus:td forUpdateStatus:DBDatabaseUpdateStatusDelete];
}


#pragma mark - Delegate
-(void)updatePannelNote:(NSString *)note{
    self.txtNoteView.text = note;
}


-(void)reloadTodoListTable{
    [self reloadCarouselData];
}

-(void)presentPreviewController:(QLPreviewController *)controller{
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)reloadDocListTable{
    [self.docTable reloadData];
}


#pragma mark - Dropbox
- (void)didPressLink
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"Login");
    } else {
        //The session has already been linked
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //The user is on an iPhone - link the correct storyboard below
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
            KioskDropboxPDFBrowserViewController *targetController = [storyboard instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
            [targetController setProjName:self.title];

            targetController.modalPresentationStyle = UIModalPresentationFormSheet;
            targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:targetController animated:YES completion:nil];
            
            targetController.view.superview.frame = CGRectMake(0, 0, 320, 480);
            UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
            
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
                targetController.view.superview.center = self.view.center;
            } else {
                targetController.view.superview.center = CGPointMake(self.view.center.y, self.view.center.x);
            }
            
            targetController.uiDelegate = self;
            // List the Dropbox Directory
            [targetController listDropboxDirectory];
        } else {
            //The user is on an iPhone - link the correct storyboard below
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
            KioskDropboxPDFBrowserViewController *targetController = [storyboard instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
            [targetController setProjName:self.title];
            
            targetController.modalPresentationStyle = UIModalPresentationFormSheet;
            targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:targetController animated:YES completion:nil];
            
            //targetController.view.superview.frame = CGRectMake(0, 0, 748, 720);
            UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
            
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
                targetController.view.superview.center = self.view.center;
            } else {
                targetController.view.superview.center = CGPointMake(self.view.center.y, self.view.center.x);
            }
            
            targetController.uiDelegate = self;
            // List the Dropbox Directory
            [targetController listDropboxDirectory];
        }
    }
}

- (void)removeDropboxBrowser {
    //This is where you can handle the cancellation of selection, ect.
    
    [self reloadDocTable];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshLibrarySection{
    NSLog(@"Final Filename: %@", [KioskDropboxPDFRootViewController fileName]);
}


#pragma mark - iCarousel Methods

-(void)reloadCarouselData{
    allTodoList = [NSMutableArray arrayWithArray:[self getAllTodoListFromDatabase]];
    [carousel reloadData];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [allTodoList count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    BButton *priorityLabelButton = nil;
    FTWButton *btnIsFinished = nil;
    FTWButton *btnDeleteTask = nil;
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)] autorelease];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 180.0f, 200.0f)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.font = [label.font fontWithSize:20];
        
        label.tag = 1;
        [view addSubview:label];
        label.numberOfLines = NUMBER_OF_LINE;
        
        //priorityLabelButton
        priorityLabelButton = [[BButton alloc]initWithFrame:CGRectMake(100, 0, 120, 20)];
        priorityLabelButton.tag = 2;
        [view addSubview:priorityLabelButton];
        
        //btnIsFinished
        btnIsFinished = [[FTWButton alloc]initWithFrame:CGRectMake(50, 175, 100, 25)];
        btnIsFinished.tag = 3;
        [btnIsFinished addBlueStyleForState:UIControlStateNormal];
        [btnIsFinished addBlackStyleForState:UIControlStateDisabled];
        [btnIsFinished setText:NSLocalizedString(@"btn isFinish", nil) forControlState:UIControlStateNormal];
        [btnIsFinished setText:NSLocalizedString(@"btn isFinished", nil) forControlState:UIControlStateDisabled];
        [btnIsFinished addTarget:self action:@selector(btnMarkTaskFinish:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnIsFinished];
        
        //btnDeleteTask
        btnDeleteTask = [[FTWButton alloc]initWithFrame:CGRectMake(165, 175, 20, 20)];
        btnDeleteTask.tag = 4;
        [btnDeleteTask addTarget:self action:@selector(btnDeleteTaskTapped:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnDeleteTask];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
        priorityLabelButton = (BButton *)[view viewWithTag:2];
        btnIsFinished = (FTWButton *)[view viewWithTag:3];
        btnDeleteTask = (FTWButton *)[view viewWithTag:4];
    }
    
    TodoList *td = [allTodoList objectAtIndex:index];
    label.text = td.desc;
    [priorityLabelButton setTitle:[NSString stringWithFormat:@"%@ %@ - %@", td.estTime, NSLocalizedString(@"lbl estTime unit", nil), td.priority] forState:UIControlStateNormal];
    //[priorityLabelButton setColor:[self getColorByPriorityLetter:td.priority]];
    //NSLog([NSString stringWithFormat:@"%@",td.isFinished]);
    if (td.isFinished.boolValue == YES) {
        btnIsFinished.enabled = NO;
        [priorityLabelButton setColor:[self getColorByPriorityLetter:@"FN"]];
    }else{
        btnIsFinished.enabled = YES;
        [priorityLabelButton setColor:[self getColorByPriorityLetter:td.priority]];
    }
    [btnDeleteTask setIcon:[UIImage imageNamed:@"trashcan.png"] forControlState:UIControlStateNormal];
    return view;
}


#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self._isCamera) {
        [self dismissViewControllerAnimated:YES completion:nil];
        self._isCamera = FALSE;
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !self._isCamera) {
        [self dismissCurrentPopover];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }

    NSString *imagePath = [self getPathWithProject: self.title withFileName:[self formatThisDateAsFileName:[NSDate date]] withPostfix:@"png"];
    NSData *imageData = UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]);
    [imageData writeToFile:imagePath atomically:YES];
    
    [self reloadDocTable];
    
}



- (void)dismissCurrentPopover
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    self.popoverController = nil;
}


#pragma mark - Note View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [txtNoteView setNeedsDisplay];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    CGRect frame = self.view.bounds;
//    frame.size.height -= KEYBOARD_HEIGHT;
//    txtNoteView.frame = frame;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    txtNoteView.frame = self.view.bounds;
}


- (IBAction)btnEmailNote:(UIButton *)sender {
    [self emailThisNote];
}

#pragma mark - SDMapViewController delegate

- (void)viewController:(SDMapViewController *)viewController wasDismissed:(BOOL)success {
    
    if (success) {
        //self.photoTool.photo = [self reduceImage:[viewController imageOfMap]];
        
        NSString *imagePath = [self getPathWithProject: self.title withFileName:[self formatThisDateAsFileName:[NSDate date]] withPostfix:@"png"];
        NSData *imageData = UIImagePNGRepresentation([viewController imageOfMap]);
        [imageData writeToFile:imagePath atomically:YES];
        
        [self reloadDocTable];
    }
    
}
@end
