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
@property (nonatomic, strong) IBOutlet WebView      *content;
@property (nonatomic, strong) IBOutlet NSView       *readMark;

@end
