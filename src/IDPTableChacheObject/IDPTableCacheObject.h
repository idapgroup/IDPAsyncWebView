//
//  IDPTableCacheObject.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDPCellHeightCalculator.h"

@interface IDPTableCacheObject : NSObject

@property (nonatomic, strong) id                        model;
@property (nonatomic, strong) IDPCellHeightCalculator   *cellHeightCalculator;
@property (nonatomic, assign) CGFloat                   cellHeight;
/**
 By default set to YES.
 */
@property (nonatomic, assign, getter = isDirty) BOOL    dirty;

@end
