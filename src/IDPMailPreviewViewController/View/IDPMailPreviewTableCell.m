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
    self.separatorView.backgroundViewColor = [NSColor blackColor];
    
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
        self.model = mailMessage;
        self.senderTextField.stringValue = [mailMessage senderString];
        self.recipientsTextField.stringValue = [mailMessage recipientsString];
        self.subjectTextField.stringValue = [mailMessage subject];
        self.dateTextField.stringValue = mailMessage.formattedDate;
        
        [[self.content mainFrame] loadHTMLString:mailMessage.previewContent baseURL:nil];
    }
}

@end
