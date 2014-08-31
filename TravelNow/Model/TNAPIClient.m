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
	}
	return self;
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

- (void)addTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion {
	
}

- (void)deleteTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion {
	
}

- (void)updateTrip:(TNTrip *)trip completion:(void (^)(NSError *error))completion {
	
}

- (void)fetchTripsWithCompletion:(void (^)(NSError *error))completion {
	
}

@end
