//
//  IDPMailViewCell.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPBaseTableCell.h"

@interface IDPMailViewCell : IDPBaseTableCell

@property (nonatomic, strong) IBOutlet NSTextField  *senderTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *subjectTextField;
@property (nonatomic, strong) IBOutlet NSView       *readMark;

@end
