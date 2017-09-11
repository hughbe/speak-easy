//
//  TTSSettingsTableViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 19/10/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSSettingsTableViewController.h"

#import "TTSBrain.h"
#import "MBProgressHUD.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"

@interface TTSSettingsTableViewController()

@property (strong, nonatomic) NSMutableData *mutData;

@end

@implementation TTSSettingsTableViewController

NSInteger selectedCellIndex = -1;
WBErrorNoticeView *errorNoticeView;
WBSuccessNoticeView *successNoticeView;

NSString *email;

UIColor *validColor;
UIColor *invalidColor;

BOOL validEmail;
BOOL validPassword;
BOOL validNewPassword;
BOOL validConfirmNewPassword;

BOOL validChangeEmail;
BOOL validChangeCurrentEmail;
BOOL validChangeEmailPassword;

BOOL validChangeNameEmail;
BOOL validChangeNamePassword;
BOOL validChangeNameName;

BOOL validDeleteEmail;
BOOL validDeletePassword;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    [self.tableView setAllowsSelection:YES];
    //Sets up our custom colors for valid and invalid properties
    invalidColor = [UIColor redColor];
    validColor = [UIApplication sharedApplication].keyWindow.tintColor;

    //Adds our validation observer and validates for the 1st time
    [self.email addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.password addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordNew addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.confirmNewPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.currentEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.changeEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.changeEmailPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.changeNameEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.changeNamePassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.changeNameName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.deleteEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.deletePassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self reloadTextViews];

    //Adds background tapRecognizer to hide keyboard when tapped
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextFields)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.userInteractionEnabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //Proceeds onto the next textField depending on which textField is being dismissed
    if (textField == self.email)
        [self.password becomeFirstResponder];
    else if (textField == self.password)
        [self.passwordNew becomeFirstResponder];
    else if (textField == self.passwordNew)
        [self.confirmNewPassword becomeFirstResponder];
    else if (textField == self.confirmNewPassword)
        [textField resignFirstResponder];

    else if (textField == self.currentEmail)
        [self.changeEmail becomeFirstResponder];
    else if (textField == self.changeEmail)
        [self.changeEmailPassword becomeFirstResponder];
    else if (textField == self.changeEmailPassword)
        [textField resignFirstResponder];

    else if (textField == self.changeNameEmail)
        [self.changeNamePassword becomeFirstResponder];
    else if (textField == self.changeNamePassword)
        [self.changeNameName becomeFirstResponder];
    else if (textField == self.changeNameName)
        [textField resignFirstResponder];

    else if (textField == self.deleteEmail)
        [self.deletePassword becomeFirstResponder];
    else if (textField == self.deletePassword)
        [textField resignFirstResponder];

    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    //Checks which textField's text has changed
    if (textField == self.email) {
        //If we don't have valid text for email, change the color to show
        if (![TTSBrain NSStringIsValidEmail:textField.text]) {
            validEmail = NO;
            self.emailLabel.textColor = invalidColor;
        }
        else {
            validEmail = YES;
            self.emailLabel.textColor = validColor;
        }
    }
    else if (textField == self.password) {
        //Checks if our currentPassword textField is valid
        if (textField.text.length < 6) {
            validPassword = NO;
            self.passwordLabel.textColor = invalidColor;
        }
        else {
            validPassword = YES;
            self.passwordLabel.textColor = validColor;
        }
    }
    else if (textField == self.passwordNew) {
        //Checks if our newPassword textField is valid and then validates our confirmPasswordField to reflect the newPassword's change
        if (textField.text.length < 6) {
            validNewPassword = NO;
            self.passwordNewLabel.textColor = invalidColor;
        }
        else {
            validNewPassword = YES;
            self.passwordNewLabel.textColor = validColor;
        }
        [self textFieldDidChange:self.confirmNewPassword];
    }
    else if (textField == self.confirmNewPassword) {
        //Checks if our confirmNewPassword textField is valid, equal to our newPassword textField and then validates it further
        if (![self.passwordNew.text isEqualToString:textField.text]) {
            validConfirmNewPassword = NO;
            self.confirmNewPasswordLabel.textColor = invalidColor;
        }
        else if (self.confirmNewPassword.text.length < 6) {
            validConfirmNewPassword = NO;
            self.confirmNewPasswordLabel.textColor = invalidColor;
        }
        else {
            validConfirmNewPassword = YES;
            self.confirmNewPasswordLabel.textColor = validColor;
        }
    }

    else if (textField == self.currentEmail) {
        //Validates the entry for currentEmail
        if (![TTSBrain NSStringIsValidEmail:textField.text]) {
            validChangeCurrentEmail = NO;
            self.currentEmailLabel.textColor = invalidColor;
        }
        else {
            validChangeCurrentEmail = YES;
            self.currentEmailLabel.textColor = validColor;
        }
    }
    else if (textField == self.changeEmail) {
        //Validates the entry for our newEmail
        if (![TTSBrain NSStringIsValidEmail:textField.text]) {
            validChangeEmail = NO;
            self.changeEmailLabel.textColor = invalidColor;
        }
        else {
            validChangeEmail = YES;
            self.changeEmailLabel.textColor = validColor;
        }
    }
    else if (textField == self.changeEmailPassword) {
        //Validates the entry for our newEmail password
        if (textField.text.length < 6) {
            validChangeEmailPassword = NO;
            self.changeEmailPasswordLabel.textColor = invalidColor;
        }
        else {
            validChangeEmailPassword = YES;
            self.changeEmailPasswordLabel.textColor = validColor;
        }
    }

    else if (textField == self.changeNameEmail) {
        //Validates the entry for our current email to change our name
        if (![TTSBrain NSStringIsValidEmail:textField.text]) {
            validChangeNameEmail = NO;
            self.changeNameEmailLabel.textColor = invalidColor;
        }
        else {
            validChangeNameEmail = YES;
            self.changeNameEmailLabel.textColor = validColor;
        }
    }
    else if (textField == self.changeNamePassword) {
        //Validates the entry for our password to change our name
        if (textField.text.length < 6) {
            validChangeNamePassword = NO;
            self.changeNamePasswordLabel.textColor = invalidColor;
        }
        else {
            validChangeNamePassword = YES;
            self.changeNamePasswordLabel.textColor = validColor;
        }
    }
    else if (textField == self.changeNameName) {
        //Validates the entry for our newName
        if (textField.text.length < 5) {
            validChangeNameName = NO;
            self.changeNameNameLabel.textColor = invalidColor;
        }
        else {
            validChangeNameName = YES;
            self.changeNameNameLabel.textColor = validColor;
        }
    }

    else if (textField == self.deleteEmail) {

        //Validates the entry for our deleteEmail
        if (![TTSBrain NSStringIsValidEmail:textField.text]) {
            validDeleteEmail = NO;
            self.deleteEmailLabel.textColor = invalidColor;
        }
        else {
            validDeleteEmail = YES;
            self.deleteEmailLabel.textColor = validColor;
        }
    }
    else if (textField == self.deletePassword) {
        //Validates the entry for our deleteAccount password
        if (textField.text.length < 6) {
            validDeletePassword = NO;
            self.deletePasswordLabel.textColor = invalidColor;
        }
        else {
            validDeletePassword = YES;
            self.deletePasswordLabel.textColor = validColor;
        }
    }
    //If we have valid change data for each of the settings options,
    //and enable the respective confirm button for each option according to validity
    self.changePasswordButton.enabled = validEmail & validPassword & validNewPassword & validConfirmNewPassword;

    self.confirmChangeEmail.enabled = validChangeCurrentEmail & validChangeEmail & validChangeEmailPassword;

    self.confirmChangeName.enabled = validChangeNameEmail & validChangeNamePassword & validChangeNameName;

    self.deleteAccountButton.enabled = validDeleteEmail & validDeletePassword;
}

