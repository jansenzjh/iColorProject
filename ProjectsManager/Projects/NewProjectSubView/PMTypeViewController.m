//
//  PMTypeViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/11/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMTypeViewController.h"

@interface PMTypeViewController ()

@end

@implementation PMTypeViewController

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
    [self initButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initButtons{
    NSArray *typeOptionsName = [[NSArray alloc]initWithObjects:
                            NSLocalizedString(@"personal", nil),
                            NSLocalizedString(@"family", nil),
                            NSLocalizedString(@"friend", nil),
                            NSLocalizedString(@"work", nil),
                            NSLocalizedString(@"group", nil),
                            NSLocalizedString(@"physical", nil),
                            NSLocalizedString(@"spiritual", nil),
                            nil];
    NSMutableArray *buttons = [[NSMutableArray alloc]init];
    for (int i = 0; i < typeOptionsName.count; i++) {
        [buttons addObject:[self setTypeButtonWithIndex:i Title:[typeOptionsName objectAtIndex:i]]];
        [self.view addSubview:[buttons objectAtIndex:i]];
    }
}

- (FTWButton *)setTypeButtonWithIndex:(int)index Title:(NSString *)title {
    FTWButton *button = [[FTWButton alloc] init];
	
	button.frame = CGRectMake(0, 30 * index + 3 * index, 120, 30);
	[button addLightBlueStyleForState:UIControlStateNormal];
	[button setText:NSLocalizedString(title, nil) forControlState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	//[self.view addSubview:btnPriority];
    return button;
}

#pragma mark - Button Handler
- (IBAction) buttonTapped:(id)sender {
    [self.delegate typeSelected:[sender getButtonTitle]];
}
@end
