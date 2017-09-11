//
//  TTSShareViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 29/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBrain.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"
#import "TTSHomeViewController.h"
#import "TTSInfoViewController.h"

@interface TTSShareViewController()

@property (assign, nonatomic) BOOL validEmail;
@property (assign, nonatomic) BOOL validPassword;
@property (assign, nonatomic) BOOL validAccountName;
@property (assign, nonatomic) BOOL validConfirmPassword;

@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) WBErrorNoticeView *errorNotice;
@property (strong, nonatomic) WBSuccessNoticeView *successNotice;

@end

@implementation TTSShareViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Sets up our check validators
    [self.email addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.password addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.name addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.confirmPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self reloadTextViews];
    
    //Checks if the user has an existing account
    BOOL hasAccount = [TTSBrain getBoolForKey:@"hasAccount"];
    if (hasAccount) {
        //The user has created an account in the past
        [self changeToLogin:nil];
        self.sharingType = TTSSharingTypeLogin;
    }
    else {
        //We don't have an account, so we're signing up
        self.sharingType = TTSSharingTypeSignup;
    }
    //Add a background tap recogniser
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextViews)];
    [self.view addGestureRecognizer:tap];
}

- (void)reloadTextViews {
    //Validate all entries for our textFields
    [self textFieldDidChange:self.email];
    [self textFieldDidChange:self.password];
    [self textFieldDidChange:self.confirmPassword];
    [self textFieldDidChange:self.name];
}

- (void)resetTextViews {
    //Change all our text values to nil
    self.email.text = @"";
    self.password.text = @"";
    self.confirmPassword.text = @"";
    self.name.text = @"";
}

- (void)resignTextViews {
    //Hide the keyboards of our textFields
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.confirmPassword resignFirstResponder];
    [self.name resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Wipe our textField's slate clean
    [self resetTextViews];
    [self reloadTextViews];
    //Checks what's going down
    if (self.sharingType == TTSSharingTypeLogin) {
        //If we're logging in, don't show the create account views
        [self.loginButton setTitle:@"Don't already have an account? Sign up" forState:UIControlStateNormal];
        self.navigationItem.title = @"Login";
        self.confirmPassword.hidden = YES;
        self.confirmPasswordLabel.hidden = YES;
        self.name.hidden = YES;
        self.nameLabel.hidden = YES;
        self.password.returnKeyType = UIReturnKeyDone;
    }
    else {
        //If we're signing up, show the create account views
        [self.loginButton setTitle:@"Already have an account? Log in" forState:UIControlStateNormal];
        self.navigationItem.title = @"Signup";
        self.confirmPassword.hidden = NO;
        self.confirmPasswordLabel.hidden = NO;
        self.name.hidden = NO;
        self.nameLabel.hidden = NO;
        self.password.returnKeyType = UIReturnKeyNext;
    }
}

