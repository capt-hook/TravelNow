//
//  TravelNowTests.m
//  TravelNowTests
//
//  Created by Maksym Huk on 8/30/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TNAPIClient.h"
#import "TNTrip.h"

#import "NSString+Password.h"
#import <NSManagedObject+MagicalRecord.h>

@interface TravelNowTests : XCTestCase

@end

@implementation TravelNowTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testLogIn {
	[[TNAPIClient sharedAPIClient] logInWithEmail:QAEmail password:[QAPassword bakedPassword] completion:^(NSError *error) {
		XCTAssertNil(error, @"");
	}];
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

- (void)testAddTrip {
	[[TNAPIClient sharedAPIClient] logInWithEmail:QAEmail password:[QAPassword bakedPassword] completion:^(NSError *error) {
		XCTAssertNil(error, @"");
		
		TNTrip *trip = [TNTrip MR_createEntity];
		trip.destination = @"Paris";
		trip.startDate = [NSDate date];
		trip.endDate = [NSDate date];
		trip.note = @"Note";
		[[TNAPIClient sharedAPIClient] addTrip:trip completion:^(NSError *error) {
			XCTAssertNil(error, @"");
		}];
	}];
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

- (void)testDeleteTrip {
	[[TNAPIClient sharedAPIClient] logInWithEmail:QAEmail password:[QAPassword bakedPassword] completion:^(NSError *error) {
		XCTAssertNil(error, @"");
		
		TNTrip *trip = [TNTrip MR_createEntity];
		trip.destination = @"Paris";
		trip.startDate = [NSDate date];
		trip.endDate = [NSDate date];
		trip.note = @"Note";
		[[TNAPIClient sharedAPIClient] addTrip:trip completion:^(NSError *error) {
			XCTAssertNil(error, @"");
			[[TNAPIClient sharedAPIClient] deleteTrip:trip completion:^(NSError *error) {
				XCTAssertNil(error, @"");
			}];
		}];
	}];
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

@end
