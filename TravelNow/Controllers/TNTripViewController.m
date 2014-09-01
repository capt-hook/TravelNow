//
//  TNTripViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNTripViewController.h"
#import "TNDateViewController.h"
#import "TNNoteViewController.h"

@interface TNTripViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *destinationField;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *noteLabel;

@end

@implementation TNTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = LS(@"Edit trip");
	
	[self configureNavigationItem];
	[self configureFormFields];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.view endEditing:YES];
}

- (void)configureNavigationItem {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
}

- (void)configureFormFields {
	UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
	UIColor *color = [UIColor lightGrayColor];
	self.destinationField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LS(@"Destination") attributes:@{ NSFontAttributeName : font, NSForegroundColorAttributeName : color }];
	self.startDateLabel.font = font;
	self.endDateLabel.font = font;
	self.noteLabel.font = font;
	
	self.destinationField.text = self.trip.destination;
	[self plugStartDate:self.trip.startDate];
	[self plugEndDate:self.trip.endDate];
	[self plugNote:self.trip.note];
}

- (NSDateFormatter *)dateFormatter {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	return dateFormatter;
}

- (void)plugDate:(NSDate *)date intoLabel:(UILabel *)label placeholder:(NSString *)placeholder {
	if (date) {
		label.text = [[self dateFormatter] stringFromDate:date];
		label.textColor = [UIColor darkGrayColor];
	} else {
		label.text = placeholder;
		label.textColor = [UIColor lightGrayColor];
	}
}

- (void)plugStartDate:(NSDate *)date {
	[self plugDate:date intoLabel:self.startDateLabel placeholder:LS(@"Start date")];
}

- (void)plugEndDate:(NSDate *)date {
	[self plugDate:date intoLabel:self.endDateLabel placeholder:LS(@"End date")];
}

- (void)plugNote:(NSString *)note {
	[self.tableView beginUpdates];
	if (note.length) {
		self.noteLabel.text = note;
		self.noteLabel.textColor = [UIColor darkGrayColor];
	} else {
		self.noteLabel.text = LS(@"Note");
		self.noteLabel.textColor = [UIColor lightGrayColor];
	}
	[self.noteLabel layoutIfNeeded];
	[self.tableView endUpdates];
}

- (BOOL)validateForm {
	if (!self.trip.destination.length) {
		[UIAlertView showAlert:LS(@"Sorry!") withMessage:LS(@"Please enter the trip destination.")];
		return NO;
	}
	return YES;
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:2]]) { // note
		CGSize size = [self.noteLabel.superview systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
		return MAX(size.height + 10, [super tableView:tableView heightForRowAtIndexPath:indexPath]);
	}
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITextField

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.destinationField) {
		self.trip.destination = self.destinationField.text;
	}
}

#pragma mark - Actions

- (void)cancelButtonTapped:(UIBarButtonItem *)button {
	[self.view endEditing:YES];
	if (self.cancelBlock) {
		self.cancelBlock();
	}
}

- (void)doneButtonTapped:(UIBarButtonItem *)button {
	[self.view endEditing:YES];
	
	if (![self validateForm]) {
		return;
	}
	
	if (self.doneBlock) {
		self.doneBlock();
	}
}

- (IBAction)startDateButtonTapped:(id)sender {
	TNDateViewController *dateVC = [TNDateViewController new];
	dateVC.doneBlock = ^(NSDate *date) {
		self.trip.startDate = date;
		[self plugStartDate:date];
		[self.navigationController popToViewController:self animated:YES];
	};
	[self.navigationController pushViewController:dateVC animated:YES];
}

- (IBAction)endDateButtonTapped:(id)sender {
	TNDateViewController *dateVC = [TNDateViewController new];
	dateVC.doneBlock = ^(NSDate *date) {
		self.trip.endDate = date;
		[self plugEndDate:date];
		[self.navigationController popToViewController:self animated:YES];
	};
	[self.navigationController pushViewController:dateVC animated:YES];
}

- (IBAction)noteButtonTapped:(id)sender {
	TNNoteViewController *noteVC = [TNNoteViewController new];
	noteVC.initialNote = self.trip.note;
	noteVC.doneBlock = ^(NSString *note) {
		self.trip.note = note;
		[self plugNote:note];
		[self.navigationController popToViewController:self animated:YES];
	};
	[self.navigationController pushViewController:noteVC animated:YES];
}
   
@end
