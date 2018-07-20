//
//  PMTodoListDetailViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/16/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMTodoListDetailViewController.h"

@interface PMTodoListDetailViewController ()
@property (nonatomic, strong) FTWButton *btnPriority;
@property (nonatomic, strong) NSNumber *taskEstTimeValue;
@property (nonatomic, strong) NSString *taskPriority;
//@property (nonatomic, strong) TodoList *todoToDB;
@end

@implementation PMTodoListDetailViewController

@synthesize btnAddPresetTaskOutlet;
@synthesize btnAddTaskOutlet;
@synthesize txtPresetTask;
@synthesize txtTodoTask;
@synthesize popover;
@synthesize lblTaskPriority;
@synthesize lblEstTime;
@synthesize lblEstTimeValue;
@synthesize lblEstTimeUnit;
@synthesize btnPriority;
@synthesize todoListTable;
@synthesize presetTaskTable;
@synthesize todoListTVC;
@synthesize presetTaskTVC;

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
    [self.txtTodoTask becomeFirstResponder];
    
    [super viewDidLoad];

    [self initButtonsOutlet];
    
    [self initTextFieldAndDefaultValue];
    
    [self initializePriorityButton];
    
    [self localizeLabels];
    
    [self initTables];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initializations

-(void)initTables{
    //todoList table
    todoListTVC = [[PMTodoListTableViewController alloc]init];
    [todoListTVC setProjName:self.projectName];
    [todoListTable setDataSource:todoListTVC];
    [todoListTable setDelegate:todoListTVC];
    todoListTVC.view = todoListTVC.tableView;
    todoListTVC.delegate = self;
    
    
    //presetTask table
    presetTaskTVC = [[PMPresetTaskTableViewController alloc]init];
    //[todoListTVC setProjName:self.projectName];
    [presetTaskTable setDataSource:presetTaskTVC];
    [presetTaskTable setDelegate:presetTaskTVC];
    presetTaskTVC.view = presetTaskTVC.tableView;
    presetTaskTVC.delegate = self;
}

- (void)initializePriorityButton {
    lblTaskPriority.text = NSLocalizedString(@"lbl task priority", nil);
    btnPriority = [[FTWButton alloc] init];
	
	btnPriority.frame = CGRectMake(280, 130, 120, 30);
	[btnPriority addGrayStyleForState:UIControlStateNormal];
	[btnPriority setText:NSLocalizedString(@"please select", nil) forControlState:UIControlStateNormal];
    [btnPriority addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnPriority];
}

-(void)initButtonsOutlet{
    UIColor *color = [UIColor colorWithRed:0.23 green:0.56 blue:0.9 alpha:1];
    
    [btnAddPresetTaskOutlet setTitle:NSLocalizedString(@"btn add preset todo", nil) forState:UIControlStateNormal];
    [btnAddPresetTaskOutlet setColor:color];
    
    [btnAddTaskOutlet setTitle:NSLocalizedString(@"btn add todo", nil) forState:UIControlStateNormal];
    [btnAddTaskOutlet setColor:color];
    
    
}

-(void)initTextFieldAndDefaultValue{
    txtTodoTask.placeholder = NSLocalizedString(@"txt todo", nil);
    txtPresetTask.placeholder = NSLocalizedString(@"txt preset todo", nil);
    self.taskEstTimeValue = [NSNumber numberWithInt:1];
    self.taskPriority = @"";
    
}



#pragma mark - Buttons Actions

- (IBAction)btnTodoListDone:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate reloadTodoListTable];
    }];
}

- (IBAction)btnAddTaskButton:(BButton *)sender {
    if (![self isPriorityValid] || self.txtTodoTask.text.length == 0) {
        [self showInfoHUD:NSLocalizedString(@"invalid info", nil) delay:1.5];
        return;
    }
    if ([self isDuplicateTodoTask:self.txtTodoTask.text]) {
        [self showInfoHUD:NSLocalizedString(@"duplicate error", nil) delay:1.5];
        return;
    }
    [self saveTodoToDatabase];
    [self.todoListTable reloadData];
    self.txtTodoTask.text = @"";
}

