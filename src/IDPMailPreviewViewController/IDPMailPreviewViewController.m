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

@interface IDPMailPreviewViewController ()

@property (nonatomic, strong) IDPMailPreviewView    *myView;

@end

@implementation IDPMailPreviewViewController

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)awakeFromNib {
    [super awakeFromNib];
    self.myView.tableView.backgroundColor = [NSColor grayColor];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTableViewCell:) name:NSTableViewSelectionDidChangeNotification object:self.myView.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedNewMail:) name:NOTIFICATION_CENTER_DID_SELECTED_MAIL_CHAIN object:nil];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTableViewSelectionDidChangeNotification object:self.myView.tableView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CENTER_DID_SELECTED_MAIL_CHAIN object:nil];
}

- (void)didSelectedNewMail:(NSNotification *)notification {
    IDPMailHistoryChainModel *model = notification.object;
    self.dataSourceObjects = model.mailMessages;
    [self reloadData];
}

- (void)reloadData {
    [self.myView.tableView reloadData];
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

- (void)didSelectTableViewCell:(NSNotification *)notification {
    if (notification.object == self.myView.tableView) {
        NSInteger index = self.myView.tableView.selectedRow;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_DID_SELECTED_MAIL object:@(index)];
    }
}

@end
