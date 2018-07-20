//
//  PMProjectListLiteViewController.m
//  ProjectsManager
//
//  Created by Jansen on 2/10/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMProjectListLiteViewController.h"

@interface PMProjectListLiteViewController ()
@property UIEdgeInsets pageMargins;
@property CGSize pageSize;
@end

@interface UIPrintPageRenderer (PDF)

- (NSData*) printToPDF;

@end

@implementation PMProjectListLiteViewController

@synthesize projList;
@synthesize lblInfo;
@synthesize lblSelectProj;
@synthesize webView;
@synthesize pageMargins;
@synthesize pageSize;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lblInfo.text = NSLocalizedString(@"lbl web save", nil);

    self.projList = [[NSMutableArray alloc]initWithArray:[self getProjectsFromDatabase]];
    
    self.pageMargins = UIEdgeInsetsMake(10, 5, 10, 5);
    
    self.pageSize = CGSizeMake(595,842);
    
    self.lblSelectProj.text = NSLocalizedString(@"select project", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.projList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"project item";
    PMCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - cell configure
- (void)configureCell:(PMCustomCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Projects *pj = [projList objectAtIndex:indexPath.row];
    cell.textLabel.text = pj.name;
    cell.detailTextLabel.text = pj.desc;
    cell.badgeString = [NSString stringWithFormat:@"%@ - %@ %@", pj.priority, pj.timeNeedValue, pj.timeNeedText];
    cell.badge.radius = 9;
    cell.showShadow = NO;
    cell.badgeColor = [self getColorByPriorityLetter:pj.priority];
}

#pragma mark - Helpers
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
        return [UIColor grayColor];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save page to local file as pdf
    Projects *pj = [self.projList objectAtIndex:indexPath.row];
    self.selectedProjName = pj.name;
    [self saveWebpageToDoc];
}

#pragma mark - database

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
                                        initWithKey:@"priority" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    return objects;
    
}


- (IBAction)btnDone:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PDF Save

-(void)saveWebpageToDoc{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path =[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.pdf",self.selectedProjName,self.pageName]];
    
    [self saveWebToPDF:path];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveWebToPDF:(NSString *)path{
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    
    [render addPrintFormatter:self.webView.viewPrintFormatter startingAtPageAtIndex:0];
    
    CGRect printableRect = CGRectMake(self.pageMargins.left,
                                      self.pageMargins.top,
                                      self.pageSize.width - self.pageMargins.left - self.pageMargins.right,
                                      self.pageSize.height - self.pageMargins.top - self.pageMargins.bottom);
    
    CGRect paperRect = CGRectMake(0, 0, self.pageSize.width, self.pageSize.height);
    
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    NSData *pdfData = [render printToPDF];
    
    [pdfData writeToFile: path atomically: YES];
}


@end

@implementation UIPrintPageRenderer (PDF)

- (NSData*) printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, CGRectZero, nil );
    
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

@end


















