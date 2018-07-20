//
//  PMPriorityViewController.m
//  ProjectsManager
//
//  Created by Jansen on 1/9/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "PMPriorityViewController.h"

@interface PMPriorityViewController ()


@end

@implementation PMPriorityViewController


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
    NSArray *priorityOptionsName = [[NSArray alloc]initWithObjects:
                            NSLocalizedString(@"A1", nil),
                            NSLocalizedString(@"A2", nil),
                            NSLocalizedString(@"A3", nil),
                            NSLocalizedString(@"B1", nil),
                            NSLocalizedString(@"B2", nil),
                            NSLocalizedString(@"B3", nil),
                            NSLocalizedString(@"C1", nil),
                            NSLocalizedString(@"C2", nil),
                            NSLocalizedString(@"C3", nil),
                            nil];
    NSMutableArray *buttons = [[NSMutableArray alloc]init];
    for (int i = 0; i < priorityOptionsName.count; i++) {
        [buttons addObject:[self setPriorityButtonWithIndex:i Title:[priorityOptionsName objectAtIndex:i]]];
        [self.view addSubview:[buttons objectAtIndex:i]];
    }
}

- (FTWButton *)setPriorityButtonWithIndex:(int)index Title:(NSString *)title {
    FTWButton *button = [[FTWButton alloc] init];
	
	button.frame = CGRectMake(0, 30 * index + 3 * index, 120, 30);
	[button addGrayStyleForState:UIControlStateNormal];
	[button setText:NSLocalizedString(title, nil) forControlState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[self getColorByPriorityLetter:title] forControlState:UIControlStateNormal];
	//[self.view addSubview:btnPriority];
    return button;
}

#pragma mark - Button Handler
- (IBAction) buttonTapped:(id)sender {
        [self.delegate prioritySelected:[sender getButtonTitle]];
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

@end
