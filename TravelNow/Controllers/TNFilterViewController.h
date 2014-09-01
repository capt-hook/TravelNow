//
//  TNFilterViewController.h
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TNFilter.h"

@interface TNFilterViewController : UITableViewController

@property (nonatomic, strong) TNFilter *filter;

@property (nonatomic, copy) void (^doneBlock)();
@property (nonatomic, copy) void (^cancelBlock)();

@end
