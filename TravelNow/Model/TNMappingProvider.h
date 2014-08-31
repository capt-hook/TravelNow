//
//  TNMappingProvider.h
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface TNMappingProvider : NSObject

+ (RKMapping *)userMapping;
+ (RKMapping *)tripMapping;

@end
