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
#import "NSMutableArray+IDPExtensions.h"
#import <QuartzCore/QuartzCore.h>

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
static CGFloat const kDefaultAnimationDuration = 0.3;
static CGFloat const kIDPResizeDelta = 15;

@interface IDPMailTableView ()

@property (nonatomic, strong) IDPTableCacheObject *loadedObject;
@property (atomic, strong) NSMutableArray         *objecstInQueueToLoadHeight;

@property (atomic, assign, getter = isPausedObjectHeightLoading) BOOL pausedObjectHeightLoading;

@property (nonatomic, strong) NSMutableArray    *pausedObjectHeightLoadingArray;

@property (nonatomic, strong) IDPTableViewProxy    *proxyDataSource;
@property (nonatomic, strong) IDPTableViewProxy    *proxyDelegate;

@property (nonatomic, assign) NSInteger currentActiveCellIndex;

@property (nonatomic, assign, getter = isRecalculateHeight) BOOL recalculateHeight;
@property (nonatomic, assign, getter = isLiveResizingStart) BOOL liveResizingStart;

@property (nonatomic, assign) CGFloat prevViewWidth;

@property (nonatomic, strong) NSArray   *visibleRows;

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
    self.prevViewWidth = NSWidth(self.frame);
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
    self.visibleRows = nil;
    self.prevViewWidth = NSWidth(self.frame);
    self.currentActiveCellIndex = kDefaultActiveCell;
    [self.tableView reloadData];
    [self updateCalculatorContentWidth];
    [self reorderCellsLoadingSequence];
}

- (void)scrollRowToVisible:(NSInteger)index {
    self.currentActiveCellIndex = index;
    [self.tableView scrollRowToVisible:index];
    [self reorderCellsLoadingSequence];
}

- (void)scrollToTopOfRow:(NSInteger)index {
    NSInteger oldIndex = self.currentActiveCellIndex;
    self.currentActiveCellIndex = index;
    if (index > oldIndex) {
        [self scrollRowToVisible:index];
    } else {
        NSRect rect = [self.tableView rectOfRow:index];
        rect.size = NSMakeSize(NSWidth(rect), 1);
        [self.tableView scrollRectToVisible:rect];
        [self reorderCellsLoadingSequence];
    }
}

- (void)updateCellHeight:(CGFloat)cellHeight forRow:(NSInteger)row {
    IDPTableCacheObject *object = self.loadedObject;
    CGFloat prevValue = object.cellHeight;
    object.dirty = NO;
    object.cellHeight = cellHeight;
    CGFloat dif = object.cellHeight - prevValue;
    object.diffCellheight = dif;
}

- (void)resetAllData {
    self.prevViewWidth = NSWidth(self.frame);
    [self.cellHeightCalculator cancel];
    self.currentActiveCellIndex = 0;
    self.loadedObject = nil;
    [self.objecstInQueueToLoadHeight removeAllObjects];
    [self.pausedObjectHeightLoadingArray removeAllObjects];
    self.pausedObjectHeightLoading = NO;
    self.liveResizingStart = NO;
    self.recalculateHeight = NO;
    self.visibleRows = nil;
}

- (void)viewWillStartLiveResize {
    [super viewWillStartLiveResize];
    if (self.currentActiveCellIndex == self.dataSourceObjects.count - 1) {
        [self updateActiveCellIndex];
    }
    self.liveResizingStart = YES;
    [self checksIsStopCellHeightCalculation];
}

- (void)viewDidEndLiveResize {
    [super viewDidEndLiveResize];
    self.liveResizingStart = NO;
    if (self.isRecalculateHeight) {
        self.objecstInQueueToLoadHeight = [NSMutableArray arrayWithArray:self.dataSourceObjects];
        [self updateCalculatorContentWidth];
        [self reorderCellsLoadingSequence];
        self.recalculateHeight = NO;
    }
}

#pragma mark -
#pragma mark Private methods

