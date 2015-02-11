//
//  IDPCellHeightCalculator.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDPCellHeightCalculator;
@class IDPTableCacheObject;

typedef void(^IDPCellHeightCalculatorCallback)(IDPCellHeightCalculator *calculator, CGFloat newHeight);

@interface IDPCellHeightCalculator : NSObject

/**
 Set this property inside IDPCellHeightCalculator or in its inherited objects.
 */
@property (nonatomic, copy) IDPCellHeightCalculatorCallback callback;

@property (nonatomic, strong) IDPTableCacheObject   *object;

@property (nonatomic, assign) CGFloat cellWidth;
/**
 Cell height except cell content height.
 */
@property (nonatomic, assign) CGFloat cellHeight;

/**
 Override this method in inherited object. Call super.
 */
- (void)calculateCellHeighForObject:(IDPTableCacheObject *)object
                           callback:(IDPCellHeightCalculatorCallback)callback;

- (void)cancel;

@end
