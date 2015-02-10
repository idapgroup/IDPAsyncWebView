//
//  IDPMailTableView.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IDPTableCacheObject;

@protocol IDPMailTableViewDelegate <NSTableViewDelegate>

@end

@protocol IDPMailTableViewDataSource  <NSTableViewDataSource>

@end

@interface IDPMailTableView : NSView <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet NSTableView  *tableView;
@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;

/**
 Set this delegate instead of tableView delegate.
 */
@property (nonatomic, weak) IBOutlet id<IDPMailTableViewDelegate>   delegate;
/**
 Set this dataSource instead of tableView dataSource.
 */
@property (nonatomic, weak) IBOutlet id<IDPMailTableViewDataSource> dataSource;

/**
 Must contain IDPTableCacheObject objects.
 */
@property (nonatomic, strong) NSArray   *dataSourceObjects;;

@end