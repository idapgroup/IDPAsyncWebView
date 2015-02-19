//
//  IDPMailMessageModel.m
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPMailMessageModel.h"
#import "NSDate+DateTools.h"

@interface IDPMailMessageModel ()

@property (nonatomic, copy)   NSString  *formattedDate;

@end

@implementation IDPMailMessageModel

#pragma mark -
#pragma mark Accessor methods

- (void)setDate:(NSDate *)date {
    if (_date == date) {
        return;
    }
    _date = date;
    _formattedDate = nil;
}

- (NSString *)formattedDate {
    if (!_formattedDate) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"MMMM dd, YYYY hh:mm"];
        _formattedDate = [dateFormatter stringFromDate:self.date];
    }
    return _formattedDate;
}

#pragma mark -
#pragma mark Public methods

- (NSString *)senderString {
    return [self.sender componentsJoinedByString:@","];
}

- (NSString *)recipientsString {
    return [self.recipients componentsJoinedByString:@","];
}

- (NSString *)shortFromattedDate {
    return self.date.shortTimeAgoSinceNow;
}

@end
