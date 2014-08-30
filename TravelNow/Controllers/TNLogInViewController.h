//
//  TNLogInViewController.h
//  TravelNow
//
//  Created by Maksym Huk on 8/30/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNLogInViewController : UITableViewController

@property (nonatomic, copy) void (^cancelBlock)(TNLogInViewController *logInVC);
@property (nonatomic, copy) void (^doneBlock)(TNLogInViewController *logInVC);

@end
