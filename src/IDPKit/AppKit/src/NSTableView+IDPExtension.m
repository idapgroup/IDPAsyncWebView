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
    NSScrollView *scrollView = [self enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    NSRange range = [self rowsInRect:visibleRect];
    NSMutableArray *visibleRows = [NSMutableArray array];
    NSInteger endIndex = range.location + range.length;
    
    for (NSInteger index = range.location; index < endIndex; index++) {
        [visibleRows addObject:@(index)];
    }
    
    return visibleRows.count > 0 ? [NSArray arrayWithArray:visibleRows] : nil;
}

@end
