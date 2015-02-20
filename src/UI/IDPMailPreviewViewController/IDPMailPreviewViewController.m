//
//  IDPMailPreviewViewController.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/17/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailPreviewViewController.h"
#import "IDPMailPreviewTableCell.h"
#import "NSViewController+IDPExtension.h"
#import "IDPMailPreviewView.h"
#import "NSNib+IDPExtension.h"
#import "IDPMailMessageModel.h"
#import "IDPConstants.h"
#import "IDPMailHistoryChainModel.h"
#import "IDPTableRowView.h"
#import "NSTableView+IDPExtension.h"
#import "NSView+IDPExtension.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kIDPAnimationDuration = 1;

@interface IDPMailPreviewViewController ()

@property (nonatomic, strong) IDPMailPreviewView    *myView;
@property (nonatomic, assign) BOOL disableRowSelectionNotification;
@property (nonatomic, assign) NSInteger selectedRowIndex;

@end

@implementation IDPMailPreviewViewController

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)awakeFromNib {
    [super awakeFromNib];
    self.myView.wantsLayer = YES;
    self.myView.backgroundViewColor = [NSColor whiteColor];
    self.myView.scrollView.drawsBackground = NO;
    self.myView.scrollView.backgroundColor = [NSColor clearColor];
    self.myView.tableView.backgroundColor = [NSColor clearColor];
    NSString *identifier = NSStringFromClass([IDPMailPreviewTableCell class]);
    [self.myView.tableView registerNib:[[NSNib alloc] initWithNibNamed:identifier bundle:nil] forIdentifier:identifier];
    [self subscribeOnNitifications];
}

#pragma mark -
#pragma mark Accessor methods

- (IDPMailPreviewView *)myView {
    if ([self.view isKindOfClass:[IDPMailPreviewView class]]) {
        return (IDPMailPreviewView *)self.view;
    }
    return nil;
}


#pragma mark -
#pragma mark Private methods

- (void)subscribeOnNitifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedNewMail:) name:NOTIFICATION_CENTER_DID_SELECTED_MAIL_CHAIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectedCellAccordingToScrolling:) name:NOTIFICATION_CENTER_DID_UPDATE_ACTIVE_PREVIEW_CELL object:nil];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CENTER_DID_SELECTED_MAIL_CHAIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CENTER_DID_UPDATE_ACTIVE_PREVIEW_CELL object:nil];
}

- (void)didSelectedNewMail:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:kIDPNCRowIndex] integerValue];
    IDPMailHistoryChainModel *model = [userInfo objectForKey:kIDPNCObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_WILL_UPDATE_MAIL_DETAILS object:self userInfo:@{kIDPNCObject:model, kIDPNCRowIndex:@(index)}];
    
    NSImage *image = [self.myView imageFromView];
    self.myView.imageView.image = image;
    
    NSRect frame = self.myView.scrollView.frame;
    NSRect startFrame = frame;
    
    startFrame.origin.y = index < self.selectedRowIndex ? NSHeight(self.myView.frame) : -NSHeight(self.myView.frame);
    
    
    self.dataSourceObjects = model.mailMessages;
    self.disableRowSelectionNotification = NO;
    [self reloadData];
    
    [self.myView.tableView scrollRowToVisible:0];
    [self.myView.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    CATransform3D transfrom = self.myView.scrollView.layer.transform;
    CATransform3D translateStart = CATransform3DMakeTranslation(0, startFrame.origin.y, 0);
    translateStart = CATransform3DConcat(transfrom, translateStart);

    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation1.duration = kIDPAnimationDuration;
    animation1.fromValue = [NSValue valueWithCATransform3D:translateStart];
    animation1.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation1.removedOnCompletion = YES;
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.duration = kIDPAnimationDuration;
    animation2.fromValue = @(0);
    animation2.toValue = @(1);
    animation2.removedOnCompletion = YES;
    
    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation3.duration = kIDPAnimationDuration;
    animation3.fromValue = @(1);
    animation3.toValue = @(0);
    animation3.removedOnCompletion = YES;
    
    self.myView.imageView.hidden = NO;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.myView.imageView.hidden = YES;
    }];
    [self.myView.scrollView.layer addAnimation:animation1 forKey:@"animation1"];
    [self.myView.scrollView.layer addAnimation:animation2 forKey:@"animation2"];
    [self.myView.imageView.layer addAnimation:animation3 forKey:@"animation3"];
    [CATransaction commit];

    self.selectedRowIndex = index;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_DID_UPDATE_MAIL_DETAILS object:self userInfo:@{kIDPNCObject:model, kIDPNCRowIndex:@(index)}];
}

- (void)reloadData {
    [self.myView.tableView reloadData];
}

- (void)updateSelectedCellAccordingToScrolling:(NSNotification *)notification {
    NSInteger row = [[notification.userInfo objectForKey:kIDPNCRowIndex] integerValue];
    self.disableRowSelectionNotification = YES;
    [self.myView.tableView scrollToRow:row atScrollPosition:IDPTableViewScrollPositionMiddle];
    [self.myView.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    self.disableRowSelectionNotification = NO;
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSourceObjects.count;
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = NSStringFromClass([IDPMailPreviewTableCell class]);
    IDPMailPreviewTableCell *cell = [tableView makeViewWithIdentifier:identifier owner:nil];
    if (!cell) {
        cell = [NSNib objectOfClass:NSClassFromString(identifier)];
    }
    [cell fillFromObject:[self.dataSourceObjects objectAtIndex:row]];
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.myView.tableView && self.disableRowSelectionNotification == NO) {
        NSInteger index = self.myView.tableView.selectedRow;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_DID_SELECTED_MAIL object:self userInfo:@{kIDPNCRowIndex:@(index)}];
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    static NSString* const kRowIdentifier = @"IDPTableRowView";
    IDPTableRowView* rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:nil];
    if (!rowView) {
        rowView = [IDPTableRowView new];
        rowView.identifier = kRowIdentifier;
    }
    
    return rowView;
}

@end