- (void)resignTextFields {
    //Hides keyboards for all our textFields
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.passwordNew resignFirstResponder];
    [self.confirmNewPassword resignFirstResponder];

    [self.currentEmail resignFirstResponder];
    [self.changeEmail resignFirstResponder];
    [self.changeEmailPassword resignFirstResponder];

    [self.changeNameEmail resignFirstResponder];
    [self.changeNamePassword resignFirstResponder];
    [self.changeNameName resignFirstResponder];

    [self.deleteEmail resignFirstResponder];
    [self.deletePassword resignFirstResponder];
}

- (void)resetTextViews {
    //Reset text for all our textFields
    self.email.text = @"";
    self.password.text = @"";
    self.passwordNew.text = @"";
    self.confirmNewPassword.text = @"";

    self.currentEmail.text = @"";
    self.changeEmail.text = @"";
    self.changeEmailPassword.text = @"";

    self.changeNameEmail.text = @"";
    self.changeNamePassword.text = @"";
    self.changeNameName.text = @"";

    self.deleteEmail.text = @"";
    self.deletePassword.text = @"";
    [self reloadTextViews];
}

- (void)reloadTextViews {
    //Validate entries for all our textFields
    [self textFieldDidChange:self.email];
    [self textFieldDidChange:self.password];
    [self textFieldDidChange:self.passwordNew];
    [self textFieldDidChange:self.confirmNewPassword];

    [self textFieldDidChange:self.currentEmail];
    [self textFieldDidChange:self.changeEmail];
    [self textFieldDidChange:self.changeEmailPassword];

    [self textFieldDidChange:self.changeNameEmail];
    [self textFieldDidChange:self.changeNamePassword];
    [self textFieldDidChange:self.changeNameName];

    [self textFieldDidChange:self.deleteEmail];
    [self textFieldDidChange:self.deletePassword];
}

