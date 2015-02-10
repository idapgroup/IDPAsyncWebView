//
//  IDPMailListTableCellView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailListTableCellView.h"
#import "IDPMailHistoryChainModel.h"

@implementation IDPMailListTableCellView

#pragma mark -
#pragma mark Public methods

- (void)fillFromObject:(id)object {
    if ([object isKindOfClass:[IDPMailHistoryChainModel class]]) {
        IDPMailHistoryChainModel *model = (IDPMailHistoryChainModel *)object;
        IDPMailMessageModel *mailMessage = [model firstUnreadMail];
        self.fromTextField.stringValue = [mailMessage senderString];
        self.subjectTextField.stringValue = mailMessage.subject;
    }
}

@end