- (void)addNotificationObsevers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScrolling:) name:NSScrollViewWillStartLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endScrolling:) name:NSScrollViewDidEndLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewCellDidSelected:) name:NSTableViewSelectionDidChangeNotification object:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScrolling:) name:IDPNOTIFICATION_CENTER_START_SCROLL_WHEEL object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endScrolling:) name:IDPNOTIFICATION_CENTER_END_SCROLL_WHEEL object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScrolling:) name:IDPNOTIFICATION_CENTER_START_SCROLL_KEY object:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endScrolling:) name:IDPNOTIFICATION_CENTER_END_SCROLL_KEY object:self.scrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
    
    NSView *view = [self.scrollView contentView];
    [view setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(frameDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:view];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewWillStartLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewDidEndLiveScrollNotification object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTableViewSelectionDidChangeNotification object:self.tableView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IDPNOTIFICATION_CENTER_START_SCROLL_WHEEL object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IDPNOTIFICATION_CENTER_END_SCROLL_WHEEL object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IDPNOTIFICATION_CENTER_START_SCROLL_KEY object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IDPNOTIFICATION_CENTER_END_SCROLL_KEY object:self.scrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
    NSView *view = [self.scrollView contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:view];
}

- (void)frameDidChange:(NSNotification *)notification {
    if (notification.object == self && self.isLiveResizingStart && self.isRecalculateHeight) {
        CGFloat width = NSWidth(self.frame);
        CGFloat delta = fabs(self.prevViewWidth - width);
        if (delta >= kIDPResizeDelta) {
            self.prevViewWidth = width;
            [self updateOnlyVisiblesCells];
        }
    } else if (notification.object == [self.scrollView contentView]) {
        NSArray *visibleRows = [self.tableView visibleRows];
        NSMutableArray *visibleRowsMutable = [NSMutableArray arrayWithArray:visibleRows];
        [visibleRowsMutable removeObjectsInArray:self.visibleRows];
        self.visibleRows = visibleRows;
        if (visibleRowsMutable.count > 0 && [self.delegate conformsToProtocol:@protocol(IDPMailTableViewDelegate)] && [self.delegate respondsToSelector:@selector(mailTableView:didDispalyRowAtIndex:)]) {
            [self.delegate mailTableView:self didDispalyRowAtIndex:[[visibleRowsMutable firstObject] integerValue]];
        }
    }
}

- (void)startScrolling:(NSNotification *)notification {
    if (notification.object == self.scrollView) {
        self.pausedObjectHeightLoading = YES;
    }
}

- (void)endScrolling:(NSNotification *)notification {
    [self updateCellsHeightAfterStopScrolling:notification];
}

- (void)updateCellsHeightAfterStopScrolling:(NSNotification *)notification {
    id object = notification.object;
    [self updateActiveCellIndex];
    if (object == self.scrollView) {
        self.pausedObjectHeightLoading = NO;
        [self updateCellsHeightAfterStopScrolling];
    }
}

- (void)updateCellsHeightAfterStopScrolling {
    NSNumber *row = [self.pausedObjectHeightLoadingArray firstObject];
    if (row) {
        IDPTableCacheObject *object = [self.dataSourceObjects objectAtIndex:row.integerValue];
        __weak typeof(self) weakSelf = self;
        [self updateCellHeightForRow:row.integerValue visibleRow:self.currentActiveCellIndex object:object completionHandler:^{
            [weakSelf.pausedObjectHeightLoadingArray removeObject:row];
            [weakSelf performSelector:@selector(updateCellsHeightAfterStopScrolling)];
        }];
    } else {
        [self.pausedObjectHeightLoadingArray removeAllObjects];
        [self reorderCellsLoadingSequence];
    }
}

- (void)loadCellHeightInBackground {
    if (!self.loadedObject) {
        self.loadedObject = [self.objecstInQueueToLoadHeight firstObject];
        if (self.loadedObject) {
            IDPTableCacheObject *object = self.loadedObject;
            __weak IDPMailTableView *weakSelf = self;
            NSInteger row = [self.dataSourceObjects indexOfObject:object];
            [self.cellHeightCalculator calculateCellHeighForObject:object callback:^(IDPCellHeightCalculator *calculator, CGFloat newHeight) {
                [weakSelf.objecstInQueueToLoadHeight removeObject:object];
                object.diffCellheight = newHeight - object.cellHeight;
                object.cellHeight = newHeight;
                if (!weakSelf.isPausedObjectHeightLoading) {
                    NSInteger visibleRow = weakSelf.currentActiveCellIndex;
                    [weakSelf updateCellHeightForRow:row visibleRow:visibleRow object:object completionHandler:^{
                        weakSelf.loadedObject = nil;
                        [weakSelf loadCellHeightInBackground];
                    }];
                } else {
                    weakSelf.loadedObject = nil;
                    [weakSelf.pausedObjectHeightLoadingArray addObject:@(row)];
                }
            }];
        } 
    }
}

