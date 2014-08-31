//
//  TNStore.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNStore.h"
#import <RestKit/RestKit.h>

@implementation TNStore

static TNStore *_sharedStore = nil;

+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedStore = [TNStore new];
	});
}

+ (instancetype)sharedStore {
	return _sharedStore;
}

- (id)init {
	if (self = [super initWithManagedObjectModel:[self managedObjectModel]]) {
	}
	return self;
}

- (NSManagedObjectModel *)managedObjectModel {
    return [NSManagedObjectModel mergedModelFromBundles:nil];
}

- (id)optionsForSqliteStore {
    return @{ NSInferMappingModelAutomaticallyOption: @YES,
			  NSMigratePersistentStoresAutomaticallyOption: @YES };
}

- (BOOL)setup {
	NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"trips.sqlite"];
    DDLogInfo(@"Setting up store at %@", path);
	NSError *error = nil;
    [self addSQLitePersistentStoreAtPath:path
				  fromSeedDatabaseAtPath:nil
					   withConfiguration:nil
								 options:[self optionsForSqliteStore]
								   error:&error];
	if (error) {
		DDLogError(@"%@", error);
		return NO;
	}
    [self createManagedObjectContexts];
	return YES;
}

@end
