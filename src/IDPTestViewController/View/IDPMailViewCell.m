//
//  IDPMailViewCell.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailViewCell.h"
#import "IDPMailMessageModel.h"
#import "NSView+IDPExtension.h"

@implementation IDPMailViewCell

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundColor = [NSColor whiteColor];
    self.separatorView.backgroundColor = [NSColor blackColor];
}

#pragma mark -
#pragma mark Public methods

- (void)fillFromObject:(id)object {
    if ([object isKindOfClass:[IDPMailMessageModel class]]) {
        IDPMailMessageModel *mailMessage = (IDPMailMessageModel *)object;
        self.senderTextField.stringValue = [mailMessage senderString];
        self.recipientsTextField.stringValue = [mailMessage recipientsString];
        self.subjectTextField.stringValue = [mailMessage subject];
        self.dateTextField.stringValue = mailMessage.formattedDate;
        [[self.content mainFrame] loadHTMLString:mailMessage.content baseURL:nil];
        
        self.readMark.backgroundColor = mailMessage.isRead ? [NSColor greenColor] : [NSColor blueColor];
        self.readMark.cornerRadius = CGRectGetWidth(self.readMark.frame)/2;
    }
}

@end