- (void)updateCellHeightForRow:(NSInteger)row visibleRow:(NSInteger)visibleRow object:(IDPTableCacheObject *)object completionHandler:(void (^)(void))completionHandler {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        context.duration = [self animateRowReloading:row] ? kDefaultAnimationDuration : 0;
        [[self.tableView animator] noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
        if (visibleRow > row) {
            NSPoint origin = [self.scrollView documentVisibleRect].origin;
            origin.y += object.diffCellheight;
            [[[self.scrollView documentView] animator] scrollPoint:origin];
        }
    } completionHandler:^{
        NSArray *visibleRows = [self.tableView visibleRows];
        self.visibleRows = visibleRows;
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (BOOL)animateRowReloading:(NSInteger)row {
    BOOL isAnimate = row == self.currentActiveCellIndex;
    if (!isAnimate) {
        NSArray *visibleRows = [self.tableView visibleRows];
        BOOL isVisible = [visibleRows containsObject:@(row)];
        
        if (isVisible) {
            NSInteger visibleRow = [[visibleRows firstObject] integerValue];
            NSView *cell = [self.tableView viewAtColumn:kColumnIndex row:visibleRow makeIfNecessary:NO];
            NSRect frame = cell.frame;
            frame = [self.tableView convertRect:frame fromView:cell];
            NSPoint origin = [self.scrollView documentVisibleRect].origin;
            if (frame.origin.y + NSHeight(frame) / 2 < origin.y) {
                isAnimate = NO;
            }
        }
    }
    
    return isAnimate;
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
    if (visibleRows.count > 0) {
        NSInteger visibleRow = [[visibleRows firstObject] integerValue];
        NSView *cell = [self.tableView viewAtColumn:kColumnIndex row:visibleRow makeIfNecessary:NO];
        NSRect frame = cell.frame;
        frame = [self.tableView convertRect:frame fromView:cell];
        NSPoint origin = [self.scrollView documentVisibleRect].origin;
        if (frame.origin.y + NSHeight(frame) / 2 < origin.y) {
            visibleRow = visibleRows.count > 1 ? visibleRow + 1 : visibleRow;
        }
        self.currentActiveCellIndex = visibleRow;
    }
}

- (void)checksIsStopCellHeightCalculation {
    BOOL isRecalculateHeight = [self.delegate mailTableViewRecalculateCellHeightIfChangeCellWidth:self];
    self.recalculateHeight = isRecalculateHeight;
    if (isRecalculateHeight) {
        [self markAllCachedObjectsAsDerty];
    }
}

- (void)markAllCachedObjectsAsDerty {
    [self.dataSourceObjects setValue:@(YES) forKeyPath:@"dirty"];
    [self.cellHeightCalculator cancel];
    self.objecstInQueueToLoadHeight = nil;
    self.loadedObject = nil;
}

- (void)updateCalculatorContentWidth {
    [self.delegate mailTableView:self updateCellHeightCalculatorContentWidth:self.cellHeightCalculator];
}

- (void)updateOnlyVisiblesCells {
    [self.cellHeightCalculator cancel];
    self.objecstInQueueToLoadHeight = nil;
    self.loadedObject = nil;
    NSArray *visibleRows = [self.tableView visibleRows];
    NSMutableArray *visibleObjects = [NSMutableArray array];
    for (NSNumber *row in [visibleRows reverseObjectEnumerator]) {
        IDPTableCacheObject *object = [self.dataSourceObjects objectAtIndex:row.integerValue];
        object.dirty = YES;
        [visibleObjects addObject:object];
    }
    self.objecstInQueueToLoadHeight = visibleObjects;
    [self updateCalculatorContentWidth];
    [self loadCellHeightInBackground];
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
