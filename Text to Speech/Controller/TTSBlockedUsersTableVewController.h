//
//  TTSBlockedUsersTableVewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 01/11/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//


@import UIKit;

#import "WBErrorNoticeView.h"

@interface TTSBlockedUsersTableVewController : UITableViewController <NSURLConnectionDelegate>

@property(strong, nonatomic) NSMutableArray *blockedUsers;

@property(strong, nonatomic) NSMutableData *mutData;
@property(strong, nonatomic) WBErrorNoticeView *errorNoticeView;
@property(strong, nonatomic) NSString *message;

@end
