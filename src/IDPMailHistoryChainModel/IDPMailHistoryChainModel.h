//
//  IDPMailHistoryChainModel.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDPMailMessageModel.h"

@interface IDPMailHistoryChainModel : NSObject

@property (nonatomic, strong, readonly) NSArray    *mailMessages;

- (IDPMailMessageModel *)firstUnreadMail;
- (NSInteger)indexOfFirstUnreadMail;

/**
 Add on top of mailMessages new mailMessage.
 */
- (void)addNewMailMessage:(IDPMailMessageModel *)mailMessage;
- (void)removeMailMessage:(IDPMailMessageModel *)mailMessage;

@end
