//
//  NSView+IDPExtension.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "NSView+IDPExtension.h"
#import <objc/runtime.h>

static char __backgroundViewColor;

@implementation NSView (IDPExtension)

#pragma mark -
#pragma mark Accessor methods

- (void)setBackgroundViewColor:(NSColor *)backgroundColor {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [backgroundColor CGColor];
    objc_setAssociatedObject(self, &__backgroundViewColor, backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSColor *)backgroundViewColor {
    NSColor *color = ((NSColor *)objc_getAssociatedObject(self, &__backgroundViewColor));
    return color;
}

#pragma mark -
#pragma mark Public methods

- (void)round {
    [self roundWithValue:MIN(NSWidth(self.frame) / 2, NSHeight(self.frame) / 2)];
}

- (void)roundWithValue:(CGFloat)value {
    self.wantsLayer = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = value;
}

- (void)borderWidthValue:(CGFloat)value {
    self.wantsLayer = YES;
    self.layer.borderWidth = value;
}

- (void)borderViewColor:(NSColor *)color {
    self.wantsLayer = YES;
    self.layer.borderColor = [color CGColor];
}

@end
