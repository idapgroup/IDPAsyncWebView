//
//  IDPScrollView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPScrollView.h"

@interface IDPScrollView ()

@property (nonatomic, strong) NSTimer   *scrollWheelTimer;
@property (nonatomic, strong) NSTimer   *keyTimer;

@end

@implementation IDPScrollView

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    self.scrollWheelTimer = nil;
    self.keyTimer = nil;
}

#pragma mark -
#pragma mark Accessor methods

- (void)setScrollWheelTimer:(NSTimer *)scrollWheelTimer {
    if (_scrollWheelTimer == scrollWheelTimer) {
        return;
    }
    [_scrollWheelTimer invalidate];
    _scrollWheelTimer = scrollWheelTimer;
}

- (void)setKeyTimer:(NSTimer *)keyTimer {
    if (_keyTimer == keyTimer) {
        return;
    }
    [_keyTimer invalidate];
    _keyTimer = keyTimer;
}

#pragma mark -
#pragma mark Public methods

- (void)scrollWheel:(NSEvent *)theEvent {
    [[NSNotificationCenter defaultCenter] postNotificationName:IDPNOTIFICATION_CENTER_WILL_SCROLL_WHEEL object:self];
    [super scrollWheel:theEvent];
    [[NSNotificationCenter defaultCenter] postNotificationName:IDPNOTIFICATION_CENTER_DID_SCROLL_WHEEL object:self];
}

@end
