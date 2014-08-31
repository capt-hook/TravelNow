//
//  LMMacros.h
//  LinMedia
//
//  Created by Maksym Huk on 8/27/14.
//  Copyright (c) 2014 Mobiquity. All rights reserved.
//

#define LS(...) NSLocalizedString((__VA_ARGS__), nil)

#define MHInterfaceIdiom UI_USER_INTERFACE_IDIOM()
#define MHPad (MHInterfaceIdiom == UIUserInterfaceIdiomPad)
#define MHPhone5 (!MHPad && [[UIScreen mainScreen] bounds].size.height == 568.0)

#define MHSystemVersionGreaterThanOrEqualTo(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define MHIOS7() MHSystemVersionGreaterThanOrEqualTo(@"7.0")

#define BaseURL @"https://blazing-heat-8600.firebaseio.com"