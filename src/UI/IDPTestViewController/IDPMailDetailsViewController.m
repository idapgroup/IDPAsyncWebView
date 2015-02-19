//
//  IDPTestViewController.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailDetailsViewController.h"
#import "IDPMailTableView.h"
#import "IDPMailViewCell.h"
#import "NSNib+IDPExtension.h"
#import "IDPTableCacheObject.h"
#import "IDPConstants.h"
#import "IDPMailHistoryChainModel.h"
#import "IDPWebViewCellHeightCalculator.h"
#import "NSView+IDPExtension.h"
#import "NSTableView+IDPExtension.h"

static CGFloat   const kCellDefaultHeight = 190;

@interface IDPMailDetailsViewController ()

@property (nonatomic, strong, readonly) IDPMailTableView *myView;

@property (nonatomic, strong) NSMutableArray    *objects;
@property (nonatomic, strong) IDPWebViewCellHeightCalculator   *cellHeightCalculator;
@property (nonatomic, assign) BOOL blockActiveCellUpdatingNotification;

@end

@implementation IDPMailDetailsViewController

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    self.cellHeightCalculator = [IDPWebViewCellHeightCalculator new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedNewMail:) name:NOTIFICATION_CENTER_DID_SELECTED_MAIL_CHAIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedMail:) name:NOTIFICATION_CENTER_DID_SELECTED_MAIL object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cellHeightCalculator.cellHeight = 97;
    self.cellHeightCalculator.cellContentWidth = 500;
    self.myView.cellHeightCalculator = self.cellHeightCalculator;
    NSString *identifier = NSStringFromClass([IDPMailViewCell class]);
    self.objects = [NSMutableArray array];
    [self.myView.tableView registerNib:[[NSNib alloc] initWithNibNamed:identifier bundle:nil] forIdentifier:identifier];
}

#pragma mark -
#pragma mark Accessor methods

- (IDPMailTableView *)myView {
    if ([self.view isKindOfClass:[IDPMailTableView class]]) {
        return (IDPMailTableView *)self.view;
    }
    return nil;
}

#pragma mark -
#pragma mark Private methods

- (void)didSelectedNewMail:(NSNotification *)notification {
    self.blockActiveCellUpdatingNotification = NO;
    [self.cellHeightCalculator cancel];
    [self.myView resetAllData];
    IDPMailHistoryChainModel *model = notification.object;
    self.objects = [NSMutableArray array];
    NSInteger firstUnreadMail = [model indexOfFirstUnreadMail];
    firstUnreadMail = NSNotFound == firstUnreadMail ? 0 : firstUnreadMail;
    for (IDPMailMessageModel *mailMessage in model.mailMessages) {
        IDPTableCacheObject *object = [IDPTableCacheObject new];
        object.cellHeight = kCellDefaultHeight;
        object.model = mailMessage;
        [self.objects addObject:object];
    }
    self.myView.dataSourceObjects = self.objects;
    [self.myView reloadData];
    [self.myView scrollRowToVisible:firstUnreadMail];
}

- (void)didSelectedMail:(NSNotification *)notification {
    NSInteger scrollToIndex = [notification.object integerValue];
    self.blockActiveCellUpdatingNotification = YES;
    [self.myView scrollToTopOfRow:scrollToIndex];
    self.blockActiveCellUpdatingNotification = NO;
}

#pragma mark -
#pragma mark IDPMailTableViewDataSource


#pragma mark -
#pragma mark IDPMailTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = NSStringFromClass([IDPMailViewCell class]);
    IDPMailViewCell *cell = [tableView makeViewWithIdentifier:identifier owner:nil];
    if (!cell) {
        cell = [NSNib objectOfClass:NSClassFromString(identifier)];
    }
    IDPTableCacheObject *cachedObject = [self.objects objectAtIndex:row];
    [cell fillFromObject:cachedObject.model];
    return cell;
}

- (BOOL)mailTableViewRecalculateCellHeightIfChangeCellWidth:(IDPMailTableView *)tableView {
    return YES;
}

- (void)mailTableView:(IDPMailTableView *)tableView updateCellHeightCalculatorContentWidth:(IDPCellHeightCalculator *)cellHeightCalculator {
    IDPMailViewCell *cell = (IDPMailViewCell *)[tableView.tableView firstVisibleViewCellMakeIfNecessary];
    if (cell) {
        cellHeightCalculator.cellContentWidth = [cell contentWidth];
    }
}

- (void)mailTableView:(IDPMailTableView *)tableView didDispalyRowAtIndex:(NSInteger)rowIndex {
    if (!self.blockActiveCellUpdatingNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_DID_UPDATE_ACTIVE_PREVIEW_CELL object:@(rowIndex)];
    }
}

@end