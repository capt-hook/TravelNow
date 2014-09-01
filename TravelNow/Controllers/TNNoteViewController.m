//
//  TNNoteViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNNoteViewController.h"

@interface TNNoteViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *noteField;
@property (nonatomic, weak) NSLayoutConstraint *noteFieldHeightConstraint;

@end

@implementation TNNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.edgesForExtendedLayout = UIRectEdgeNone;
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self configureNavigationItem];
	
	[self observeKeyboard];
	
	self.title = LS(@"Edit note");
	
	[self setupNoteField];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.noteField becomeFirstResponder];
}

- (void)configureNavigationItem {
	self.navigationItem.hidesBackButton = YES;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
}

- (void)setupNoteField {
	self.noteField = [UITextView newAutoLayoutView];
	self.noteField.text = self.initialNote;
	self.noteField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
	self.noteField.textColor = [UIColor darkGrayColor];
	self.noteField.delegate = self;
	
	[self.view addSubview:self.noteField];
	
	[self.noteField autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 5, 5, 5) excludingEdge:ALEdgeBottom];
	self.noteFieldHeightConstraint = [self.noteField autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// The callback for frame-changing of keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
	
    CGFloat height = keyboardFrame.size.height;
	
    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    self.noteFieldHeightConstraint.constant = -height;
	
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
    self.noteFieldHeightConstraint.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)doneButtonTapped:(UIButton *)button {
	DDLogVerbose(@"");
	
	[self.view endEditing:YES];
	
	if (self.doneBlock) {
		self.doneBlock(self.noteField.text);
	}
}

@end
