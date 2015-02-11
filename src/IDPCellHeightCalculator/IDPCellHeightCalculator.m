//
//  IDPCellHeightCalculator.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPCellHeightCalculator.h"

static CGFloat const kTestHeight = 200;

@interface IDPCellHeightCalculator ()

@end

@implementation IDPCellHeightCalculator

#pragma mark -
#pragma mark Public methods

- (void)calculateCellHeightWithCallback:(IDPCellHeightCalculatorCallback)callback {
    callback(self, kTestHeight);
}

@end