- (IBAction)btnAddPresetTaskButton:(BButton *)sender {
    if (self.txtPresetTask.text.length == 0) {
        [self showInfoHUD:NSLocalizedString(@"invalid info", nil) delay:1.5];
        return;
    }
    [self savePresetTaskToDatabase];
    [self.presetTaskTable reloadData];
    self.txtPresetTask.text = @"";
}

#pragma mark - ActionSheet AlertSheet HUD

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
#pragma mark - Database Relative

-(void)saveTodoToDatabase{
    
    NSManagedObjectContext* managedObjectContext = [(PMAppDelegate *)[[UIApplication sharedApplication]delegate] managedObjectContext];
    TodoList *task = [NSEntityDescription insertNewObjectForEntityForName:@"TodoList" inManagedObjectContext:managedObjectContext];
    
    task.desc = self.txtTodoTask.text;
    task.estTime = self.taskEstTimeValue;
    task.isFinished = [NSNumber numberWithBool:NO];
    task.priority = self.taskPriority;
    task.projName = self.projectName;
    task.addDate = [NSDate date];
    [managedObjectContext save:nil];
}

-(void)savePresetTaskToDatabase{
    NSManagedObjectContext* managedObjectContext = [(PMAppDelegate *)[[UIApplication sharedApplication]delegate] managedObjectContext];
    PresetTask *task = [NSEntityDescription insertNewObjectForEntityForName:@"PresetTask" inManagedObjectContext:managedObjectContext];
    
    task.desc = self.txtPresetTask.text;
    task.addDate = [NSDate date];
    [managedObjectContext save:nil];

}



#pragma mark - Helpers

-(BOOL)isDuplicateTodoTask:(NSString *)task{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"TodoList" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(desc = %@) AND (projName = %@)", task, self.projectName];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if ([objects count] == 0) {
        return FALSE;
    } else {
        return TRUE;
    }
}

-(BOOL)isPriorityValid{
    if([self string:@"A" IsInString:self.taskPriority]){
        return TRUE;
    }else if([self string:@"B" IsInString:self.taskPriority]){
        return TRUE;
    }else if([self string:@"C" IsInString:self.taskPriority]){
        return TRUE;
    }else{
        return FALSE;
    }
}

-(BOOL)string:(NSString *)str IsInString:(NSString *)string{
    NSRange range = [string rangeOfString:str];
    if (range.location < 10) {
        return TRUE;
    }else return FALSE;
}

-(void)localizeLabels{
    self.todoNavItem.title = NSLocalizedString(@"todo list", nil);
    lblTaskPriority.text = NSLocalizedString(@"lbl task priority", nil);
    lblEstTime.text = NSLocalizedString(@"lbl estTime", nil);
    lblEstTimeUnit.text = NSLocalizedString(@"lbl estTime unit", nil);
}

- (IBAction) buttonTapped:(id)sender {
	if (sender == btnPriority) {
        [self popPriorityView];
	}
	
}

-(void)popPriorityView{
    PMPriorityViewController *controller = [[PMPriorityViewController alloc]init];
    controller.delegate = self;
    popover = [[UIPopoverController alloc]initWithContentViewController:controller];
    popover.popoverContentSize = CGSizeMake(120, 300);
    popover.delegate = self;
    [popover presentPopoverFromRect:CGRectMake(280, 130, 120, 30) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
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

- (IBAction)estTimeSlider:(UISlider *)sender {
    NSInteger progressAsInt = (int)roundf(sender.value);
    self.taskEstTimeValue = [NSNumber numberWithInt:progressAsInt];
    lblEstTimeValue.text = [NSString stringWithFormat:@"%d", progressAsInt];
}


#pragma mark - Delegates
-(void)prioritySelected:(NSString *)title{
    self.taskPriority = title;
    [self.btnPriority setText:title forControlState:UIControlStateNormal];
    [self.btnPriority setBackgroundColor:[self getColorByPriorityLetter:title] forControlState:UIControlStateNormal];
    [self.popover dismissPopoverAnimated:YES];
}

-(void)reloadPresetTaskTable{
    [self.presetTaskTable reloadData];
}

-(void)reloadTodoListTable{
    [self.todoListTable reloadData];
}

-(void)copyTaskToTodoList:(NSString *)task{
    self.txtTodoTask.text = task;
}

@end
