//
//  TNLogInViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 8/30/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNLogInViewController.h"

#import "NSString+Password.h"
#import "TNAPIClient.h"

@interface TNLogInViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;

@end

@implementation TNLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (QA) {
		self.emailField.text = QAEmail;
		self.passwordField.text = QAPassword;
	}
}

- (void)logIn {
	NSString *email = self.emailField.text;
	NSString *password = [self.passwordField.text bakedPassword];
	
	JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithText:LS(@"Logging you in") detailText:LS(@"Just a sec..")];
	[progressHUD showInView:self.view.window];
	
	[[TNAPIClient sharedAPIClient] logInWithEmail:email password:password completion:^(NSError *error) {
		if (error) {
			[progressHUD dismissAsError];
			[UIAlertView showAlert:LS(@"Sorry!") withMessage:error.localizedDescription];
		} else {
			[progressHUD dismissAsSuccess];
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
