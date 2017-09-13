//
//  TTSBlockedUsersTableVewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 01/11/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBlockedUsersTableVewController.h"

#import "TTSBrain.h"

#import "MBProgressHUD.h"

@implementation TTSBlockedUsersTableVewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self update];
}

- (void)update {
    NSString *urlString = [NSString stringWithFormat:@"http://hughbellamyapps.heliohost.org/Speak Easy/getBlocked.php?userID=%ld", (long) [TTSBrain getUserID]];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //Creates our request with a URL and sets it to be $_GET
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    //Create and start a connection with our request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

    //Checks if we're successful
    if (connection) {
        //If we are, start the progress HUD and reset our data
        self.mutData = [NSMutableData data];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Loading";
        self.message = @"Loading...";
        self.blockedUsers = [NSMutableArray new];
    }
    else {
        //If not, notify the user of an unknown error
        self.errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
        [self.errorNoticeView show];
        self.message = NSLocalizedString(@"An Error Occurred", nil);
    }
}

#pragma mark - Table view data source

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
        self.errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:NSLocalizedString(@"Invalid Data", nil) message:NSLocalizedString(@"Try Again Later", nil)];
        [self.errorNoticeView show];
        self.message = NSLocalizedString(@"An Error Occurred", nil);
    }
    else if ([formattedStr isEqualToString:@"NBU"]) {
        //Checks the scenario where we have no users
        self.message = NSLocalizedString(@"No Blocked Users found", nil);
    }
    else if ([formattedStr isEqualToString:@"UB"]) {
        [self update];
    }
            //We've got data
    else {
        //Recreate our users array and parser
        //Our data is a list of jsonObjects {...} separated by |
        NSArray *arrayOfOurJSONObjects = [str componentsSeparatedByString:@"|"];

        //Now lets loop through our array of users
        for (NSUInteger i = 0; i < arrayOfOurJSONObjects.count; i++) {
            //Let's get the current jsonObject and parse it into an array
            NSString *jsonString = arrayOfOurJSONObjects[i];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if (dict) {
                NSMutableArray *array = [[NSMutableArray alloc] init];

                //Lets format the dictionary to the array

                [array addObject:dict[@"userID"]];
                [array addObject:dict[@"userName"]];

                //Add our formatted array to our main array
                [self.blockedUsers addObject:array];
            }
        }
    }
    //We're done here so let's reload our view's data
    [self.tableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //If we failed, stop our progress HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    //Then tell the user that something went wrong
    self.errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:@"Network Error" message:@"Check your network connection."];
    [self.errorNoticeView show];
    self.message = NSLocalizedString(@"An Error Occurred", nil);
    [self.tableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //We've started so lets reset our data
    [self.mutData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //As we get data downloaded, add
    [self.mutData appendData:data];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.blockedUsers.count == 0)
        return 1;
    return (NSInteger) self.blockedUsers.count;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.blockedUsers.count != 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (self.blockedUsers.count == 0) {
        cell.tag = 0;
        cell.textLabel.text = self.message;
        cell.accessoryView = nil;
    }
    else {
        NSArray *userCellArray = self.blockedUsers[(NSUInteger) indexPath.row];
        cell.textLabel.text = userCellArray[1];
        UIButton *label = [UIButton buttonWithType:UIButtonTypeSystem];
        [label setTitle:@"Unblock" forState:UIControlStateNormal];
        [label setFrame:CGRectMake(0, 0, 70, 30)];
        [label addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        label.tag = [userCellArray[0] integerValue];
        cell.accessoryView = label;
    }
    return cell;
}

- (void)buttonTapped:(UIButton *)button {
    NSString *urlString = @"http://hughbellamyapps.heliohost.org/Speak Easy/unblock.php";
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //Creates our request with a URL and sets it to be $_GET
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSString *paramString = [NSString stringWithFormat:@"userID=%ld&blockID=%ld", (long) [TTSBrain getUserID], (long) button.tag];
    paramString = [paramString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];

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
        hud.label.text = @"Unblocking";
        self.message = @"Unblocking...";
    }
    else {
        //If not, notify the user of an unknown error
        self.errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
        [self.errorNoticeView show];
        self.message = NSLocalizedString(@"An Error Occurred", nil);
    }
}
@end
