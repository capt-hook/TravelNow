//
//  TNFilter.h
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TNUser;

@interface TNFilter : NSManagedObject

@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) TNUser *user;

@end
