//
//  MHLog.m
//
//  Created by Maksym Huk on 8/22/13.
//  Copyright (c) 2013 Maksym Huk. All rights reserved.
//  Version 1.0
//

#import "MHLog.h"

#import <DDASLLogger.h>
#import <DDTTYLogger.h>

@interface MHLogFormatter : NSObject <DDLogFormatter>

- (NSString*)formatLogMessage:(DDLogMessage *)message;

@end

@implementation MHLogFormatter

- (NSString*)formatLogMessage:(DDLogMessage *)message {
	BOOL showLocation = YES;
    NSString* prefix = nil;
    switch (message->logFlag) {
		case LOG_FLAG_INFO:
			showLocation = NO;
			prefix = @"> ";
			break;
        case LOG_FLAG_ERROR:
            prefix = @"Error: ";
            break;
        case LOG_FLAG_WARN:
            prefix = @"Warn: ";
            break;
        default:
            prefix = @"";
            break;
    }
	
	if (showLocation) {
		return [NSString stringWithFormat:@"%@[%@:%d %@] %@",
				prefix,
				message.fileName,
				message->lineNumber,
				message.methodName,
				message->logMsg];
	}
	else {
		return [NSString stringWithFormat:@"%@%@",
				prefix,
				message->logMsg];
	}
}

@end

@implementation MHLog

+ (void)setup {
	[DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDASLLogger sharedInstance].logFormatter = [[MHLogFormatter alloc] init];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDTTYLogger sharedInstance].logFormatter = [[MHLogFormatter alloc] init];
}

@end
