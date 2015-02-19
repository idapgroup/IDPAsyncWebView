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
#import "NSColor+IDPExtension.h"
#import "IDPKeyPathObserver.h"

@interface IDPMailPreviewTableCell () <IDPKeyPathObserverDelegate>

@property (nonatomic, strong) IDPMailMessageModel   *model;
@property (nonatomic, strong) IDPKeyPathObserver    *keyPathObserver;

@end

@implementation IDPMailPreviewTableCell

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    [self.keyPathObserver stopObserving];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundViewColor = [NSColor whiteColor];
    self.readMarkView.backgroundViewColor = [NSColor colorWithIntRed:0 green:161 blue:244 alpha:255];
    [self.readMarkView round];
    [self roundWithValue:3];
}

#pragma mark -
#pragma mark Public methods

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.keyPathObserver stopObserving];
    self.keyPathObserver = nil;
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
        self.readMarkView.hidden = mailMessage.isRead;
        
        self.senderTextField.textColor = mailMessage.previewTextColor;
        self.subjectTextField.textColor = mailMessage.previewTextColor;
        self.dateTextField.textColor = mailMessage.previewTextColor;
        self.content.textColor = mailMessage.previewTextColor;
        
        self.keyPathObserver = [[IDPKeyPathObserver alloc] initWithObservedObject:mailMessage observerObject:self];
        self.keyPathObserver.observedKeyPathsArray = @[@"read"];
        [self.keyPathObserver startObserving];
    }
}

#pragma mark -
#pragma mark IDPKeyPathObserverDelegate

- (void)keyPathObserver:(IDPKeyPathObserver *)observer
        didCatchChanges:(NSDictionary *)changes
              inKeyPath:(NSString *)keyPath
               ofObject:(id<NSObject>)observedObject {
    if (observedObject == self.model) {
        IDPMailMessageModel *model = (IDPMailMessageModel *)observedObject;
        self.readMarkView.hidden = model.isRead;
    }
}

@end
