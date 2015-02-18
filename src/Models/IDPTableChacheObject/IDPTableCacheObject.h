//
//  IDPTableCacheObject.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDPTableCacheObject : NSObject

@property (nonatomic, strong) id                        model;
@property (atomic, assign) CGFloat                      cellHeight;
@property (atomic, assign) CGFloat                      diffCellheight;
/**
 By default set to YES.
 */
@property (atomic, assign, getter = isDirty) BOOL    dirty;

@end
