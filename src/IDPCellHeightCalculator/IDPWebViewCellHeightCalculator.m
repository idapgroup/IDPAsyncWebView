//
//  IDPWebViewCellHeightCalculator.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/11/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPWebViewCellHeightCalculator.h"
#import <WebKit/WebKit.h>
#import "IDPMailMessageModel.h"
#import "IDPTableCacheObject.h"

static CGFloat const kDefaultHeight = 50;
static CGFloat const kDefaultWidth = 50;

@interface IDPWebViewCellHeightCalculator ()

@property (nonatomic, strong) WebView   *webView;

@end

@implementation IDPWebViewCellHeightCalculator

#pragma mark -
#pragma mark Initializations and Deallocations

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, kDefaultWidth, kDefaultHeight)];
        self.webView.frameLoadDelegate = self;
    }
    return self;
}

#pragma mark -
#pragma mark Accessor methods

- (void)setCellContentWidth:(CGFloat)cellContentWidth {
    _cellContentWidth = cellContentWidth;
    NSRect frame = self.webView.frame;
    frame.size.width = _cellContentWidth;
    self.webView.frame = frame;
}

- (void)setCellContentHeight:(CGFloat)cellContentHeight {
    _cellContentHeight = cellContentHeight;
    NSRect frame = self.webView.frame;
    frame.size.height = _cellContentHeight;
    self.webView.frame = frame;
}

#pragma mark -
#pragma mark Public methods

- (void)calculateCellHeighForObject:(IDPTableCacheObject *)object
                           callback:(IDPCellHeightCalculatorCallback)callback {
    [super calculateCellHeighForObject:object callback:callback];
    [self makeRequest];
}

- (void)calculateCellHeighSyncForObject:(IDPTableCacheObject *)object
                               callback:(IDPCellHeightCalculatorCallback)callback {
    [super calculateCellHeighSyncForObject:object callback:callback];
    [self makeRequest];
}

#pragma mark -
#pragma mark Private methods

- (void)makeRequest {
    IDPMailMessageModel *mailObject = self.object.model;
    [[self.webView mainFrame] loadHTMLString:mailObject.content baseURL:nil];
}

#pragma mark -
#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    if(self.isSyncCalculating && [frame isEqual:[self.webView mainFrame]]) {
        NSRect rect = [[[frame frameView] documentView] frame];
        CGFloat height = NSHeight(rect);
        height += self.cellHeight;
        if (self.callback) {
            self.callback(self,height);
        }
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame {
    if(!self.isSyncCalculating && [webFrame isEqual:[self.webView mainFrame]]) {
        NSRect frame = [[[[sender mainFrame] frameView] documentView] frame];
        CGFloat height = NSHeight(frame);
        height += self.cellHeight;
        if (self.callback) {
            self.callback(self,height);
        }
    }
}

@end
