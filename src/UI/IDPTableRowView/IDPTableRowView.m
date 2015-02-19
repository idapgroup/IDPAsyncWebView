//
//  IDPTableRowView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/19/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPTableRowView.h"

@implementation IDPTableRowView

#pragma mark -
#pragma mark Initializations and Deallocations

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectionColor = [NSColor alternateSelectedControlColor];
    }
    return self;
}



#pragma mark -
#pragma mark Public methods

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = NSInsetRect(self.bounds, 0.5, 0.5);
        [self.selectionColor setStroke];
        [self.selectionColor setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:6 yRadius:6];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end
