//
//  IDPMailMessageModel.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDPMailMessageModel : NSObject

@property (nonatomic, strong) NSArray   *sender;
@property (nonatomic, strong) NSArray   *recipients;
@property (nonatomic, copy)   NSString  *subject;
@property (nonatomic, assign, getter = isRead) BOOL read;
@property (nonatomic, strong) NSDate    *date;
@property (nonatomic, copy)   NSString  *content;

- (NSString *)senderString;
- (NSString *)recipientsString;

@end
