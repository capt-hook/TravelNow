//
//  TNLogInViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 8/30/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNLogInViewController.h"

@interface TNLogInViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;

@end

@implementation TNLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self configureFormFields];
}

- (void)configureFormFields {
}

- (void)logIn {
	if (self.doneBlock) {
		self.doneBlock(self);
	}
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.emailField) {
		[self.passwordField becomeFirstResponder];
	} else if (textField == self.passwordField) {
		[self logIn];
	}
	return NO;
}

#pragma mark - Actions

- (IBAction)cancelButtonTapped:(id)sender {
	if (self.cancelBlock) {
		self.cancelBlock(self);
	}
}

- (IBAction)logInButtonTapped:(id)sender {
	[self logIn];
}

@end
