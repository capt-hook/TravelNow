//
//  TNFilterViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNFilterViewController.h"

@interface TNFilterViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *destinationField;

@end

@implementation TNFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = LS(@"Filter");
	
	[self configureFormFields];
}

- (void)configureFormFields {
	self.destinationField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Destination") attributes:@{ NSFontAttributeName : TNFormFieldFont,NSForegroundColorAttributeName : TNFormPlaceholderColor }];
	
	self.destinationField.text = self.filter.destination;
}

#pragma mark - UITextField

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.destinationField) {
		self.filter.destination = self.destinationField.text;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - Action

- (IBAction)cancelButtonTapped:(id)sender {
	[self.view endEditing:YES];
	if (self.cancelBlock) {
		self.cancelBlock();
	}
}

- (IBAction)doneButtonTapped:(id)sender {
	[self.view endEditing:YES];
	if (self.doneBlock) {
		self.doneBlock();
	}
}

@end
