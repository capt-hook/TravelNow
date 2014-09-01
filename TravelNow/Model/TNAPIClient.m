//
//  TNAPIClient.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNAPIClient.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import "TNUser.h"
#import "TNTrip.h"

#import <NSManagedObject+MagicalRecord.h>
#import <NSManagedObject+MagicalFinders.h>
#import <NSManagedObjectContext+MagicalRecord.h>
#import <NSManagedObjectContext+MagicalSaves.h>

@interface TNAPIClient ()

@property (nonatomic, strong) TNUser *user;

@end

@implementation TNAPIClient

static TNAPIClient *_sharedAPIClient = nil;

+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedAPIClient = [TNAPIClient new];
	});
}

+ (instancetype)sharedAPIClient {
	return _sharedAPIClient;
}

- (id)init {
	if (self = [super initWithBaseURL:[NSURL URLWithString:BaseURL]]) {
		self.requestSerializer = [AFJSONRequestSerializer serializer];
		self.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
		self.responseSerializer.acceptableStatusCodes = [self acceptableStatusCodes];
	}
	return self;
}

- (NSIndexSet *)acceptableStatusCodes {
	NSMutableIndexSet *statusCodes;
	[statusCodes addIndex:200];
	[statusCodes addIndex:204];
	return statusCodes;
}

- (NSString *)pathWithAuth:(NSString *)path {
	return [NSString stringWithFormat:@"%@?auth=%@", path, self.user.authToken];
}

- (void)putUser:(TNUser *)user completion:(void (^)(NSError *error))completion {
	[self PUT:[self pathWithAuth:@"users.json"] parameters:@{ user.userID : @{ @"email" : user.email } } success:^(NSURLSessionDataTask *task, id responseObject) {
		DDLogInfo(@"PUT user success with response: %@", responseObject);
		if (completion) {
			completion(nil);
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		DDLogError(@"%@", error.localizedDescription);
		if (completion) {
			completion(error);
		}
	}];
}

- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *error))completion {
	Firebase *firebase = [[Firebase alloc] initWithUrl:BaseURL];
	FirebaseSimpleLogin *auth = [[FirebaseSimpleLogin alloc] initWithRef:firebase];
	[auth loginWithEmail:email andPassword:password withCompletionBlock:^(NSError *error, FAUser *authUser) {
		if (error) {
			DDLogError(@"%@", error.localizedDescription);
			if (completion) {
				completion(error);
			}
		} else {
			DDLogInfo(@"User ID: %@ token: %@", authUser.userId, authUser.authToken);
			TNUser *user = [TNUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userID = %@", authUser.userId]];
			if (!user) {
				user = [TNUser MR_createEntity];
				user.email = authUser.email;
				user.userID = authUser.userId;
				user.authToken = authUser.authToken;
			} else {
				user.authToken = authUser.authToken;
			}
			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
			self.user = user;
			if (completion) {
				completion(nil);
			}
		}
	}];
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionBlock:(void (^)(NSError *error))completion {
	Firebase *firebase = [[Firebase alloc] initWithUrl:BaseURL];
	FirebaseSimpleLogin *auth = [[FirebaseSimpleLogin alloc] initWithRef:firebase];
	[auth createUserWithEmail:email password:password andCompletionBlock:^(NSError *error, FAUser *user) {
		if (error) {
			DDLogError(@"%@", error.localizedDescription);
			if (completion) {
				completion(error);
			}
		} else {
			[self logInWithEmail:email password:password completion:^(NSError *error) {
				if (error) {
					if (completion) {
						completion(error);
					}
				} else {
					[self putUser:self.user completion:^(NSError *error) {
						if (completion) {
							completion(error);
						}
					}];
				}
			}];
		}
	}];
}

- (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    return dateFormatter;
}

- (void)addTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion {
	NSString *path = [NSString stringWithFormat:@"users/%@/trips.json", self.user.userID];
	NSDateFormatter *dateFormatter = [self dateFormatter];
	[self POST:[self pathWithAuth:path] parameters:@{ @"destination" : trip.destination, @"startDate" : (trip.startDate ? [dateFormatter stringFromDate:trip.startDate] : @""), @"endDate" : (trip.endDate ? [dateFormatter stringFromDate:trip.endDate] : @""), @"note" : trip.note ? trip.note : @"" } success:^(NSURLSessionDataTask *task, id responseObject) {
		DDLogInfo(@"POST trip success with response: %@", responseObject);
		NSString *tripID = [responseObject objectForKey:@"name"];
		trip.tripID = tripID;
		if (completion) {
			completion(nil);
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		DDLogError(@"%@", error.localizedDescription);
		if (completion) {
			completion(error);
		}
	}];
}

- (void)deleteTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion {
	NSString *path = [NSString stringWithFormat:@"users/%@/trips/%@.json", self.user.userID, trip.tripID];
	[self DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		DDLogInfo(@"DELETE trip success with response: %@", responseObject);
		[trip MR_deleteInContext:trip.managedObjectContext];
		if (completion) {
			completion(nil);
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		DDLogError(@"%@", error);
		if (completion) {
			completion(error);
		}
	}];
}

- (void)updateTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion {
	NSString *path = [NSString stringWithFormat:@"users/%@/trips/%@.json", self.user.userID, trip.tripID];
	NSDateFormatter *dateFormatter = [self dateFormatter];
	[self PUT:[self pathWithAuth:path] parameters:@{ @"destination" : trip.destination, @"startDate" : (trip.startDate ? [dateFormatter stringFromDate:trip.startDate] : @""), @"endDate" : (trip.endDate ? [dateFormatter stringFromDate:trip.endDate] : @""), @"note" : trip.note ? trip.note : @"" } success:^(NSURLSessionDataTask *task, id responseObject) {
		DDLogInfo(@"POST trip success with response: %@", responseObject);
		if (completion) {
			completion(nil);
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		DDLogError(@"%@", error.localizedDescription);
		if (completion) {
			completion(error);
		}
	}];
}

- (void)fetchTripsWithCompletion:(void (^)(NSError *error))completion inContext:(NSManagedObjectContext *)context {
	TNUser *user = (TNUser *)[context objectWithID:self.user.objectID];
	[TNTrip MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"user = %@", user] inContext:context];
	NSString *path = [NSString stringWithFormat:@"users/%@/trips.json", self.user.userID];
	NSDateFormatter *dateFormatter = [self dateFormatter];
	[self GET:[self pathWithAuth:path] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		DDLogInfo(@"GET trips success with response: %@", responseObject);
		if ([responseObject isKindOfClass:[NSDictionary class]]) {
			NSDictionary *tripsDict = responseObject;
			for (NSString *tripID in tripsDict) {
				NSDictionary *tripDict = tripsDict[tripID];
				TNTrip *trip = [TNTrip MR_createInContext:context];
				[user addTripsObject:trip];
				trip.tripID = tripID;
				trip.destination = tripDict[@"destination"];
				if (tripDict[@"startDate"]) {
					trip.startDate = [dateFormatter dateFromString:tripDict[@"startDate"]];
				}
				if (tripDict[@"endDate"]) {
					trip.endDate = [dateFormatter dateFromString:tripDict[@"endDate"]];
				}
				trip.note = tripDict[@"note"];
			}
		}
		if (completion) {
			completion(nil);
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		DDLogError(@"%@", error.localizedDescription);
		if (completion) {
			completion(error);
		}
	}];
}

@end