- (IBAction)logout:(id)sender {
    //Logs us out and unwinds us to our offline view
    [TTSBrain logout];
    [self performSegueWithIdentifier:@"unwindPresets" sender:nil];
}

- (IBAction)confirmPasswordChange:(id)sender {
    //Validates our data again
    if (![TTSBrain NSStringIsValidEmail:self.email.text] || self.password.text.length < 6 || self.passwordNew.text.length < 6 || self.confirmNewPassword.text.length < 6) {
        //If we have invalid change password data, data is invalid
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"Please fill in all the fields correctly"];
        [errorNoticeView show];
    }
    else if ([self.password.text isEqualToString:self.passwordNew.text]) {
        //If the new password entered is the same as your current password entered, data is invalid
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"Your new password entered is the same as your current password"];
        [errorNoticeView show];
    }
    else if (![self.passwordNew.text isEqualToString:self.confirmNewPassword.text]) {
        //If the new password and the confirm new password don't match, data is invalid
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"New passwords do not match"];
        [errorNoticeView show];
    }
    else {
        //Data is valid, so let's update our password
        [self changeUserWithPOSTType:@"password" email:self.email.text unencryptedPassword:self.password.text newValue:self.passwordNew.text];
    }
}

- (IBAction)confirmEmailChange:(id)sender {
    if (![TTSBrain NSStringIsValidEmail:self.currentEmail.text] || self.changeEmail.text.length == 0 || self.changeEmailPassword.text.length < 6 || self.confirmNewPassword.text.length < 6) {
        //If we have invalid change email data, data is invalid
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"Please fill in all the fields correctly"];
        [errorNoticeView show];
    }
    else if ([self.currentEmail.text isEqualToString:self.changeEmail.text]) {
        //If the new email entered is the same as your current email entered, data is invalid
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"Your new email entered is the same as your current email"];
        [errorNoticeView show];
    }
    else {
        //Data is valid, so let's update our email
        email = self.changeEmail.text;
        [self changeUserWithPOSTType:@"email" email:self.currentEmail.text unencryptedPassword:self.changeEmailPassword.text newValue:self.changeEmail.text];
    }
}

- (IBAction)confirmChangeName:(id)sender {
    if (![TTSBrain NSStringIsValidEmail:self.changeNameEmail.text] || self.changeNamePassword.text.length < 6 || self.changeNameName.text.length < 5) {
        //If we have invalid change name data, data is invalid
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"Please fill in all the fields correctly"];
        [errorNoticeView show];
    }
    else {
        //Data is valid, so let's get changing our name
        [self changeUserWithPOSTType:@"name" email:self.changeNameEmail.text unencryptedPassword:self.changeNamePassword.text newValue:self.changeNameName.text];
    }
}

- (IBAction)confirmDeleteAccount:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Really delete account?" delegate:self cancelButtonTitle:@"CANCEL" destructiveButtonTitle:@"DELETE" otherButtonTitles:nil, nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Checks if we've pressed delete
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        if (![TTSBrain NSStringIsValidEmail:self.deleteEmail.text] || self.deletePassword.text.length < 60) {
            //If we have invalid delete account data, data is invalid
            errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"Please fill in all the fields correctly"];
            [errorNoticeView show];
        }
        else {
            //Data is valid, so let's get deleting
            [self changeUserWithPOSTType:@"deleteAccount" email:self.deleteEmail.text unencryptedPassword:self.deletePassword.text newValue:@""];
        }
    }
}

