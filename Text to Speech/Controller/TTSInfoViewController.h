//
//  TTSInfoViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 27/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

@import UIKit;
@import iAd;
@import AVFoundation;

#import "TTSBrain.h"
#import "TTSVoiceCell.h"
#import "TTSBottomCell.h"
#import "WBErrorNoticeView.h"
#import "WYPopoverController.h"
#import "TTSShareViewController.h"
#import "TTSPresetterViewController.h"

@interface TTSInfoViewController : UIViewController <WYPopoverControllerDelegate, AVSpeechSynthesizerDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate, TTSUserActionsDelegate, ADBannerViewDelegate, UIActionSheetDelegate>

FOUNDATION_EXPORT NSInteger const toIncrementEachLoad;

@property(weak, nonatomic) IBOutlet UIView *offlineHeaderView;
@property(weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet ADBannerView *adView;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property(weak, nonatomic) IBOutlet UIButton *profileOptionsButton;

@property(strong, nonatomic) NSString *message;
@property(nonatomic) NSUInteger currentlyViewing;
@property(strong, nonatomic) NSMutableArray *presets;

@property(nonatomic) BOOL loading;
@property(nonatomic) BOOL canceled;

@property(nonatomic) BOOL blocked;
@property(nonatomic) CGFloat height;
@property(nonatomic, assign) BOOL bannerIsVisible;

@property(nonatomic) NSInteger ID;
@property(weak, nonatomic) NSString *userName;
@property(strong, nonatomic) NSMutableData *mutData;
@property(nonatomic) NSMutableArray *sharePresetArray;


@property(strong, nonatomic) NSIndexPath *path;
@property(strong, nonatomic) TTSVoiceCell *selectedCell;
@property(strong, nonatomic) NSIndexPath *selectedIndexPath;

@property(strong, nonatomic) WBErrorNoticeView *notice;

@property(strong, nonatomic) WYPopoverController *presetterPopover;
@property(strong, nonatomic) TTSPresetterViewController *presetterController;

@property(nonatomic) TTSPresetInfoType infoType;
@property(nonatomic) TTSPresetOnlineType onlineType;

@property(strong, nonatomic) NSURLConnection *connection;


- (void)update;
- (void)reloadData;
-(void)showShareOptions:(NSTimer*)timer;
@end
