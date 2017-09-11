//
//  TTSSearchViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 22/10/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

@import UIKit;

#import "WBErrorNoticeView.h"

@interface TTSSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSURLConnectionDelegate>
@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *users;

@property(strong, nonatomic) NSMutableData *mutData;
@property(strong, nonatomic) WBErrorNoticeView *errorNoticeView;
@property(strong, nonatomic) NSString *message;
@end
