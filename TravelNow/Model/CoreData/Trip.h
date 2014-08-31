//
//  Trip.h
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * tripID;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) User *user;

@end
