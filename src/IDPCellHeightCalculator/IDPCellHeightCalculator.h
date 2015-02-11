//
//  IDPCellHeightCalculator.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDPCellHeightCalculator;

typedef void(^IDPCellHeightCalculatorCallback)(IDPCellHeightCalculator *calculator, CGFloat newHeight);

@interface IDPCellHeightCalculator : NSObject

/**
 Set this property inside IDPCellHeightCalculator or in its inherited objects.
 */
@property (nonatomic, copy) IDPCellHeightCalculatorCallback callback;

/**
 Override this method in inherited object.
 Warning this method call in background thread.
 */
- (void)calculateCellHeightWithCallback:(IDPCellHeightCalculatorCallback)callback;

@end
