//
//  NSTableView+IDPExtension.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "NSTableView+IDPExtension.h"

@implementation NSTableView (IDPExtension)

#pragma mark -
#pragma mark Public methods

- (NSArray *)visibleRows {
    NSRange range = [self rangeOfVisibleRows];
    NSMutableArray *visibleRows = [NSMutableArray array];
    NSInteger endIndex = range.location + range.length;
    
    for (NSInteger index = range.location; index < endIndex; index++) {
        [visibleRows addObject:@(index)];
    }
    
    return visibleRows.count > 0 ? [NSArray arrayWithArray:visibleRows] : nil;
}

- (NSArray *)visibleCells {
    NSMutableArray *visibleCells = [NSMutableArray array];
    NSArray *visibleRows = [self visibleRows];
    for (NSNumber *row in [[visibleRows reverseObjectEnumerator] allObjects]) {
        NSTableCellView *cell = [self viewAtColumn:0 row:row.integerValue makeIfNecessary:NO];
        [visibleCells addObject:cell];
    }
    
    return visibleCells.count > 0 ? [NSArray arrayWithArray:visibleCells] :  nil;
}

- (NSTableCellView *)firstVisibleViewCell {
    return [self firstVisibleViewCellMakeIfNecessary:NO];
}

- (NSTableCellView *)firstVisibleViewCellMakeIfNecessary {
    return [self firstVisibleViewCellMakeIfNecessary:YES];
}

#pragma mark -
#pragma mark Private methods

- (NSTableCellView *)firstVisibleViewCellMakeIfNecessary:(BOOL)makeIfNecessary {
    NSRange range = [self rangeOfVisibleRows];
    if (range.length == 0) {
        return nil;
    }
    NSTableCellView *cell = [self viewAtColumn:0 row:range.location makeIfNecessary:makeIfNecessary];
    return cell;
}

- (NSRange)rangeOfVisibleRows {
    NSScrollView *scrollView = [self enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    NSRange range = [self rowsInRect:visibleRect];
    return range;
}

@end
