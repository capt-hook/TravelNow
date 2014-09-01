//
//  TNUser.h
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TNFilter, TNTrip;

@interface TNUser : NSManagedObject

@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSSet *trips;
@property (nonatomic, retain) TNFilter *filter;
@end

@interface TNUser (CoreDataGeneratedAccessors)

- (void)addTripsObject:(TNTrip *)value;
- (void)removeTripsObject:(TNTrip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
