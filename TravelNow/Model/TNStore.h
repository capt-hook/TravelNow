//
//  TNStore.h
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "RKManagedObjectStore.h"

@interface TNStore : RKManagedObjectStore

+ (instancetype)sharedStore;
- (BOOL)setup;

@end
