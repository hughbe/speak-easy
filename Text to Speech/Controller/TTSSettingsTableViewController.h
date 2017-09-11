//
//  TTSSettingsTableViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 19/10/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTSSettingsTableViewController : UITableViewController <UITextFieldDelegate, NSURLConnectionDelegate, UIActionSheetDelegate>
@property(weak, nonatomic) IBOutlet UILabel *emailLabel;
@property(weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property(weak, nonatomic) IBOutlet UILabel *passwordNewLabel;
@property(weak, nonatomic) IBOutlet UILabel *confirmNewPasswordLabel;
@property(weak, nonatomic) IBOutlet UITextField *email;
@property(weak, nonatomic) IBOutlet UITextField *password;
@property(weak, nonatomic) IBOutlet UITextField *passwordNew;
@property(weak, nonatomic) IBOutlet UITextField *confirmNewPassword;
@property(weak, nonatomic) IBOutlet UIButton *changePasswordButton;


@property(weak, nonatomic) IBOutlet UITextField *currentEmail;
@property(weak, nonatomic) IBOutlet UITextField *changeEmail;
@property(weak, nonatomic) IBOutlet UITextField *changeEmailPassword;
@property(weak, nonatomic) IBOutlet UILabel *currentEmailLabel;
@property(weak, nonatomic) IBOutlet UILabel *changeEmailLabel;
@property(weak, nonatomic) IBOutlet UILabel *changeEmailPasswordLabel;
@property(weak, nonatomic) IBOutlet UIButton *confirmChangeEmail;

@property(weak, nonatomic) IBOutlet UITextField *changeNameEmail;
@property(weak, nonatomic) IBOutlet UITextField *changeNamePassword;
@property(weak, nonatomic) IBOutlet UITextField *changeNameName;

@property(weak, nonatomic) IBOutlet UILabel *changeNameEmailLabel;
@property(weak, nonatomic) IBOutlet UILabel *changeNamePasswordLabel;
@property(weak, nonatomic) IBOutlet UILabel *changeNameNameLabel;
@property(weak, nonatomic) IBOutlet UIButton *confirmChangeName;

@property(weak, nonatomic) IBOutlet UITextField *deleteEmail;
@property(weak, nonatomic) IBOutlet UILabel *deleteEmailLabel;
@property(weak, nonatomic) IBOutlet UITextField *deletePassword;
@property(weak, nonatomic) IBOutlet UILabel *deletePasswordLabel;
@property(weak, nonatomic) IBOutlet UIButton *deleteAccountButton;
@end
