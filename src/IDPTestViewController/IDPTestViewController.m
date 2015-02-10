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
#import "IDPTableCacheObject.h"

static NSInteger const kRows = 1000;
static CGFloat   const kCellDefaultHeight = 50;

@interface IDPTestViewController ()

@property (nonatomic, strong, readonly) IDPTestView *myView;

@property (nonatomic, strong) NSMutableArray    *objects;


@end

@implementation IDPTestViewController

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)awakeFromNib {
    [super awakeFromNib];
    NSString *identifier = NSStringFromClass([IDPMailViewCell class]);
    self.objects = [NSMutableArray array];
    [self.myView.mailTableView.tableView registerNib:[[NSNib alloc] initWithNibNamed:identifier bundle:nil] forIdentifier:identifier];
    for (NSInteger index = 0; index < kRows; index++) {
        IDPTableCacheObject *object = [IDPTableCacheObject new];
        object.cellHeight = kCellDefaultHeight;
        [self.objects addObject:object];
    }
    self.myView.mailTableView.dataSourceObjects = self.objects;
}

#pragma mark -
#pragma mark Accessor methods

- (IDPTestView *)myView {
    if ([self.view isKindOfClass:[IDPTestView class]]) {
        return (IDPTestView *)self.view;
    }
    return nil;
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
    
#warning TEMP
    cell.textField.stringValue = [NSString stringWithFormat:@"Text %ld", (long)row];
    
    return cell;
}

@end
