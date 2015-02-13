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

static NSTimeInterval const kIDPTimerTime = 1;

@interface IDPMailViewCell ()

@property (nonatomic, strong) NSTimer *markAsReadTimer;

@property (nonatomic, strong) IDPMailMessageModel   *model;

@end

@implementation IDPMailViewCell

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    self.markAsReadTimer = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundViewColor = [NSColor whiteColor];
    self.separatorView.backgroundViewColor = [NSColor blackColor];
}

#pragma mark -
#pragma mark Accessor methods

- (void)setMarkAsReadTimer:(NSTimer *)markAsReadTimer {
    if (_markAsReadTimer == markAsReadTimer) {
        return;
    }
    [_markAsReadTimer invalidate];
    _markAsReadTimer = markAsReadTimer;
}

#pragma mark -
#pragma mark Public methods

- (void)prepareForReuse {
    [super prepareForReuse];
    self.model = nil;
    self.markAsReadTimer = nil;
}

- (void)fillFromObject:(id)object {
    if ([object isKindOfClass:[IDPMailMessageModel class]]) {
        IDPMailMessageModel *mailMessage = (IDPMailMessageModel *)object;
        self.model = mailMessage;
        self.senderTextField.stringValue = [mailMessage senderString];
        self.recipientsTextField.stringValue = [mailMessage recipientsString];
        self.subjectTextField.stringValue = [mailMessage subject];
        self.dateTextField.stringValue = mailMessage.formattedDate;
        [[self.content mainFrame] loadHTMLString:mailMessage.content baseURL:nil];
        
        self.readMark.backgroundViewColor = mailMessage.isRead ? [NSColor clearColor] : [NSColor blueColor];
        self.readMark.cornerRadius = CGRectGetWidth(self.readMark.frame)/2;
        if (!mailMessage.isRead) {
            [self setupMarkTimer];
        }
    }
}

#pragma mark -
#pragma mark Private methods 

- (void)setupMarkTimer {
    self.markAsReadTimer = [NSTimer scheduledTimerWithTimeInterval:kIDPTimerTime target:self selector:@selector(markAsRead) userInfo:nil repeats:NO];
}

- (void)markAsRead {
    self.markAsReadTimer = nil;
    self.model.read = YES;
    self.readMark.backgroundViewColor = self.model.isRead ? [NSColor clearColor] : [NSColor blueColor];
}

#pragma mark -
#pragma mark IDPMailCellProtocol

- (CGFloat)contentWidth {
    return NSWidth(self.content.frame);
}

@end
