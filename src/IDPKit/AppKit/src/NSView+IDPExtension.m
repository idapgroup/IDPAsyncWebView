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

- (void)round {
    self.layer.cornerRadius = MIN(NSWidth(self.frame) / 2, NSHeight(self.frame) / 2);
}

@end
