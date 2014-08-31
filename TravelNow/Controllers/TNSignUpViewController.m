//
//  TNSignUpViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 8/30/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNSignUpViewController.h"
#import "TNAPIClient.h"
#import "NSString+Password.h"

@interface TNSignUpViewController () <UITextFieldDelegate>

@property (nonatomic, strong) JGProgressHUD *progressHUD;

@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordField;

@end

@implementation TNSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self configureFormFields];
}

- (void)configureFormFields {
}

- (void)signUp {
	NSString *email = self.emailField.text;
	NSString *password = [self.passwordField.text bakedPassword];
	
	self.progressHUD = [JGProgressHUD progressHUDWithText:LS(@"Signing you up") detailText:LS(@"Just a sec..")];
	[self.progressHUD showInView:self.view.window];
	
	[[TNAPIClient sharedAPIClient] signUpWithEmail:email password:password completionBlock:^(NSError *error) {
		if (error) {
			[self.progressHUD dismissAsError];
			[UIAlertView showAlert:LS(@"Sorry") withMessage:error.localizedDescription];
		} else {
			[self.progressHUD dismissAsSuccess];
			if (self.doneBlock) {
				self.doneBlock(self);
			}
		}
	}];
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.emailField) {
		[self.passwordField becomeFirstResponder];
	} else if (textField == self.passwordField) {
		[self.confirmPasswordField becomeFirstResponder];
	} else if (textField == self.confirmPasswordField) {
		[self signUp];
	}
	return NO;
}

#pragma mark - Actions

- (IBAction)cancelButtonTapped:(id)sender {
	if (self.cancelBlock) {
		self.cancelBlock(self);
	}
}

- (IBAction)signUpButtonTapped:(id)sender {
	[self signUp];
}

@end
