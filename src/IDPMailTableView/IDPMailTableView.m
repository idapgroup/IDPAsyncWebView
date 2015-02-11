//
//  IDPMailTableView.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailTableView.h"
#import "IDPTableCacheObject.h"
#import "NSTableView+IDPExtension.h"

#pragma mark -
#pragma mark Proxying

static BOOL isInterceptedSelector(SEL sel) {
    return ( sel == @selector(numberOfRowsInTableView:) || sel == @selector(tableView:heightOfRow:));
}

@interface IDPTableViewProxy : NSProxy

@property (nonatomic, weak) id                  target;
@property (nonatomic, weak) IDPMailTableView    *interceptor;

- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(IDPMailTableView *)interceptor;

@end

@implementation IDPTableViewProxy

- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(IDPMailTableView *)interceptor {
    if (!self) {
        return nil;
    }
    
    self.target = target;
    self.interceptor = interceptor;
    
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return (isInterceptedSelector(aSelector) || [self.target respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (isInterceptedSelector(aSelector)) {
        return self.interceptor;
    }
    
    return [self.target respondsToSelector:aSelector] ? self.target : nil;
}

@end

#pragma mark -
#pragma mark IDPMailTableView

static NSInteger const kColumnIndex = 0;
static NSInteger const kDefaultActiveCell = 0;
static CGFloat const kDefaultAnimationDuration = 0;

@interface IDPMailTableView ()

@property (nonatomic, strong) IDPTableCacheObject *loadedObject;
@property (atomic, strong) NSMutableArray         *objecstInQueueToLoadHeight;

@property (atomic, assign, getter = isPausedObjectHeightLoading) BOOL pausedObjectHeightLoading;

@property (nonatomic, strong) NSMutableArray    *pausedObjectHeightLoadingArray;

@property (nonatomic, strong) IDPTableViewProxy    *proxyDataSource;
@property (nonatomic, strong) IDPTableViewProxy    *proxyDelegate;

@property (nonatomic, assign) NSInteger currentActiveCellIndex;

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
    self.objecstInQueueToLoadHeight = [NSMutableArray array];
    self.proxyDataSource = [[IDPTableViewProxy alloc] initWithTarget:nil interceptor:self];
    self.proxyDelegate = [[IDPTableViewProxy alloc] initWithTarget:nil interceptor:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.dataSource = (id<NSTableViewDataSource>)self.proxyDataSource;
    self.tableView.delegate = (id<NSTableViewDelegate>)self.proxyDelegate;
    [self reorderCellsLoadingSequence];
}

#pragma mark -
#pragma mark Accessor methods

- (void)setDataSource:(id<IDPMailTableViewDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    if (_dataSource == nil) {
        self.proxyDataSource = nil;
    } else {
        self.proxyDataSource.target = dataSource;
    }
    self.tableView.dataSource = (id<NSTableViewDataSource>)self.proxyDataSource;
}

- (void)setDelegate:(id<IDPMailTableViewDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }
    _delegate = delegate;
    if (_delegate == nil) {
        self.proxyDelegate = nil;
    } else {
        self.proxyDelegate.target = delegate;
    }
    self.tableView.delegate = (id<NSTableViewDelegate>)self.proxyDelegate;
}

- (void)setDataSourceObjects:(NSArray *)dataSourceObjects {
    _dataSourceObjects = dataSourceObjects;
    self.objecstInQueueToLoadHeight = [NSMutableArray arrayWithArray:_dataSourceObjects];
}

#pragma mark -
#pragma mark Public methods

- (void)reloadData {
    self.currentActiveCellIndex = kDefaultActiveCell;
    [self.tableView reloadData];
    [self reorderCellsLoadingSequence];
}

- (void)scrollRowToVisible:(NSInteger)index {
    self.currentActiveCellIndex = index;
    [self.tableView scrollRowToVisible:index];
    [self reorderCellsLoadingSequence];
}

#pragma mark -
#pragma mark Private methods

- (void)addNotificationObsevers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScrolling:) name:NSScrollViewWillStartLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endScrolling:) name:NSScrollViewDidEndLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewCellDidSelected:) name:NSTableViewSelectionDidChangeNotification object:self.tableView];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewWillStartLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewDidEndLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTableViewSelectionDidChangeNotification object:self.tableView];
}

