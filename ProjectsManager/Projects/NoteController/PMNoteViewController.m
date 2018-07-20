//
//  PMNoteViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/22/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMNoteViewController.h"
#define KEYBOARD_HEIGHT 216

@interface PMNoteViewController ()
@property BOOL isNew;
@end

@implementation PMNoteViewController

@synthesize txtViewNote;
@synthesize theNote;

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

    [self initNotepad];
    
    [self setupNoteContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewWillDisappear:(BOOL)animated{
    //Save note and Populate Pannel Note
    [self saveNote];
    [self.delegate updatePannelNote:txtViewNote.text];
}

#pragma mark - Init

-(void)initNotepad{
    txtViewNote.backgroundColor = [UIColor clearColor];
    [txtViewNote becomeFirstResponder];
    txtViewNote.delegate = self;
}

#pragma mark - Database Relative

-(void)updateNote{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"ProjectNote"inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(projName = %@) AND (timeAdd = %@)", theNote.projName, theNote.timeAdd];
    [request setPredicate:pred];
    ProjectNote *match = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] != 0) {
        match = objects[0];
        match.note = txtViewNote.text;
        match.timeModified = [NSDate date];
        NSError *error;
        [context save:&error];
    }
}

-(void)saveNewNote{
    NSManagedObjectContext* managedObjectContext = [(PMAppDelegate *)[[UIApplication sharedApplication]delegate] managedObjectContext];
    ProjectNote *note = [NSEntityDescription insertNewObjectForEntityForName:@"ProjectNote" inManagedObjectContext:managedObjectContext];
    note.projName = self.projName;
    note.note = txtViewNote.text;
    note.timeAdd = [NSDate date];
    note.timeModified = [NSDate date];
    [managedObjectContext save:nil];
}

#pragma mark - Email
-(void)emailThisNote{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        [composer setMessageBody:txtViewNote.text isHTML:NO];
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

-(void)saveNote{
    if(self.isNew){
        //Create a new one and save it
        [self saveNewNote];
    }else{
        //Find the old one and update it
        [self updateNote];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        //Populate the Pannel Note
        [self.delegate updatePannelNote:txtViewNote.text];
    }];
}

-(void)setupNoteContent{
    theNote = [self getNoteByProjectName];
    if (theNote != NULL) {
        self.isNew = FALSE;
        txtViewNote.text = [NSString stringWithFormat:@"\n\n--[%@] \n\n%@", [self formatThisDate:[NSDate date] withTime:YES], theNote.note];
    }else{
        self.isNew = TRUE;
        txtViewNote.text = [NSString stringWithFormat:@"\n\n--[%@]", [self formatThisDate:[NSDate date] withTime:YES]];
    }
    [self setTextViewCursor];
}

-(void)setTextViewCursor{
    NSRange beginningRange = NSMakeRange(0, 0);
    NSRange currentRange = [txtViewNote selectedRange];
    if(!NSEqualRanges(beginningRange, currentRange))
        [txtViewNote setSelectedRange:beginningRange];
}

-(ProjectNote *)getNoteByProjectName{
    if (self.projName == NULL) {
        return NULL;
    }
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"ProjectNote"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(projName = %@)", self.projName];
    [request setPredicate:pred];
    
    //        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
    //                                            initWithKey:@"priority" ascending:NO];
    //        [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    if(objects == NULL || objects.count == 0){
        return NULL;
    }
    return objects[0];
    
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

#pragma mark - Buttons

- (IBAction)btnSaveNote:(UIButton *)sender {
    [self saveNote];
}

- (IBAction)btnEmailNote:(UIButton *)sender {
    [self emailThisNote];
}

#pragma Text View Delegate
//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    CGRect frame = self.view.bounds;
//    frame.size.height -= KEYBOARD_HEIGHT;
//    txtViewNote.frame = frame;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [txtViewNote setNeedsDisplay];
}

@end
