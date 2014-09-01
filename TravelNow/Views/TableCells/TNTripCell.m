//
//  TNTripCell.m
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import "TNTripCell.h"

#import "NSDate+Difference.h"

@interface TNTripCell ()

@property (nonatomic, weak) IBOutlet UILabel *destinationLabel;
@property (nonatomic, weak) IBOutlet UILabel *datesLabel;
@property (nonatomic, weak) IBOutlet UILabel *daysToStartLabel;

@end

@implementation TNTripCell

- (void)setTrip:(TNTrip *)trip {
	_trip = trip;
	
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	dateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
	
	self.destinationLabel.text = trip.destination;
	
	if (trip.startDate && trip.endDate) {
		NSString *startDate = [dateFormatter stringFromDate:trip.startDate];
		NSString *endDate = [dateFormatter stringFromDate:trip.endDate];
		self.datesLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
	} else if (trip.startDate) {
		self.datesLabel.text = [NSString stringWithFormat:LS(@"Starts on %@"), [dateFormatter stringFromDate:trip.startDate]];
	} else if (trip.endDate) {
		self.datesLabel.text = [NSString stringWithFormat:LS(@"Ends on %@"), [dateFormatter stringFromDate:trip.endDate]];
	} else {
		self.datesLabel.text = nil;
	}
	
	if ([[NSDate date] compare:trip.startDate] == NSOrderedAscending) { // Trip not started yet
		self.daysToStartLabel.text = [@([NSDate daysBetweenDate:[NSDate date] andDate:trip.startDate]) stringValue];
	} else {
		self.daysToStartLabel.text = nil;
	}
}

@end
