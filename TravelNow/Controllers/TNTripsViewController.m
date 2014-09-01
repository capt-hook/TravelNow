//
//  TNTripsViewController.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNTripsViewController.h"
#import "TNTripViewController.h"
#import "TNFilterViewController.h"

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
@property (nonatomic) BOOL shouldRefreshOnAppear;

@end

@implementation TNTripsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = LS(@"Trips");
	
	[self configureNavigationItem];
	
	[self setupTrips];
	
	[self configurePullToRefresh];
	
	self.shouldRefreshOnAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.shouldRefreshOnAppear) {
		self.shouldRefreshOnAppear = NO;
		[self refresh];
	}
}

- (void)configureNavigationItem {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moreButtonTapped:)];
}

- (NSFetchRequest *)tripsFetchRequest {
	TNUser *user = [TNAPIClient sharedAPIClient].user;
	NSMutableArray *predicates = [NSMutableArray new];
	[predicates addObject:[NSPredicate predicateWithFormat:@"user = %@", user]];
	if (user.filter.destination.length) {
		[predicates addObject:[NSPredicate predicateWithFormat:@"destination CONTAINS[c] %@", user.filter.destination]];
	}
	NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
	return [TNTrip MR_requestAllSortedBy:@"destination" ascending:YES withPredicate:predicate];
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
	} else if ([segue.identifier isEqualToString:@"Filter"]) {
		[self setupTempContext];
		UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
		TNFilterViewController *filterVC = navigationController.childViewControllers[0];
		TNUser *user = (TNUser *)[self.tempContext objectWithID:[TNAPIClient sharedAPIClient].user.objectID];
		TNFilter *filter = user.filter;
		if (!filter) {
			filter = [TNFilter MR_createInContext:self.tempContext];
			user.filter = filter;
		}
		filterVC.filter = filter;
		filterVC.doneBlock = ^{
			[self.tempContext MR_saveToPersistentStoreAndWait];
			self.tempContext = nil;
			[self applyFilter];
			[self dismissViewControllerAnimated:YES completion:nil];
		};
		filterVC.cancelBlock = ^{
			self.tempContext = nil;
			[self dismissViewControllerAnimated:YES completion:nil];
		};
	}
}

- (void)setupTempContext {
	self.tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[self.tempContext setParentContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)applyFilter {
	[self setupTrips];
	[self.tableView reloadData];
}

- (void)addTrip {
	[self setupTempContext];
	
	TNTrip *trip = [TNTrip MR_createInContext:self.tempContext];
	TNUser *user = [TNUser MR_findFirstByAttribute:@"userID" withValue:[TNAPIClient sharedAPIClient].user.userID inContext:self.tempContext];
	[user addTripsObject:trip];

	[self performSegueWithIdentifier:@"Trip" sender:trip];
}

- (NSDate *)datePlusOneMonth:(NSDate *)date {
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setMonth:1];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	return [calendar dateByAddingComponents:dateComponents toDate:date options:0];
}

- (NSString *)textToPrintForTrip:(TNTrip *)trip {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	return [NSString stringWithFormat:@"%@: %@ - %@\n%@\n\n", trip.destination, [dateFormatter stringFromDate:trip.startDate], [dateFormatter stringFromDate:trip.endDate], trip.note];
}

- (NSString *)textToPrint {
	NSMutableString *text = [NSMutableString new];
	
	NSDate *startDate = [NSDate date];
	NSDate *endDate = [self datePlusOneMonth:startDate];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) AND (startDate <= %@)", startDate, endDate];
	NSArray *trips = [TNTrip MR_findAllSortedBy:@"destination" ascending:YES withPredicate:predicate];
	for (TNTrip *trip in trips) {
		[text appendString:[self textToPrintForTrip:trip]];
	}
	return text;
}

- (NSString *)printJobName {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	dateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
	dateFormatter.dateFormat = @"MMM";
	return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)printTravelPlan {
	UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
	if (!printController) {
		[UIAlertView showAlert:LS(@"Sorry!") withMessage:LS(@"Can not find a printer.")];
	} else {
		UISimpleTextPrintFormatter *printFormatter = [[UISimpleTextPrintFormatter alloc] initWithText:[self textToPrint]];
		printController.printFormatter = printFormatter;
		
		UIPrintInfo *printInfo = [UIPrintInfo printInfo];
		printInfo.outputType = UIPrintInfoOutputGeneral;
		printInfo.jobName = [self printJobName];
		printInfo.duplex = UIPrintInfoDuplexLongEdge;
		printController.printInfo = printInfo;
		
		[printController presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
			if (error) {
				DDLogError(@"%@", error);
				[UIAlertView showAlert:LS(@"Sorry!") withMessage:error.localizedDescription];
			}
		}];
	}
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

- (void)refresh {
	[self setupTempContext];
	
	JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithText:LS(@"Fetching trips") detailText:LS(@"Just a sec..")];
	[progressHUD showInView:self.view.window];
	
	[[TNAPIClient sharedAPIClient] fetchTripsWithCompletion:^(NSError *error) {
		if (error) {
			[progressHUD dismissAsError];
			[UIAlertView showAlert:LS(@"Sorry!") withMessage:error.localizedDescription];
		} else {
			[self.tempContext MR_saveToPersistentStoreAndWait];
			[progressHUD dismissAsSuccess];
		}
		self.tempContext = nil;
	} inContext:self.tempContext];
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
		if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) { // filter
			[self performSegueWithIdentifier:@"Filter" sender:nil];
		} else if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:0]]) { // print
			[self printTravelPlan];
		} else if ([indexPath isEqual:[NSIndexPath indexPathForRow:2 inSection:0]]) { // log out
			[self.navigationController popToViewController:self.navigationController.childViewControllers[0] animated:YES];
		}
		[sheet dismissAnimated:YES];
	}];
	
	[sheet showInView:self.view.window animated:YES];
}

@end
