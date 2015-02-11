//
//  IDPMailViewCell.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPBaseTableCell.h"
#import <WebKit/WebKit.h>

@interface IDPMailViewCell : IDPBaseTableCell

@property (nonatomic, strong) IBOutlet NSTextField  *senderTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *recipientsTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *subjectTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *dateTextField;
@property (nonatomic, strong) IBOutlet WebView      *content;
@property (nonatomic, strong) IBOutlet NSView       *readMark;
@property (nonatomic, strong) IBOutlet NSView       *headerView;
@property (nonatomic, strong) IBOutlet NSView       *contentView;
@property (nonatomic, strong) IBOutlet NSView       *containerView;
@property (nonatomic, strong) IBOutlet NSView       *separatorView;

@end
