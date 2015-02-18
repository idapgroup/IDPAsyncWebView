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

@interface IDPMailPreviewViewController ()

@property (nonatomic, strong) IDPMailPreviewView    *myView;

@end

@implementation IDPMailPreviewViewController

- (void)dealloc {
    
}

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)awakeFromNib {
    [super awakeFromNib];
    NSString *identifier = NSStringFromClass([IDPMailPreviewTableCell class]);
    [self.myView.tableView registerNib:[[NSNib alloc] initWithNibNamed:identifier bundle:nil] forIdentifier:identifier];
    
}

#pragma mark -
#pragma mark Accessor methods

IDPViewControllerViewOfClassGetterSynthesize(IDPMailPreviewView, myView)

#pragma mark -
#pragma mark Private methods

- (void)subscribeOnNitifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTableViewCell:) name:NSTableViewSelectionDidChangeNotification object:self.myView.tableView];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTableViewSelectionDidChangeNotification object:self.myView.tableView];
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
        
    }
}

@end
