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
#import <QuartzCore/QuartzCore.h>

static CGFloat   const kCellDefaultHeight = 190;
static CGFloat   const kCellDefaultContentWidth = 526;
static CGFloat   const kIDPAnimationDuration = 0.55;
static CGFloat   const kIDPCellHeightExeptContent = 97;

@interface IDPMailDetailsViewController ()

@property (nonatomic, strong, readonly) IDPMailTableView *myView;

@property (nonatomic, strong) NSMutableArray    *objects;
@property (nonatomic, strong) IDPWebViewCellHeightCalculator   *cellHeightCalculator;
@property (nonatomic, assign) BOOL blockActiveCellUpdatingNotification;
@property (nonatomic, assign) NSInteger curIndex;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateMailDetails:) name:NOTIFICATION_CENTER_DID_UPDATE_MAIL_DETAILS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedMail:) name:NOTIFICATION_CENTER_DID_SELECTED_MAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willUpdateMailDetails:) name:NOTIFICATION_CENTER_WILL_UPDATE_MAIL_DETAILS object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.myView.scrollView.wantsLayer = YES;
    self.cellHeightCalculator.cellHeight = kIDPCellHeightExeptContent;
    self.cellHeightCalculator.cellContentWidth = kCellDefaultContentWidth;
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

- (void)willUpdateMailDetails:(NSNotification *)notification {
    NSImage *image = [self.myView imageFromView];
    self.myView.animationImageView.image = image;
}

- (void)didUpdateMailDetails:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:kIDPNCRowIndex] integerValue];
    
    self.blockActiveCellUpdatingNotification = NO;
    [self.cellHeightCalculator cancel];
    [self.myView resetAllData];
    IDPMailHistoryChainModel *model = [userInfo objectForKey:kIDPNCObject];
    self.objects = [NSMutableArray array];
    NSInteger firstUnreadMail = [model indexOfFirstUnreadMail];
    firstUnreadMail = NSNotFound == firstUnreadMail ? 0 : firstUnreadMail;
    for (IDPMailMessageModel *mailMessage in model.mailMessages) {
        IDPTableCacheObject *object = [IDPTableCacheObject new];
        object.cellHeight = kCellDefaultHeight;
        object.model = mailMessage;
        [self.objects addObject:object];
    }
    self.myView.rowHeightResizeAnimated = NO;
    self.myView.dataSourceObjects = self.objects;
    [self.myView reloadData];
    [self.myView scrollRowToVisible:firstUnreadMail];
    
    [self.myView.clipView.layer removeAllAnimations];
    
    CATransition *transition = [CATransition animation];
    transition.duration = kIDPAnimationDuration;
    transition.subtype = index < self.curIndex ? kCATransitionFromTop : kCATransitionFromBottom;
    transition.type = kCATransitionMoveIn;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.myView.rowHeightResizeAnimated = YES;
    }];
    [self.myView.clipView.layer addAnimation:transition forKey:nil];
    [CATransaction commit];
    
    self.curIndex = index;
}

- (void)didSelectedMail:(NSNotification *)notification {
    NSInteger scrollToIndex = [[notification.userInfo objectForKey:kIDPNCRowIndex] integerValue];
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
    IDPMailViewCell *cell = (IDPMailViewCell *)[tableView.tableView firstVisibleViewCell];
    CGFloat cellContentWidth = kCellDefaultContentWidth;
    if (cell) {
        cellContentWidth = [cell contentWidth];
    }
    cellHeightCalculator.cellContentWidth = cellContentWidth;
}

- (void)mailTableView:(IDPMailTableView *)tableView didDispalyRowAtIndex:(NSInteger)rowIndex {
    if (!self.blockActiveCellUpdatingNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_DID_UPDATE_ACTIVE_PREVIEW_CELL object:self userInfo:@{kIDPNCRowIndex: @(rowIndex)}];
    }
}

@end
