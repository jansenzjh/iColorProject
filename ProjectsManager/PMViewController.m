//
//  PMViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/4/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMViewController.h"

@interface PMViewController ()<PMEditNewProjectViewControllerDelegate>

@property (nonatomic, strong) FTWButton *btnNewProject;

@property (nonatomic, strong) FTWButton *btnReload;

@property (nonatomic, strong) FTWButton *btnBrowser;


@end

@implementation PMViewController

@synthesize projectList;

@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize btnNewProject;
@synthesize btnReload;
@synthesize btnBrowser;
@synthesize browserURL;


- (void)viewDidLoad
{
    
    
	[self initializeNewProjectButton];
    
    [self initializeReloadButton];
    
    [self initDBConnection];

    self.projectList = [[NSMutableArray alloc]initWithArray:[self getProjectsFromDatabase]];

    [self initializeBrowserButton];
    
    [super viewDidLoad];
    
//    PMEditNewProjectViewController *pmev = [[PMEditNewProjectViewController alloc]init];
//    pmev.delegate = self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - KLNote
- (NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView {
    //return  [self.projectList count];
    return [self getProjectsFromDatabase].count;
}
- (UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get the relevant data for the navigation controller
    
    //SET DATA HERE
    //NSDictionary* navDict = [self.projectList objectAtIndex: indexPath.row];
    
    //Initialize a blank uiviewcontroller for display purposes
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    PMProjectPannelViewController * viewController = [st instantiateViewControllerWithIdentifier:@"RootViewController"];
    self.projectList = [[NSMutableArray alloc]initWithArray:[self getProjectsFromDatabase]];
    Projects *project = [self.projectList objectAtIndex:indexPath.row];
    viewController.title = project.name;
    viewController.delegate = self;
    //Return the custom view controller
    return viewController;
}


#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Projects" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"priority" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

//- (IBAction)addNewProj:(FTWButton *)sender {
//}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    //[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    //[self.tableView endUpdates];
}

#pragma mark - Database Relative

-(void)initDBConnection{
    self.managedObjectContext = [(PMAppDelegate *)[[UIApplication sharedApplication]delegate] managedObjectContext];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

-(NSArray *)getProjectsFromDatabase{
    PMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Projects"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"priority" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    return objects;

}

#pragma mark - Helpers

-(NSString *)formatThisDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm"];
    return [dateFormatter stringFromDate:date];
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
        return [UIColor colorWithRed:0 green:1 blue:0.785 alpha:1];
    }else if ([priority rangeOfString:@"C2" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
    }else if ([priority rangeOfString:@"C3" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return [UIColor colorWithRed:0 green:0.785 blue:1 alpha:1];
    }else{
        return [UIColor whiteColor];
    }
}

#pragma mark - Button Initialization



- (void)initializeBrowserButton {
    btnBrowser = [[FTWButton alloc] init];
	
	btnBrowser.frame = CGRectMake(250, 20, 40, 40);
	[btnBrowser addBlueStyleForState:UIControlStateNormal];
	[btnBrowser addYellowStyleForState:UIControlStateSelected];
	
	//[btnExport setText:NSLocalizedString(@"Export", nil) forControlState:UIControlStateNormal];
	[btnBrowser setIcon:[UIImage imageNamed:@"safari.png"] forControlState:UIControlStateNormal];
    [btnBrowser addTarget:self action:@selector(browserButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnBrowser];
}

- (void)initializeReloadButton {
    btnReload = [[FTWButton alloc] init];
	
	btnReload.frame = CGRectMake(140, 20, 100, 40);
	[btnReload addBlueStyleForState:UIControlStateNormal];
	[btnReload addYellowStyleForState:UIControlStateSelected];
	
	[btnReload setText:NSLocalizedString(@"reload", nil) forControlState:UIControlStateNormal];
	//[btnNewProject setText:@"Tapped!" forControlState:UIControlStateSelected];
	
	[btnReload addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnReload];
}

- (void)initializeNewProjectButton{
    
    btnNewProject = [[FTWButton alloc] init];
	
	btnNewProject.frame = CGRectMake(20, 20, 110, 40);
	[btnNewProject addBlueStyleForState:UIControlStateNormal];
	[btnNewProject addYellowStyleForState:UIControlStateSelected];
	
	[btnNewProject setText:NSLocalizedString(@"new project", nil) forControlState:UIControlStateNormal];
	//[btnNewProject setText:@"Tapped!" forControlState:UIControlStateSelected];
	
	[btnNewProject addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnNewProject];
}





#pragma mark - Modal View 

-(void)presentBrowserByIdentifier:(NSString *)identifier{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    SDBrowserViewController* bws = [st instantiateViewControllerWithIdentifier:identifier];
    if (self.browserURL) {
        bws.lastURL = self.browserURL;
    }
    bws.delegate = self;
    [self presentViewController: bws animated: YES completion:nil];
}

-(void)presentModalViewByIdentifier:(NSString *)identifier{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    PMEditNewProjectViewController * editProjectViewController = [st instantiateViewControllerWithIdentifier:identifier];
    editProjectViewController.delegate = self;
    [self presentViewController: editProjectViewController animated: YES completion:nil];
}


#pragma mark - Button Tap

- (IBAction) browserButtonTapped:(id)sender {
	[self presentBrowserByIdentifier:@"browser"];
}

- (IBAction) buttonTapped:(id)sender {
	if (sender == btnNewProject) {
        [self presentModalViewByIdentifier:@"newProjectViewController"];
	}else if (sender == btnReload){
        [self reloadProjectsView];
    }
}

#pragma mark - delegate method
-(void)reloadProjectsView{
    
    [super viewDidLoad];
    
}

-(void)reloadProjectAfterDelete{
    [self reloadProjectsView];
}

-(void)browserViewController:(SDBrowserViewController *)viewController wasDismissed:(BOOL)success{
    self.browserURL = viewController.txtURL.text;
    [self reloadProjectsView];
}

@end
