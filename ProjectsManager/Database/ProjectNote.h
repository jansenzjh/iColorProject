//
//  ProjectNote.h
//  ProjectsManager
//
//  Created by Jansen on 1/22/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProjectNote : NSManagedObject

@property (nonatomic, retain) NSString * projName;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * timeAdd;
@property (nonatomic, retain) NSDate * timeModified;

@end
