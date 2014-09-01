//
//  TNDateViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNDateViewController.h"

#import <RSDFDatePickerView.h>

@interface TNDateViewController () <RSDFDatePickerViewDelegate>

@property (nonatomic, strong) RSDFDatePickerView *pickerView;

@end

@implementation TNDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = LS(@"Choose date");

	[self configurePicker];
	[self configureNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.pickerView scrollToToday:NO];
}

- (void)configurePicker {
	self.pickerView = [[RSDFDatePickerView alloc] initWithFrame:self.view.bounds];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = nil;
    [self.view addSubview:self.pickerView];
}

- (void)configureNavigationItem {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
}

#pragma mark - RSDFDatePickerView

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date {
	if (self.doneBlock) {
		self.doneBlock(date);
	}
}

#pragma mark - Actions

- (void)cancelButtonTapped:(UIBarButtonItem *)button {
	if (self.doneBlock) {
		self.doneBlock(nil);
	}
}

@end
