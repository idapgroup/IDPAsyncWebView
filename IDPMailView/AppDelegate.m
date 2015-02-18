//
//  AppDelegate.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "AppDelegate.h"
#import "IDPMailHistoryChainModel.h"
#import "NSColor+IDPExtension.h"

static NSInteger kMailInChain = 100;
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
    self.testMailObjects = [NSMutableArray array];
    NSString *folderName = @"html files";
    NSArray *array = @[@"html-1",@"html-2",@"html-3",@"html-4"];
    NSArray *previewArray = @[@"html-1_text",@"html-2_text",@"html-3_text",@"html-4_text"];
    NSArray *backgroundColors = @[[NSColor colorWithIntRed:252 green:221 blue:226 alpha:255],
                                  [NSColor colorWithIntRed:244 green:238 blue:238 alpha:255],
                                  [NSColor colorWithIntRed:137 green:188 blue:78 alpha:255],
                                  [NSColor colorWithIntRed:51 green:22 blue:18 alpha:255]];
    NSArray *textColors = @[[NSColor colorWithIntRed:0 green:0 blue:0 alpha:255],
                                  [NSColor colorWithIntRed:0 green:0 blue:0 alpha:255],
                                  [NSColor colorWithIntRed:0 green:0 blue:0 alpha:255],
                                  [NSColor colorWithIntRed:255 green:255 blue:255 alpha:255]];
    
    
    for (NSInteger index = 0; index < kMailCount; index++) {
        IDPMailHistoryChainModel *chainModel = [IDPMailHistoryChainModel new];
        for (NSInteger kIndex = 0; kIndex < kMailInChain; kIndex++) {
            IDPMailMessageModel *model = [IDPMailMessageModel new];
            model.subject = [NSString stringWithFormat:@"Test subject %ld-%ld", (long)index+1, (long)kIndex+1];
            model.recipients = @[@"test.test@recipient.com"];
            model.sender = @[[NSString stringWithFormat:@"test.test@sender.com %ld-%ld",(long)index+1,(long)kIndex+1]];
            model.date = [NSDate date];
            NSInteger randomIndex = (NSInteger)arc4random_uniform((u_int32_t)array.count);
            NSString *fileName = [array objectAtIndex:randomIndex];
            NSString *contentString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@/%@", folderName, fileName] ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
            model.content = contentString;
            model.urlForContentResources = [[NSBundle mainBundle] URLForResource:folderName withExtension:nil];
            fileName = [previewArray objectAtIndex:randomIndex];
            NSString *previewContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@/%@", folderName, fileName] ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
            model.previewContent = previewContent;
            model.previewBackgroundColor = [backgroundColors objectAtIndex:randomIndex];
            model.previewTextColor = [textColors objectAtIndex:randomIndex];
            [chainModel addNewMailMessage:model];
        }
        [self.testMailObjects addObject:chainModel];
    }
}

@end
