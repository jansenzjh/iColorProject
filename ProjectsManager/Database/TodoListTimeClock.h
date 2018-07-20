//
//  TodoListTimeClock.h
//  ProjectsManager
//
//  Created by Jansen on 1/22/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TodoListTimeClock : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * taskName;

@end
