//
//  JGProgressHUD+Presets.h
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <JGProgressHUD.h>

@interface JGProgressHUD (Presets)

+ (instancetype)progressHUDWithText:(NSString *)text detailText:(NSString *)detailText;

- (void)dismissAsSuccess;
- (void)dismissAsError;

@end
