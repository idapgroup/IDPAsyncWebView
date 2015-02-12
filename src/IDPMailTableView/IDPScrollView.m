//
//  IDPScrollView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPScrollView.h"

static NSTimeInterval const kIDPScrollWheelTime = 0.5;

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
    if (!self.scrollWheelTimer) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IDPNOTIFICATION_CENTER_START_SCROLL_WHEEL object:self];
    }
    [self setupScrollWheelTimer];
    [super scrollWheel:theEvent];
}

#pragma mark -
#pragma mark Private methods

- (void)setupScrollWheelTimer {
    self.scrollWheelTimer = [NSTimer scheduledTimerWithTimeInterval:kIDPScrollWheelTime target:self selector:@selector(scrollWheelDidStopScrolling:) userInfo:nil repeats:NO];
}

- (void)scrollWheelDidStopScrolling:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:IDPNOTIFICATION_CENTER_END_SCROLL_WHEEL object:self];
    self.scrollWheelTimer = nil;
}

@end
