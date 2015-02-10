//
//  IDPMailMessageModel.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailMessageModel.h"

@implementation IDPMailMessageModel

#pragma mark -
#pragma mark Public methods

- (NSString *)senderString {
    return [self.sender componentsJoinedByString:@","];
}

- (NSString *)recipientsString {
    return [self.recipients componentsJoinedByString:@","];
}

@end
