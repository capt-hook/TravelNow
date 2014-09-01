//
//  TNNoteViewController.h
//  TravelNow
//
//  Created by Maksym Huk on 9/1/14.
//  Copyright (c) 2014 Maksym Huk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNNoteViewController : UIViewController

@property (nonatomic, copy) NSString *initialNote;
@property (nonatomic, copy) void (^doneBlock)(NSString *note);

@end
