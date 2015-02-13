//
//  NSView+IDPExtension.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "NSView+IDPExtension.h"
#import <objc/runtime.h>

static char __backgroundColor;

@implementation NSView (IDPExtension)

#pragma mark -
#pragma mark Accessor methods

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [backgroundColor CGColor];
    objc_setAssociatedObject(self, &__backgroundColor, backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSColor *)backgroundColor {
    NSColor *color = ((NSColor *)objc_getAssociatedObject(self, &__backgroundColor));
    return color;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

@end
