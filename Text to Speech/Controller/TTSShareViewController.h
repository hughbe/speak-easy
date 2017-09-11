//
//  TTSShareViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 29/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//
@class TTSInfoViewController;

#import "MBProgressHUD.h"

@protocol TTSUserActionsDelegate

- (void)userActionsDidCancel;

@end

@interface TTSShareViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate>

@property(weak, nonatomic) id <TTSUserActionsDelegate> delegate;

@property(weak, nonatomic) IBOutlet UILabel *emailLabel;
@property(weak, nonatomic) IBOutlet UITextField *email;

@property(weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property(weak, nonatomic) IBOutlet UITextField *password;

@property(weak, nonatomic) IBOutlet UILabel *confirmPasswordLabel;
@property(weak, nonatomic) IBOutlet UITextField *confirmPassword;

@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UITextField *name;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *proceed;
@property(weak, nonatomic) IBOutlet UIButton *loginButton;

@property(nonatomic) TTSSharingType sharingType;

@property(weak, nonatomic) NSMutableArray *presetArray;

@property(nonatomic, assign) BOOL bannerIsVisible;

@end
