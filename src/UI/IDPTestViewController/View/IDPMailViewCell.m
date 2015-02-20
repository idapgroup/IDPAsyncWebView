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
#import "NSColor+IDPExtension.h"

@interface IDPMailViewCell ()

@property (nonatomic, strong) IDPMailMessageModel   *model;

@end

@implementation IDPMailViewCell

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundViewColor = [NSColor whiteColor];
    [self.containerView roundWithValue:5];
    [self.containerView borderWidthValue:2.5];
    [self.containerView borderViewColor:[NSColor colorWithIntRed:247 green:247 blue:247 alpha:255]];
    [self.avatarImageView borderWidthValue:1];
    [self.avatarImageView borderViewColor:[NSColor grayColor]];
}

#pragma mark -
#pragma mark Interface Handling

- (IBAction)onMarkAsRead:(id)sender {
    self.model.read = YES;
    self.readMark.hidden = self.model.isRead;
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
        self.dateTextField.stringValue = [mailMessage shortFromattedDate];
        self.content.policyDelegate = self;
        self.avatarImageView.image = [NSImage imageNamed:mailMessage.senderAvater];
        [self.avatarImageView round];
        
        [[self.content mainFrame] loadHTMLString:mailMessage.content baseURL:mailMessage.urlForContentResources];
        
        self.readMark.hidden = mailMessage.isRead;
    }
}

#pragma mark -
#pragma mark IDPMailCellProtocol

- (CGFloat)contentWidth {
    return NSWidth(self.content.frame);
}

#pragma mark -
#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)webView
    decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame
    decisionListener:(id < WebPolicyDecisionListener >)listener
{
    NSString *host = [[request URL] host];
    if (host) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    } else {
        [listener use];
    }
}

@end
