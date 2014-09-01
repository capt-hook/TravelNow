//
//  TNAPIClient.h
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TNUser.h"

#import <AFNetworking/AFNetworking.h>

@interface TNAPIClient : AFHTTPSessionManager

+ (instancetype)sharedAPIClient;

- (TNUser *)user;

- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *error))completion;
- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionBlock:(void (^)(NSError *error))completion;

- (void)addTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion;
- (void)deleteTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion;
- (void)updateTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion;
- (void)fetchTripsWithCompletion:(void (^)(NSError *error))completion inContext:(NSManagedObjectContext *)context;

@end
