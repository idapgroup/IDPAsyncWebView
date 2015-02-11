//
//  IDPScrollView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPScrollView.h"

@implementation IDPScrollView

#pragma mark -
#pragma mark Public methods

- (void)scrollWheel:(NSEvent *)theEvent {
    CGFloat deltaY = fabs(theEvent.deltaY);
    NSLog(@"%f", deltaY);
    [[NSNotificationCenter defaultCenter] postNotificationName:IDPNOTIFICATION_CENTER_WILL_SCROLL_WHEEL object:self];
    [super scrollWheel:theEvent];
    [[NSNotificationCenter defaultCenter] postNotificationName:IDPNOTIFICATION_CENTER_DID_SCROLL_WHEEL object:self];
}

@end
