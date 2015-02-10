//
//  AppDelegate.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IDPMailListViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IBOutlet IDPMailListViewController *mailListViewController;

@end

