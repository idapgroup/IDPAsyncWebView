//
//  AppDelegate.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "AppDelegate.h"
#import "IDPMailMessageModel.h"
#import "IDPMailHistoryChainModel.h"

static NSInteger kMailInChain = 10;
static NSInteger  kMailCount = 20;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSMutableArray    *testMailObjects;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self generateTestData];
    self.mailListViewController.mailObjects = [NSArray arrayWithArray:self.testMailObjects];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark -
#pragma mark Private methods

- (void)generateTestData {
    for (NSInteger index = 0; index < kMailCount; index++) {
        IDPMailHistoryChainModel *chainModel = [IDPMailHistoryChainModel new];
        for (NSInteger kIndex = 0; kIndex < kMailInChain; kIndex++) {
            IDPMailMessageModel *model = [IDPMailMessageModel new];
            model.subject = @"Test subject";
            model.recipients = @[@"test.test@recipient.com"];
            model.sender = @[@"test.test@sender.com"];
            model.date = [NSDate date];
            model.text = @"Test text";
        }
        [self.testMailObjects addObject:chainModel];
    }
}

@end
