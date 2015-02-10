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

static NSInteger const kRows = 1000;
static CGFloat   const kCellDefaultHeight = 50;

@interface IDPMailDetailsViewController ()

@property (nonatomic, strong, readonly) IDPMailTableView *myView;

@property (nonatomic, strong) NSMutableArray    *objects;


@end

@implementation IDPMailDetailsViewController

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)awakeFromNib {
    [super awakeFromNib];
    NSString *identifier = NSStringFromClass([IDPMailViewCell class]);
    self.objects = [NSMutableArray array];
    [self.myView.tableView registerNib:[[NSNib alloc] initWithNibNamed:identifier bundle:nil] forIdentifier:identifier];
    for (NSInteger index = 0; index < kRows; index++) {
        IDPTableCacheObject *object = [IDPTableCacheObject new];
        object.cellHeight = kCellDefaultHeight;
        [self.objects addObject:object];
    }
    self.myView.dataSourceObjects = self.objects;
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
