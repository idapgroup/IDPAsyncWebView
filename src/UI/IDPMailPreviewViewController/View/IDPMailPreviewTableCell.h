//
//  IDPMailPreviewTableCell.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/18/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPBaseTableCell.h"
#import <WebKit/WebKit.h>

@class IDPMailMessageModel;

@interface IDPMailPreviewTableCell : IDPBaseTableCell

@property (nonatomic, strong) IBOutlet NSTextField  *senderTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *dateTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *subjectTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *content;
@property (nonatomic, strong) IBOutlet NSView       *containerView;
@property (nonatomic, strong) IBOutlet NSImageView  *avatarImageView;

@property (nonatomic, strong, readonly) IDPMailMessageModel   *model;

@end
