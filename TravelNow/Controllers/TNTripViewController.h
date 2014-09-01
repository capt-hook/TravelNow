//
//  TNTripViewController.h
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TNTrip.h"

@interface TNTripViewController : UITableViewController

@property (nonatomic, strong) TNTrip *trip;

@property (nonatomic, copy) void (^cancelBlock)();
@property (nonatomic, copy) void (^doneBlock)();

@end
