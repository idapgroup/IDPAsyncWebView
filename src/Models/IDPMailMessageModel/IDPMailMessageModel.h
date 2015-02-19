//
//  IDPMailMessageModel.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface IDPMailMessageModel : NSObject

@property (nonatomic, strong) NSArray   *sender;
@property (nonatomic, strong) NSArray   *recipients;
@property (nonatomic, copy)   NSString  *subject;
@property (nonatomic, assign, getter = isRead) BOOL read;
@property (nonatomic, strong) NSDate    *date;
@property (nonatomic, copy)   NSString  *content;
@property (nonatomic, strong) NSURL     *urlForContentResources;
@property (nonatomic, copy, readonly)   NSString  *formattedDate;
@property (nonatomic, copy)   NSString  *previewContent;

@property (nonatomic, strong) NSColor   *previewBackgroundColor;
@property (nonatomic, strong) NSColor   *previewTextColor;
@property (nonatomic, copy)   NSString  *senderAvater;

- (NSString *)senderString;
- (NSString *)recipientsString;

- (NSString *)shortFromattedDate;

@end
