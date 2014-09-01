//
//  TNDateViewController.h
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNDateViewController : UIViewController

@property (nonatomic, copy) void (^doneBlock)(NSDate *date);

@end
