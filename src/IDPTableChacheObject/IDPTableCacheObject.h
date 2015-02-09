//
//  IDPTableCacheObject.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDPTableCacheObjectProtocol.h"

@interface IDPTableCacheObject : NSObject

@property (nonatomic, strong) id<IDPTableCacheObjectProtocol> object;
@property (nonatomic, assign) CGFloat   cellHeight;

@end
