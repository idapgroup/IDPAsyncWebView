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

- (NSTableCellView *)firstVisibleViewCell {
    NSRange range = [self rangeOfVisibleRows];
    if (range.length == 0) {
        return nil;
    }
    NSTableCellView *cell = [self viewAtColumn:0 row:range.location makeIfNecessary:NO];
    return cell;
}

#pragma mark -
#pragma mark Private methods

- (NSRange)rangeOfVisibleRows {
    NSScrollView *scrollView = [self enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    NSRange range = [self rowsInRect:visibleRect];
    return range;
}

@end
