//
//  TNTripCell.h
//  TravelNow
//
//  Created by Maksym Huk on 8/31/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWRevealTableViewCell.h>

#import "TNTrip.h"

@interface TNTripCell : SWRevealTableViewCell

@property (nonatomic, strong) TNTrip *trip;

@end
