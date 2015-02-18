//
//  IDPMailListTableCellView.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#import "IDPBaseTableCell.h"

@interface IDPMailListTableCellView : IDPBaseTableCell

@property (nonatomic, strong) IBOutlet NSTextField  *fromTextField;
@property (nonatomic, strong) IBOutlet NSTextField  *subjectTextField;

@end
