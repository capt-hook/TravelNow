//
//  TNSignUpViewController.h
//  TravelNow
//
//  Created by Maksym Huk on 8/30/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNSignUpViewController : UITableViewController

@property (nonatomic, copy) void (^cancelBlock)(TNSignUpViewController *signUpVC);
@property (nonatomic, copy) void (^doneBlock)(TNSignUpViewController *signUpVC);

@end
