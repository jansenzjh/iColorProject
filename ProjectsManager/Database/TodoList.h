//
//  TodoList.h
//  ProjectsManager
//
//  Created by Jansen on 1/22/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TodoList : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * estTime;
@property (nonatomic, retain) NSNumber * isFinished;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * projName;

@end
