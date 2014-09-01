//
//  TNTripsViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNTripsViewController.h"
#import "TNTripViewController.h"

#import <CoreData/CoreData.h>
#import <NSManagedObject+MagicalRecord.h>
#import <NSManagedObject+MagicalRequests.h>
#import <NSManagedObject+MagicalFinders.h>
#import <NSManagedObject+MagicalAggregation.h>
#import <NSManagedObjectContext+MagicalRecord.h>
#import <NSManagedObjectContext+MagicalSaves.h>

#import "TNUser.h"
#import "TNTrip.h"
#import "TNAPIClient.h"

#import "TNTripCell.h"
#import <JGActionSheet.h>

@interface TNTripsViewController () <NSFetchedResultsControllerDelegate, SWRevealTableViewCellDataSource>

@property (nonatomic, strong) NSFetchedResultsController *tripsController;

@property (nonatomic) NSManagedObjectContext *tempContext;

@end

@implementation TNTripsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = LS(@"Trips");
	
	[self configureNavigationItem];
	
	[self setupTrips];
	
	[self configurePullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)configureNavigationItem {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moreButtonTapped:)];
}

- (NSFetchRequest *)tripsFetchRequest {
	return [TNTrip MR_requestAllSortedBy:@"destination" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"user = %@", [TNAPIClient sharedAPIClient].user]];
}

- (void)setupTrips {
	self.tripsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self tripsFetchRequest] managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
	self.tripsController.delegate = self;
	
	NSError *error = nil;
	if (![self.tripsController performFetch:&error]) {
		DDLogError(@"%@", error);
	}
}

- (void)configurePullToRefresh {
	[self.refreshControl addTarget:self action:@selector(pulledToRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Trip"]) {
		TNTrip *trip = sender;
		TNTripViewController *tripVC = segue.destinationViewController;
		tripVC.trip = trip;
		tripVC.doneBlock = ^{
			if (!trip.tripID) {
				JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithText:LS(@"Adding trip") detailText:LS(@"Just a sec..")];
				[progressHUD showInView:self.view.window];
				
				[[TNAPIClient sharedAPIClient] addTrip:trip completion:^(NSError *error) {
					if (error) {
						[progressHUD dismissAsError];
						[UIAlertView showAlert:LS(@"Sorry!") withMessage:error.localizedDescription];
					} else {
						[self.tempContext MR_saveToPersistentStoreAndWait];
						[progressHUD dismissAsSuccess];
					}
					self.tempContext = nil;
					[self.navigationController popToViewController:self animated:YES];
				}];
			} else {
				JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithText:LS(@"Updating trip") detailText:LS(@"Just a sec..")];
				[progressHUD showInView:self.view.window];
				
				[[TNAPIClient sharedAPIClient] updateTrip:trip completion:^(NSError *error) {
					if (error) {
						[progressHUD dismissAsError];
						[UIAlertView showAlert:LS(@"Sorry!") withMessage:error.localizedDescription];
					} else {
						[self.tempContext MR_saveToPersistentStoreAndWait];
						[progressHUD dismissAsSuccess];
					}
					self.tempContext = nil;
					[self.navigationController popToViewController:self animated:YES];
				}];
			}
		};
		tripVC.cancelBlock = ^{
			self.tempContext = nil;
			[self.navigationController popToViewController:self animated:YES];
		};
	}
}

- (void)setupTempContext {
	self.tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[self.tempContext setParentContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)addTrip {
	[self setupTempContext];
	
	TNTrip *trip = [TNTrip MR_createInContext:self.tempContext];
	TNUser *user = [TNUser MR_findFirstByAttribute:@"userID" withValue:[TNAPIClient sharedAPIClient].user.userID inContext:self.tempContext];
	[user addTripsObject:trip];

	[self performSegueWithIdentifier:@"Trip" sender:trip];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tripsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = self.tripsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TNTripCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Trip" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(TNTripCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	TNTrip *trip = [self.tripsController objectAtIndexPath:indexPath];
	cell.trip = trip;
	cell.dataSource = self;
	cell.cellRevealMode = SWCellRevealModeReversedWithAction;
	cell.performsActionOnRightOverdraw = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self setupTempContext];
	TNTrip *trip = [self.tripsController objectAtIndexPath:indexPath];
	TNTrip *tempTrip = (TNTrip *)[self.tempContext objectWithID:trip.objectID];
	[self performSegueWithIdentifier:@"Trip" sender:tempTrip];
}

#pragma mark - NSFetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
	
    UITableView *tableView = self.tableView;
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(TNTripCell *)[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - SWRevealTableViewCell

- (NSArray *)rightButtonItemsInRevealTableViewCell:(TNTripCell *)tripCell {
    SWCellButtonItem *deleteItem = [SWCellButtonItem itemWithTitle:@"Delete" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
		[self setupTempContext];
		TNTrip *trip = (TNTrip *)[self.tempContext objectWithID:tripCell.trip.objectID];
		
		JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithText:LS(@"Deleting trip") detailText:LS(@"Just a sec..")];
		[progressHUD showInView:self.view.window];
		
		[[TNAPIClient sharedAPIClient] deleteTrip:trip completion:^(NSError *error) {
			if (error) {
				[progressHUD dismissAsError];
				[UIAlertView showAlert:LS(@"Sorry!") withMessage:error.localizedDescription];
			} else {
				[self.tempContext MR_saveToPersistentStoreAndWait];
				[progressHUD dismissAsSuccess];
			}
			self.tempContext = nil;
		}];
		return YES;
	}];
	
    deleteItem.backgroundColor = [UIColor redColor];
    deleteItem.tintColor = [UIColor whiteColor];
    deleteItem.width = 75;
	
    return @[ deleteItem ];
}

#pragma mark - Actions

- (IBAction)addButtonTapped:(id)sender {
	[self addTrip];
}

- (void)pulledToRefresh {
	[self setupTempContext];
	self.view.window.userInteractionEnabled = NO;
	[[TNAPIClient sharedAPIClient] fetchTripsWithCompletion:^(NSError *error) {
		if (!error) {
			[self.tempContext MR_saveToPersistentStoreAndWait];
		}
		self.tempContext = nil;
		self.view.window.userInteractionEnabled = YES;
		[self.refreshControl endRefreshing];
	} inContext:self.tempContext];
}

- (void)moreButtonTapped:(UIBarButtonItem *)button {
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	JGActionSheetSection *actionSection = [JGActionSheetSection sectionWithTitle:LS(@"Travel Now!") message:version buttonTitles:@[ @"Filter", @"Print", @"Log Out" ] buttonStyle:JGActionSheetButtonStyleDefault];
	[actionSection setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:2];
	JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[ @"Cancel" ] buttonStyle:JGActionSheetButtonStyleCancel];
	
	NSArray *sections = @[ actionSection, cancelSection];
	
	JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
	
	[sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
		[sheet dismissAnimated:YES];
	}];
	
	[sheet showInView:self.view.window animated:YES];
}

@end
