//
//  TNWelcomeViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 8/30/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNWelcomeViewController.h"
#import "TNLogInViewController.h"
#import "TNSignUpViewController.h"

@interface TNWelcomeViewController ()

@end

@implementation TNWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self configureNavigationItem];
}

- (void)configureNavigationItem {
	[self.navigationController setNavigationBarHidden:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"LogIn"]) {
		UINavigationController *navigationController = segue.destinationViewController;
		TNLogInViewController *logInVC = navigationController.viewControllers[0];
		logInVC.doneBlock = ^(TNLogInViewController *logInVC) {
			[self dismissViewControllerAnimated:NO completion:nil];
		};
		logInVC.cancelBlock = ^(TNLogInViewController *logInVC) {
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	} else if ([segue.identifier isEqualToString:@"SignUp"]) {
		UINavigationController *navigationController = segue.destinationViewController;
		TNSignUpViewController *signUpVC = navigationController.viewControllers[0];
		signUpVC.doneBlock = ^(TNSignUpViewController *signUpVC) {
			[self dismissViewControllerAnimated:NO completion:nil];
		};
		signUpVC.cancelBlock = ^(TNSignUpViewController *signUpVC) {
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
}

@end
