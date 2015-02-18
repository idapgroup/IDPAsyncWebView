//
//  IDPMailListViewController.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IDPMailListViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSArray   *mailObjects;

- (void)reloadData;

@end
