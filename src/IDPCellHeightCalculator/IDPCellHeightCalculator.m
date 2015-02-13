//
//  IDPCellHeightCalculator.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPCellHeightCalculator.h"

@interface IDPCellHeightCalculator ()

@end

@implementation IDPCellHeightCalculator

#pragma mark -
#pragma mark Public methods

- (void)calculateCellHeighForObject:(IDPTableCacheObject *)object
                           callback:(IDPCellHeightCalculatorCallback)callback {
    self.syncCalculating = NO;
    self.object = object;
    self.callback = callback;
}

- (void)calculateCellHeighSyncForObject:(IDPTableCacheObject *)object
                               callback:(IDPCellHeightCalculatorCallback)callback {
    self.syncCalculating = YES;
    self.object = object;
    self.callback = callback;
}

- (void)cancel {
    self.object = nil;
    self.callback = nil;
}

@end
