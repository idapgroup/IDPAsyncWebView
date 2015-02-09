//
//  IDPTestViewController.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPTestViewController.h"
#import "IDPTestView.h"
#import "IDPMailViewCell.h"
#import "NSNib+IDPExtension.h"

@interface IDPTestViewController ()

@end

@implementation IDPTestViewController

#pragma mark
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 2000;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = NSStringFromClass([IDPMailViewCell class]);
    IDPMailViewCell *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    if (!cell) {
        cell = [NSNib objectOfClass:NSClassFromString(identifier)];
    }
    cell.textField.stringValue = @"Text";
    return cell;
}

#pragma mark -
#pragma mark NSTableViewDelegate

@end
