//
//  IDPMailTableView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailTableView.h"
#import "IDPTableCacheObject.h"

static CGFloat kTestHeight = 200;

@interface IDPMailTableView ()

@property (nonatomic, strong) IDPTableCacheObject *loadedObject;
@property (atomic, strong) NSMutableArray         *objectInQueusToLoad;

@property (atomic, assign, getter = isPausedObjectHeightLoading) BOOL pausedObjectHeightLoading;

@property (nonatomic, strong) NSMutableArray    *pausedObjectHeightLoadingArray;

@end

@implementation IDPMailTableView

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    [self removeNotificationObservers];
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    [self addNotificationObsevers];
    self.pausedObjectHeightLoadingArray = [NSMutableArray array];
    self.objectInQueusToLoad = [NSMutableArray array];
}

#pragma mark -
#pragma mark Accessor methods

- (void)setDataSourceObjects:(NSArray *)dataSourceObjects {
    _dataSourceObjects = dataSourceObjects;
    self.objectInQueusToLoad = [NSMutableArray arrayWithArray:_dataSourceObjects];
}

#pragma mark -
#pragma mark Private methods

- (void)startScrolling:(NSNotification *)notification {
    id object = notification.object;
    if (object == self.scrollView) {
        self.pausedObjectHeightLoading = YES;
    }
}

- (void)endScrolling:(NSNotification *)notification {
    id object = notification.object;
    if (object == self.scrollView) {
        self.pausedObjectHeightLoading = NO;
        for (NSNumber *row in self.pausedObjectHeightLoadingArray) {
            CGFloat dif = 150;
            NSScrollView *scrollView = [self.tableView enclosingScrollView];
            CGRect visibleRect = scrollView.contentView.visibleRect;
            NSRange range = [self.tableView rowsInRect:visibleRect];
            NSInteger visibleRow = range.location;
            NSPoint origin = [scrollView documentVisibleRect].origin;
            
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0.0];
            [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:[row integerValue]]];
            if (visibleRow > row.integerValue) {
                origin.y += dif;
                [[scrollView documentView] scrollPoint:origin];
            }
            [NSAnimationContext endGrouping];
        }
        [self.pausedObjectHeightLoadingArray removeAllObjects];
        [self loadHeightOfNextObjectInQueue];
    }
}

- (void)addNotificationObsevers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScrolling:) name:NSScrollViewWillStartLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endScrolling:) name:NSScrollViewDidEndLiveScrollNotification object:self.scrollView];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewWillStartLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewDidEndLiveScrollNotification object:self.scrollView];
}

- (void)loadHeightOfNextObjectInQueue {
    self.loadedObject = [self.objectInQueusToLoad firstObject];
    if (self.loadedObject) {
        IDPTableCacheObject *object = self.loadedObject;
        [self.objectInQueusToLoad removeObjectAtIndex:0];
        __weak IDPMailTableView *weakSelf = self;
        NSInteger row = [self.dataSourceObjects indexOfObject:object];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGFloat prevValue = object.cellHeight;
            object.dirty = NO;
            object.cellHeight = kTestHeight;
            CGFloat dif = object.cellHeight - prevValue;
            NSScrollView *scrollView = [weakSelf.tableView enclosingScrollView];
            CGRect visibleRect = scrollView.contentView.visibleRect;
            NSRange range = [weakSelf.tableView rowsInRect:visibleRect];
            NSInteger visibleRow = range.location;
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (!weakSelf.isPausedObjectHeightLoading) {
                    NSPoint origin = [scrollView documentVisibleRect].origin;
                    [NSAnimationContext beginGrouping];
                    [[NSAnimationContext currentContext] setDuration:0.0];
                    [weakSelf.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
                    if (visibleRow > row) {
                        origin.y += dif;
                        [[scrollView documentView] scrollPoint:origin];
                    }
                    [NSAnimationContext endGrouping];
                    weakSelf.loadedObject = nil;
                    [weakSelf loadHeightOfNextObjectInQueue];
                } else {
                    weakSelf.loadedObject = nil;
                    [weakSelf.pausedObjectHeightLoadingArray addObject:@(row)];
                }
            });
        });
    }
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
    IDPTableCacheObject *object = [self.dataSourceObjects objectAtIndex:row];
    CGFloat height = object.cellHeight;
    
    if (object.isDirty) {
        if (!self.loadedObject) {
            self.loadedObject = object;
            [self loadHeightOfNextObjectInQueue];
        }
    }
    return height;
}

@end
