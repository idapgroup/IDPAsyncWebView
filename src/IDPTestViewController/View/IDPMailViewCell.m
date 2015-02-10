//
//  IDPMailViewCell.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailViewCell.h"
#import "IDPMailMessageModel.h"

@implementation IDPMailViewCell

#pragma mark -
#pragma mark Public methods

- (void)fillFromObject:(id)object {
    if ([object isKindOfClass:[IDPMailMessageModel class]]) {
        IDPMailMessageModel *mailMessage = (IDPMailMessageModel *)object;
        self.senderTextField.stringValue = [mailMessage senderString];
        self.subjectTextField.stringValue = mailMessage.subject;
    }
}

@end
