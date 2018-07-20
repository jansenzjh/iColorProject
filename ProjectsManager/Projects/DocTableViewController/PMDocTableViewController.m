//
//  PMDocTableViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/25/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMDocTableViewController.h"

@interface PMDocTableViewController ()
@property int selectedItemIndex;
@end

@implementation PMDocTableViewController

@synthesize docList;
@synthesize delegate;
@synthesize selectedItemIndex;

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

    [self reloadDocList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadDocList{
    self.docList = [[NSMutableArray alloc]init];
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.projName];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (NSString *fileName in directoryContent) {
        NSString *dot = [fileName substringWithRange:NSMakeRange(0, 1)];
        if (![dot isEqualToString:@"."]) {
            [self.docList addObject:fileName];
        }
    }
    //self.docList = [NSMutableArray arrayWithArray:directoryContent];
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
    return self.docList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"doc item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = [self.docList objectAtIndex:indexPath.row];
    cell.textLabel.text = fileName;
    cell.imageView.image = [UIImage imageNamed:[self getImageNameByFileName:fileName]];
    
}

-(NSString *)getImageNameByFileName:(NSString *)fileName{
    NSString *fn = [fileName copy];
    if ([[fn lowercaseString] hasSuffix:@"jpg"] || [[fn lowercaseString] hasSuffix:@"jepg"]){
        return @"jpg.png";
    }else if ([[fn lowercaseString] hasSuffix:@"gif"]){
        return @"gif.png";
    }else if ([[fn lowercaseString] hasSuffix:@"png"]){
        return @"png.png";
    }else if ([[fn lowercaseString] hasSuffix:@"zip"]){
        return @"zip.png";
    }else if ([[fn lowercaseString] hasSuffix:@"rar"]){
        return @"zip.png";
    }else if ([[fn lowercaseString] hasSuffix:@"pdf"]){
        return @"pdf.png";
    }else if ([[fn lowercaseString] hasSuffix:@"doc"] || [[fn lowercaseString] hasSuffix:@"docx"]){
        return @"word.png";
    }else if ([[fn lowercaseString] hasSuffix:@"ppt"] || [[fn lowercaseString] hasSuffix:@"pptx"]){
        return @"ppt.png";
    }else if ([[fn lowercaseString] hasSuffix:@"xls"] || [[fn lowercaseString] hasSuffix:@"xlsx"]){
        return @"excel.png";
    }else {
        return @"Text.png";
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self removeFile:[self.docList objectAtIndex:indexPath.row] fromProject:self.projName];
        [self reloadDocList];
        [self.delegate reloadDocListTable];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.selectedItemIndex = indexPath.row;
    QLPreviewController * preview = [[QLPreviewController alloc] init];
	preview.dataSource = self;
	preview.currentPreviewItemIndex = indexPath.row;
    [self.delegate presentPreviewController:preview];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - QLPreview delegate

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{

    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", self.projName, [docList objectAtIndex:selectedItemIndex]]];
    return [NSURL fileURLWithPath:path];
}

#pragma mark - delegate methods


- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView **)view
{
    //Rectangle of the button which has been pressed by the user
    //Zoom in and out effect appears to happen from the button which is pressed.

    UIView *view1 = self.view;
    return view1.frame;
}


#pragma mark - Helpers
-(void)removeFile:(NSString *)fileName fromProject:(NSString *)pName{
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", pName, fileName]];
    NSError *error;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
        {
            NSLog(@"Delete directory error: %@", error);
        }
    }
    
}
@end
