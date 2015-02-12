//
//  NSTableView+IDPExtension.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTableView (IDPExtension)

- (NSArray *)visibleRows;
- (NSTableCellView *)firstVisibleViewCell;

@end
