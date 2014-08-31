//
//  NSString+Password.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "NSString+Password.h"
#import <NSString+Hashes.h>

@implementation NSString (Password)

- (NSString *)bakedPassword {
	return [self sha512];
}

@end
