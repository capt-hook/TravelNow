//
//  MHLog.h
//
//  Created by Maksym Huk on 8/22/13.
//  Copyright (c) 2013 Maksym Huk. All rights reserved.
//  Version 1.0
//

#import <Foundation/Foundation.h>
#import <DDLog.h>
#import <DDLogMacros.h>

enum {
    ddLogLevel = LOG_LEVEL_VERBOSE
};

@interface MHLog : NSObject

+ (void)setup;

@end