- (void)changeUserWithPOSTType:(NSString *)type email:(NSString *)email unencryptedPassword:(NSString *)password newValue:(NSString *)newVariable {
    [self resignTextFields];
    //Encrypt password
    password = [TTSBrain hashString:password withSalt:TTSDatabaseSalt];
    //If we're changing the password, encrypt the new password too
    if ([type isEqualToString:@"password"])
        newVariable = [TTSBrain hashString:newVariable withSalt:TTSDatabaseSalt];
    //Creates our request with a URL and sets it to be $_POST
    NSURL *url = [NSURL URLWithString:@"http://hughbellamyapps.heliohost.org/Speak%20Easy/updateAccount.php"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:7.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    //Create our parameter and add it to our request
    NSString *paramString = [NSString stringWithFormat:@"type=%@&userID=%ld&email=%@&password=%@&new=%@", type, (long) [TTSBrain getUserID], email, password, newVariable];

    paramString = [paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];

    //Create and start a connection with our request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

    //Checks if we're successful
    if (connection) {
        //If we are, start the progress HUD and reset our data
        self.mutData = [NSMutableData data];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Loading";
    }
    else {
        //If not, notify the user of an unknown error
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
        [errorNoticeView show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //We've finished so we hide the HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

    //Now lets get our data in the form of a string
    NSString *str = [[NSString alloc] initWithData:self.mutData encoding:NSUTF8StringEncoding];
    NSString *formattedStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];

    //Check what our data means
    if ([formattedStr isEqualToString:@"i"] || [formattedStr isEqualToString:@""] || [formattedStr isEqualToString:@"mE"]) {
        //Something bad has happened, so lets notify the user
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Data" message:@"Please try again later."];
        [errorNoticeView show];
    }
    else if ([formattedStr isEqualToString:@"nSU"]) {
        //No Such User - id sent is not on record
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"No Such User" message:@"AN error occured - Error: nSU invalid userID for `id`='_!'"];
        [errorNoticeView show];
    }
    else if ([formattedStr isEqualToString:@"cE"]) {
        //Incorrect email
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"No Such User" message:@"The email address you entered does not match the email address on record"];
        [errorNoticeView show];
    }
    else if ([formattedStr isEqualToString:@"cP"]) {
        //Incorrect password
        errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Incorrect Password" message:@"Check your password and try again"];
        [errorNoticeView show];
    }
    else if ([formattedStr isEqualToString:@"cES"]) {
        //Changed Email Successfully
        [self resetTextViews];
        [TTSBrain loginWithEmail:email userID:[TTSBrain getUserID]];
        successNoticeView = [WBSuccessNoticeView successNoticeInView:self.tableView title:@"Email Changed"];
        [successNoticeView show];
    }
    else if ([formattedStr isEqualToString:@"cPS"]) {
        //Changed Password Successfully
        [self resetTextViews];
        successNoticeView = [WBSuccessNoticeView successNoticeInView:self.tableView title:@"Password Changed"];
        [successNoticeView show];
    }
    else if ([formattedStr isEqualToString:@"cNS"]) {
        [self resetTextViews];
        successNoticeView = [WBSuccessNoticeView successNoticeInView:self.tableView title:@"Name Changed"];
        [successNoticeView show];
    }
    else if ([formattedStr isEqualToString:@"cAD"]) {
        //Changed Account Deleted
        [self resetTextViews];
        self.tableView.userInteractionEnabled = NO;
        [TTSBrain writeBoolForKey:NO forKey:@"hasAccount"];
        successNoticeView = [WBSuccessNoticeView successNoticeInView:self.tableView title:@"Account Deleted"];
        [successNoticeView show];

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Logging Out";

        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(logout:) userInfo:nil repeats:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //If we failed, stop our progress HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    NSLog(@"%@", @"Error");
    //Then tell the user that something went wrong
    errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:@"Error Connecting" message:@"Check your network connection."];
    [errorNoticeView show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //We've started so lets reset our data
    [self.mutData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //As we get data downloaded, add
    [self.mutData appendData:data];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Checks if we've selected an item
    if (indexPath.row == selectedCellIndex) {
        //Depending on the cell we want to expand, change the height to suit the cell in question
        switch (selectedCellIndex) {
            case 0:
                return 240;
            case 1:
                return 200;
            case 2:
                return 195;
            case 3:
                return 175;
            default:
                return self.navigationController.navigationBar.frame.size.height + 1;
        }
    }
    else
        return self.navigationController.navigationBar.frame.size.height + 1; //If not, return a default value of a small cell
}

- (IBAction)cellTapped:(UIButton *)cell {
    NSInteger tag = cell.tag;
    if (tag != selectedCellIndex) {
        //Show the cell
        selectedCellIndex = tag;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

@end
