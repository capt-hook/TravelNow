//
//  UIAlertView+Presets.m
//  LegalProof
//
//  Created by Maksym Huk on 8/24/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "UIAlertView+Presets.h"

@implementation UIAlertView (Presets)

+ (void)showAlert:(NSString*)title withMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:LS(@"OK") otherButtonTitles:nil];
    [alert show];
}

@end
