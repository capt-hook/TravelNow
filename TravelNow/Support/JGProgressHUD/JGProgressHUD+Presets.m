//
//  JGProgressHUD+Presets.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "JGProgressHUD+Presets.h"
#import <JGProgressHUDSuccessIndicatorView.h>
#import <JGProgressHUDErrorIndicatorView.h>

@implementation JGProgressHUD (Presets)

+ (instancetype)progressHUDWithText:(NSString *)text detailText:(NSString *)detailText {
	JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
	progressHUD.textLabel.text = text;
	progressHUD.detailTextLabel.text = detailText;
	return progressHUD;
}

- (void)dismissAsSuccess {
	self.indicatorView = [JGProgressHUDSuccessIndicatorView new];
	[self dismissAfterDelay:0.2 animated:YES];
}

- (void)dismissAsError {
	self.indicatorView = [JGProgressHUDErrorIndicatorView new];
	[self dismissAfterDelay:0.2 animated:YES];
}

@end
