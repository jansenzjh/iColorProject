//
//  Projects.h
//  ProjectsManager
//
//  Created by Jansen on 1/22/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Projects : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * isFinished;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSDate * projDueDate;
@property (nonatomic, retain) NSDate * projModifiedDate;
@property (nonatomic, retain) NSDate * projStartDate;
@property (nonatomic, retain) NSString * timeNeedText;
@property (nonatomic, retain) NSNumber * timeNeedValue;
@property (nonatomic, retain) NSString * type;

@end
