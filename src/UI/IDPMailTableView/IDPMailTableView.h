//
//  IDPMailTableView.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IDPScrollView.h"
#import "IDPCellHeightCalculator.h"

@class IDPTableCacheObject;
@class IDPMailTableView;

@protocol IDPMailTableViewDelegate <NSTableViewDelegate>

@required
- (BOOL)mailTableViewRecalculateCellHeightIfChangeCellWidth:(IDPMailTableView *)tableView;
/**
 This methods call after window resizing.
 */
- (void)mailTableView:(IDPMailTableView *)tableView updateCellHeightCalculatorContentWidth:(IDPCellHeightCalculator *)cellHeightCalculator;

@optional
- (void)mailTableView:(IDPMailTableView *)tableView didDispalyRowAtIndex:(NSInteger)rowIndex;

@end

@protocol IDPMailTableViewDataSource  <NSTableViewDataSource>

@end

@interface IDPMailTableView : NSView <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet NSTableView  *tableView;
@property (nonatomic, strong) IBOutlet IDPScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSImageView   *animationImageView;
@property (nonatomic, strong) IBOutlet NSClipView   *clipView;

/**
 By default set to NO
 */
@property (nonatomic, assign) BOOL rowHeightResizeAnimated;

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

@property (nonatomic, strong) IDPCellHeightCalculator   *cellHeightCalculator;

- (void)reloadData;
- (void)scrollRowToVisible:(NSInteger)index;

- (void)updateCellHeight:(CGFloat)cellHeight forRow:(NSInteger)row;

- (void)resetAllData;

- (void)scrollToTopOfRow:(NSInteger)index;

@end