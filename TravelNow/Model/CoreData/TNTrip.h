//
//  TNTrip.h
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TNUser;

@interface TNTrip : NSManagedObject

@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * tripID;
@property (nonatomic, retain) TNUser *user;

@end
