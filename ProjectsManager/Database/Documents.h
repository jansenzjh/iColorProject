//
//  Documents.h
//  ProjectsManager
//
//  Created by Jansen on 1/22/13.
//  Copyright (c) 2013 Jansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Documents : NSManagedObject

@property (nonatomic, retain) NSData * file;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * projName;
@property (nonatomic, retain) NSDate * timeAdd;

@end
