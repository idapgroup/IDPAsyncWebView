//
//  IDPMailListViewController.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailListViewController.h"
#import "IDPMailListView.h"
#import "IDPMailListTableCellView.h"
#import "NSNib+IDPExtension.h"
#import "IDPConstants.h"
#import "IDPMailHistoryChainModel.h"

@interface IDPMailListViewController ()

@property (nonatomic, strong, readonly) IDPMailListView *myView;

@end

@implementation IDPMailListViewController

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTableViewSelectionDidChangeNotification object:self.myView.tableView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSString *identifier = NSStringFromClass([IDPMailListTableCellView class]);
    [self.myView.tableView registerNib:[[NSNib alloc] initWithNibNamed:identifier bundle:nil] forIdentifier:identifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewCellDidSelected:) name:NSTableViewSelectionDidChangeNotification object:self.myView.tableView];
}

#pragma mark -
#pragma mark Accessor methods

- (IDPMailListView *)myView {
    if ([self.view isKindOfClass:[IDPMailListView class]]) {
        return (IDPMailListView *)self.view;
    }
    return nil;
}

- (void)setMailObjects:(NSArray *)mailObjects {
    BOOL isChange = _mailObjects != mailObjects;
    _mailObjects = mailObjects;
    if (isChange && _mailObjects != nil) {
        [self reloadData];
        [self.myView.tableView scrollRowToVisible:0];
        [self.myView.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
}

#pragma mark -
#pragma mark Public methods

- (void)reloadData {
    [self.myView.tableView reloadData];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.mailObjects.count;
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = NSStringFromClass([IDPMailListTableCellView class]);
    IDPMailListTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:nil];
    if (!cell) {
        cell = [NSNib objectOfClass:NSClassFromString(identifier)];
    }
    [cell fillFromObject:[self.mailObjects objectAtIndex:row]];
    
    return cell;
}

- (void)tableViewCellDidSelected:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    if (tableView == self.myView.tableView) {
        IDPMailHistoryChainModel *model = [self.mailObjects objectAtIndex:tableView.selectedRow];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_DID_SELECTED_NEW_MAIL object:model];
    }
}

@end
