//
//  PMCustomCell.h
//  ProjectsManager
//
//  Created by Jansen on 1/19/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import "TDBadgedCell.h"

@interface PMCustomCell : TDBadgedCell
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
- (IBAction)btnCheckbox:(UIButton *)sender;

@end
