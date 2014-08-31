//
//  TNMappingProvider.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNMappingProvider.h"

#import "User.h"
#import "Trip.h"
#import "TNStore.h"

@implementation TNMappingProvider

+ (RKMapping *)userMapping {
	RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:[TNStore sharedStore]];
	[mapping addAttributeMappingsFromArray:@[ @"userID", @"email" ]];
	[mapping addRelationshipMappingWithSourceKeyPath:@"trips" mapping:[TNMappingProvider tripMapping]];
	return mapping;
}

+ (RKMapping *)tripMapping {
	RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:@"Trip" inManagedObjectStore:[TNStore sharedStore]];
	[mapping addAttributeMappingsFromArray:@[ @"tripID", @"order", @"destination", @"startDate", @"endDate", @"note" ]];
	return mapping;
}

@end
