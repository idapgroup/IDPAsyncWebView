//
//  IDPView.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IDPMailTableView.h"

@interface IDPTestView : NSView

@property (nonatomic, strong) IBOutlet IDPMailTableView *mailTableView;

@end