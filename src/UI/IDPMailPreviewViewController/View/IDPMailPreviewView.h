//
//  IDPMailPreviewView.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/17/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IDPMailPreviewView : NSView

@property (nonatomic, strong) IBOutlet NSTableView  *tableView;
@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSImageView  *imageView;

@end