- (void)startScrolling:(NSNotification *)notification {
    id object = notification.object;
    if (object == self.scrollView) {
        self.pausedObjectHeightLoading = YES;
    }
}

- (void)endScrolling:(NSNotification *)notification {
    id object = notification.object;
    [self updateActiveCellIndex];
    NSInteger visibleRow = self.currentActiveCellIndex;
    if (object == self.scrollView) {
        self.pausedObjectHeightLoading = NO;
        for (NSNumber *row in self.pausedObjectHeightLoadingArray) {
            IDPTableCacheObject *object = [self.dataSourceObjects objectAtIndex:row.integerValue];
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:kDefaultAnimationDuration];
            [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:[row integerValue]]];
            if (visibleRow >= row.integerValue) {
                NSPoint origin = [self.scrollView documentVisibleRect].origin;
                CGFloat dif = object.diffCellheight;
                origin.y += dif;
                [[self.scrollView documentView] scrollPoint:origin];
            }
            [NSAnimationContext endGrouping];
        }
        [self.pausedObjectHeightLoadingArray removeAllObjects];
        [self reorderCellsLoadingSequence];
    }
}

- (void)loadCellHeightInBackground {
    self.loadedObject = [self.objecstInQueueToLoadHeight firstObject];
    if (self.loadedObject) {
        IDPTableCacheObject *object = self.loadedObject;
        [self.objecstInQueueToLoadHeight removeObjectAtIndex:0];
        __weak IDPMailTableView *weakSelf = self;
        NSInteger row = [self.dataSourceObjects indexOfObject:object];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [object.cellHeightCalculator calculateCellHeightWithCallback:^(IDPCellHeightCalculator *calculator, CGFloat newHeight) {
                CGFloat prevValue = object.cellHeight;
                object.dirty = NO;
                object.cellHeight = newHeight;
                CGFloat dif = object.cellHeight - prevValue;
                object.diffCellheight = dif;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (!weakSelf.isPausedObjectHeightLoading) {
                        NSInteger visibleRow = self.currentActiveCellIndex;
                        [NSAnimationContext beginGrouping];
                        [[NSAnimationContext currentContext] setDuration:kDefaultAnimationDuration];
                        [weakSelf.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
                        if (visibleRow >= row) {
                            NSPoint origin = [weakSelf.scrollView documentVisibleRect].origin;
                            origin.y += dif;
                            [[weakSelf.scrollView documentView] scrollPoint:origin];
                        }
                        [NSAnimationContext endGrouping];
                        weakSelf.loadedObject = nil;
                        [weakSelf loadCellHeightInBackground];
                    } else {
                        weakSelf.loadedObject = nil;
                        [weakSelf.pausedObjectHeightLoadingArray addObject:@(row)];
                    }
                });
            }];
        });
    }
}

- (void)reorderCellsLoadingSequence {
    NSArray *visibleRows = [self.tableView visibleRows];
    for (NSNumber *rowIndexValue in [[visibleRows reverseObjectEnumerator] allObjects]) {
        IDPTableCacheObject *object = [self.dataSourceObjects objectAtIndex:rowIndexValue.integerValue];
        if (object.isDirty && [self.objecstInQueueToLoadHeight containsObject:object]) {
            [self.objecstInQueueToLoadHeight removeObject:object];
            [self.objecstInQueueToLoadHeight insertObject:object atIndex:0];
        }
    }
    [self loadCellHeightInBackground];
}

- (void)updateActiveCellIndex {
    NSArray *visibleRows = [self.tableView visibleRows];
    NSInteger visibleRow = [[visibleRows firstObject] integerValue];
    NSView *cell = [self.tableView viewAtColumn:kColumnIndex row:visibleRow makeIfNecessary:NO];
    NSRect frame = cell.frame;
    frame = [self.tableView convertRect:frame fromView:cell];
    NSPoint origin = [self.scrollView documentVisibleRect].origin;
    if (frame.origin.y < origin.y) {
        visibleRow = visibleRows.count > 1 ? visibleRow + 1 : visibleRow;
    }
    self.currentActiveCellIndex = visibleRow;
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSourceObjects.count;
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    IDPTableCacheObject *object = [self.dataSourceObjects objectAtIndex:row];
    CGFloat height = object.cellHeight;
    return height;
}

- (void)tableViewCellDidSelected:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    if (tableView == self.tableView) {
        
    }
}

@end
