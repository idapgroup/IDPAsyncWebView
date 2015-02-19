//
//  IDPMailPreviewTableCell.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/18/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailPreviewTableCell.h"
#import "IDPMailMessageModel.h"
#import "NSView+IDPExtension.h"
#import "IDPMailMessageModel.h"

@interface IDPMailPreviewTableCell ()

@property (nonatomic, strong) IDPMailMessageModel   *model;

@end

@implementation IDPMailPreviewTableCell

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundViewColor = [NSColor whiteColor];
}

#pragma mark -
#pragma mark Public methods

- (void)prepareForReuse {
    [super prepareForReuse];
    self.model = nil;
}

- (void)fillFromObject:(id)object {
    if ([object isKindOfClass:[IDPMailMessageModel class]]) {
        IDPMailMessageModel *mailMessage = (IDPMailMessageModel *)object;
        self.containerView.backgroundViewColor = mailMessage.previewBackgroundColor;
        self.model = mailMessage;
        self.senderTextField.stringValue = [mailMessage senderString];
        self.subjectTextField.stringValue = [mailMessage subject];
        self.dateTextField.stringValue = [mailMessage shortFromattedDate];
        self.content.stringValue = mailMessage.previewContent;
        self.avatarImageView.image = [NSImage imageNamed:mailMessage.senderAvater];
        self.avatarImageView.backgroundViewColor = [NSColor whiteColor];
        [self.avatarImageView round];
        
        self.senderTextField.textColor = mailMessage.previewTextColor;
        self.subjectTextField.textColor = mailMessage.previewTextColor;
        self.dateTextField.textColor = mailMessage.previewTextColor;
        self.content.textColor = mailMessage.previewTextColor;
        
    }
}

@end
