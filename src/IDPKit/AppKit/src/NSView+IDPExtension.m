//
//  NSView+IDPExtension.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "NSView+IDPExtension.h"

@implementation NSView (IDPExtension)

#pragma mark -
#pragma mark Accessor methods

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [backgroundColor CGColor];
}

- (NSColor *)backgroundColor {
    return [NSColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

@end
