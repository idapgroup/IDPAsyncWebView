//
//  IDPMailTableView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailTableView.h"
#import "IDPTableCacheObject.h"

static NSString *const kOperationQueueName = @"IDPTableViewCellHeightQueue";

static CGFloat kTestHeight = 200;

@interface IDPMailTableView ()

@property (nonatomic, strong) NSOperationQueue  *operationQueue;

@end

@implementation IDPMailTableView

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.operationQueue = [NSOperationQueue new];
    self.operationQueue.name = kOperationQueueName;
    self.operationQueue.maxConcurrentOperationCount = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScrolling) name:NSScrollViewWillStartLiveScrollNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endScrolling) name:NSScrollViewDidEndLiveScrollNotification object:nil];
}

#pragma mark -
#pragma mark Private methods

- (void)startScrolling {
    self.operationQueue.suspended = YES;
}

- (void)endScrolling {
    self.operationQueue.suspended = NO;
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSourceObjects.count;
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [self.delegate tableView:tableView viewForTableColumn:tableColumn row:row];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    __block IDPTableCacheObject *object = [self.dataSourceObjects objectAtIndex:row];
    CGFloat height = object.cellHeight;
    if (object.isDirty) {
        [self.operationQueue addOperationWithBlock:^{
            CGFloat prevValue = object.cellHeight;
            CGFloat dif = object.cellHeight - prevValue;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                object.dirty = NO;
                object.cellHeight = kTestHeight;
                [NSAnimationContext beginGrouping];
                [[NSAnimationContext currentContext] setDuration:0.0];
                NSScrollView *scrollView = [tableView enclosingScrollView];
                CGRect visibleRect = scrollView.contentView.visibleRect;
                NSRange range = [tableView rowsInRect:visibleRect];
                NSInteger visibleRow = range.location;
                if (visibleRow > row) {
                    NSPoint origin = [scrollView documentVisibleRect].origin;
                    origin.y += dif;
                    [[scrollView documentView] scrollPoint:origin];
                }
                [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
                [NSAnimationContext endGrouping];
            }];
        }];
    }
    return height;
}

@end
