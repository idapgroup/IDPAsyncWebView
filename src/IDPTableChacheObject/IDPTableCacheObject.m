//
//  IDPTableCacheObject.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPTableCacheObject.h"

@implementation IDPTableCacheObject

#pragma mark -
#pragma mark Initializations and Deallocations

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dirty = YES;
    }
    return self;
}

@end
