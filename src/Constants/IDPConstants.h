//
//  IDPConstants.h
//  IDPMailView
//
//  Created by Artem Chabanniy on 2/10/15.
//  Copyright (c) 2015 IDAP Group. All rights reserved.
//

#ifndef __IDPMailView__IDPConstants__
#define __IDPMailView__IDPConstants__

//Notification center

#define NOTIFICATION_CENTER_DID_SELECTED_MAIL_CHAIN @"NOTIFICATION_CENTER_DID_SELECTED_MAIL_CHAIN"
#define NOTIFICATION_CENTER_DID_SELECTED_MAIL @"NOTIFICATION_CENTER_DID_SELECTED_MAIL"
#define NOTIFICATION_CENTER_DID_UPDATE_ACTIVE_PREVIEW_CELL @"NOTIFICATION_CENTER_DID_UPDATE_ACTIVE_PREVIEW_CELL"
#define NOTIFICATION_CENTER_DID_UPDATE_MAIL_DETAILS @"NOTIFICATION_CENTER_DID_UPDATE_MAIL_DETAILS"

//Notification user info key

#define KEYNC(name) static NSString *const kIDPNC##name = @#name

KEYNC(RowIndex);
KEYNC(Object);

#endif /* defined(__IDPMailView__IDPConstants__) */
