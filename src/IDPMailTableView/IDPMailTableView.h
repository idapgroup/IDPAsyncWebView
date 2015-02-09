//
//  IDPMailTableView.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/9/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol IDPMailTableViewDelegate <NSTableViewDelegate>



@end

@interface IDPMailTableView : NSView

@property (nonatomic, strong) IBOutlet NSTableView  *tableView;
@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;

@end