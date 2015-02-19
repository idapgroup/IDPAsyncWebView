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

@interface IDPMailPreviewViewController ()

@property (nonatomic, strong) IDPMailPreviewView    *myView;
@property (nonatomic, assign) BOOL disableRowSelectionNotification;

@end

@implementation IDPMailPreviewViewController

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)awakeFromNib {
    [super awakeFromNib];
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
    IDPMailHistoryChainModel *model = notification.object;
    self.dataSourceObjects = model.mailMessages;
    self.disableRowSelectionNotification = NO;
    [self reloadData];
    [self.myView.tableView scrollRowToVisible:0];
    [self.myView.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)reloadData {
    [self.myView.tableView reloadData];
}

- (void)updateSelectedCellAccordingToScrolling:(NSNotification *)notification {
    NSInteger row = [notification.object integerValue];
    self.disableRowSelectionNotification = YES;
    [self.myView.tableView scrollRowToVisible:row];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_DID_SELECTED_MAIL object:@(index)];
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [IDPTableRowView new];
}

@end