- (IBAction)changeToLogin:(id)sender {
    [self resignTextViews];
    if (self.sharingType == TTSSharingTypeSignup)
        self.sharingType = TTSSharingTypeLogin;
    else
        self.sharingType = TTSSharingTypeSignup;
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor colorWithRed:0.862 green:0.875 blue:0.859 alpha:1.000];
    CGRect frameOpen = self.view.frame;
    CGRect frameClosed = self.view.frame;
    frameClosed.size.height = 0;
    frameClosed.origin.y = frameOpen.size.height / 2;

    [UIView animateWithDuration:0.4 animations:^{
        [self.view setFrame:frameClosed];
    }                completion:^(BOOL finished) {
        [self viewWillAppear:YES];
        [UIView animateWithDuration:0.4 animations:^{
            [self.view setFrame:frameOpen];
        }                completion:^(BOOL done) {
            [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
        }];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.email)
        [self.password becomeFirstResponder];
    else if (textField == self.password && self.sharingType == TTSSharingTypeSignup) {
        [self.confirmPassword becomeFirstResponder];
    }
    else if (textField == self.confirmPassword && self.sharingType == TTSSharingTypeSignup) {
        [self.name becomeFirstResponder];
    }
    else
        [textField resignFirstResponder];

    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    //Checks which textField's text has changed
    if (textField == self.email) {
        //If we don't have valid text for email, change the color to show
        if (![TTSBrain NSStringIsValidEmail:self.email.text]) {
            self.validEmail = NO;
            self.emailLabel.textColor = [UIColor redColor];
        }
        else {
            self.validEmail = YES;
            self.emailLabel.textColor = [UIColor blueColor];
        }
    }
    else if (textField == self.password) {
        //If we don't have text for email, change the color to show
        if (self.password.text.length < 6) {
            self.validPassword = NO;
            self.passwordLabel.textColor = [UIColor redColor];
        }
        else {
            self.validPassword = YES;
            self.passwordLabel.textColor = [UIColor blueColor];
        }
        [self textFieldDidChange:self.confirmPassword];
    }
    else if (textField == self.name) {
        //If we don't have text for email, change the color to show
        if (self.name.text.length < 6) {
            self.validAccountName = NO;
            self.nameLabel.textColor = [UIColor redColor];
        }
        else {
            self.validAccountName = YES;
            self.nameLabel.textColor = [UIColor blueColor];
        }
    }
    else if (textField == self.confirmPassword) {
        //If we don't have text for email, change the color to show
        if (![self.password.text isEqualToString:textField.text]) {
            self.validConfirmPassword = NO;
            self.confirmPasswordLabel.textColor = [UIColor redColor];
        }
        else if (self.confirmPassword.text.length < 6) {
            self.validConfirmPassword = NO;
            self.confirmPasswordLabel.textColor = [UIColor redColor];
        }
        else {
            self.validConfirmPassword = YES;
            self.confirmPasswordLabel.textColor = [UIColor blueColor];
        }
    }
    if (self.sharingType == TTSSharingTypeSignup) {
        self.proceed.enabled = self.validEmail && self.validPassword && self.validConfirmPassword && self.validAccountName;
    }
    else {
        self.proceed.enabled = self.validEmail && self.validPassword;
    }
}

- (IBAction)proceed:(id)sender {
    [self resignTextViews];
    NSString *suffix;
    if (self.sharingType == TTSSharingTypeLogin)
        suffix = @"login.php";
    else
        suffix = @"createAccount.php";

    NSURL *url = [NSURL URLWithString:[@"http://hughbellamyapps.heliohost.org/Speak%20Easy/" stringByAppendingString:suffix]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSString *paramString = [NSString stringWithFormat:@"email=%@&password=%@", self.email.text, [TTSBrain hashString:self.password.text withSalt:TTSDatabaseSalt]];
    if (self.sharingType == TTSSharingTypeSignup) {
        paramString = [paramString stringByAppendingFormat:@"&name=%@", self.name.text];
    }
    NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

    if (connection) {
        self.data = [NSMutableData data];
        self.proceed.enabled = NO;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if (self.sharingType == TTSSharingTypeLogin)
            hud.label.text = @"Logging In";
        else
            hud.label.text = @"Creating";
    }
    else {
        self.errorNotice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Error Connecting" message:@"Try again later or check your internet connection"];
        [self.errorNotice show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //We've finished loading so lets hide the progress bar and enable our proceed button in case something went wrong
    self.proceed.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

    //Formats our data
    NSString *str = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    //Now checks what the data means to us
    if ([str isEqualToString:@"sE"]) {
        //The account exists
        self.errorNotice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Account Exists" message:@"An account already exists under this email, please login"];
        [self.errorNotice show];
    }
    else if ([str isEqualToString:@"i"] || [str isEqualToString:@""] || [str isEqualToString:@"mE"]) {
        //Invalid data
        self.errorNotice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown Error" message:@"Please try again later or inform the developer"];
        [self.errorNotice show];
    }
    else if ([str isEqualToString:@"lE"]) {
        //Email was incorrect
        self.errorNotice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Incorrect Email" message:@"No such email exists, signup?"];
        [self.errorNotice show];
    }
    else if ([str isEqualToString:@"lP"]) {
        //Password was incorrect
        self.errorNotice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Incorrect Password" message:@"Incorrect password, try again"];
        [self.errorNotice show];
    }

    self.proceed.enabled = YES;
    NSString *loginSuccessString = @"lS";
    NSString *signupSuccessString = @"sS";
    NSRange loginRangeValue = [str rangeOfString:loginSuccessString options:NSCaseInsensitiveSearch];
    NSRange signupRangeValue = [str rangeOfString:signupSuccessString options:NSCaseInsensitiveSearch];

    if (loginRangeValue.length > 0) {
        NSInteger userID = [[str substringFromIndex:loginSuccessString.length] integerValue];
        [TTSBrain loginWithEmail:self.email.text userID:userID];
        [TTSBrain writeBoolForKey:YES forKey:@"hasAccount"];

        self.successNotice = [WBSuccessNoticeView successNoticeInView:self.view title:@"Logged In"];
        [self.successNotice show];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(toOnline) userInfo:nil repeats:NO];

        self.proceed.enabled = NO;
    }
    else if (signupRangeValue.length > 0) {
        NSInteger userID = [[str substringFromIndex:signupSuccessString.length] integerValue];
        [TTSBrain loginWithEmail:self.email.text userID:userID];
        [TTSBrain writeBoolForKey:YES forKey:@"hasAccount"];

        self.successNotice = [WBSuccessNoticeView successNoticeInView:self.view title:@"Account Created-Welcome!"];
        [self.successNotice show];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(toOnline) userInfo:nil repeats:NO];

        self.proceed.enabled = NO;
    }
}

- (void)toOnline {
    //We've logged in/signed up so lets go to our online presets
    [self performSegueWithIdentifier:@"unwindPresets" sender:nil];
}

- (IBAction)cancelLogin:(id)sender {
    //Tell our delegate that we've cancelled to prevent this popup from appearing again, then go to presets
    [self.delegate userActionsDidCancel];
    [self performSegueWithIdentifier:@"unwindPresets" sender:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //We've failed, so lets enable our proceed button, hide the HUD and tell the user
    self.proceed.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    self.errorNotice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Error Connecting" message:@"Try again later or check your internet connection"];
    [self.errorNotice show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //We've received a response, so reset our data and prepare to receive new data
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //As we receive data, add the received data onto our current data
    [self.data appendData:data];
}

@end
