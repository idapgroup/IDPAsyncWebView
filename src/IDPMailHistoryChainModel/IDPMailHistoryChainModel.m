//
//  IDPMailHistoryChainModel.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailHistoryChainModel.h"

@interface IDPMailHistoryChainModel ()

@property (nonatomic, strong) NSMutableArray   *mailMessagesInternal;

@end

@implementation IDPMailHistoryChainModel

#pragma mark -
#pragma mark Initializations and Deallocations

- (instancetype)init {
    self = [super init];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    self.mailMessagesInternal = [NSMutableArray array];
}

#pragma mark -
#pragma mark Accessor methods

- (NSArray *)mailMessages {
    return [NSArray arrayWithArray:self.mailMessagesInternal];
}

#pragma mark -
#pragma mark Public methods

- (IDPMailMessageModel *)firstUnreadMail {
    IDPMailMessageModel *firstUnreadMail = nil;
    for (IDPMailMessageModel *object in self.mailMessages) {
        if (NO == object.isRead) {
            firstUnreadMail = object;
            break;
        }
    }
    return firstUnreadMail;
}

- (NSInteger)indexOfFirstUnreadMail {
    return [self.mailMessages indexOfObject:[self firstUnreadMail]];
}

- (void)addNewMailMessage:(IDPMailMessageModel *)mailMessage {
    if (mailMessage) {
        [self.mailMessagesInternal insertObject:mailMessage atIndex:0];
    }
}

- (void)removeMailMessage:(IDPMailMessageModel *)mailMessage {
    [self.mailMessagesInternal removeObject:mailMessage];
}

@end
