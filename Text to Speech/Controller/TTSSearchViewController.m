//
//  TTSSearchViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 22/10/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSSearchViewController.h"

#import "TTSInfoViewController.h"

@implementation TTSSearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //Create our array of users
    self.message = @"";
    self.users = [NSMutableArray new];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        self.errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.tableView title:@"Invalid Search" message:@"Try entering a user name"];
        [self.errorNoticeView show];
    }
    else {
        self.message = @"Loading...";
        NSString *paramString = [NSString stringWithFormat:@"?userName=%@", searchBar.text];

        paramString = [paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //Creates our request with a URL and sets it to be $_POST
        NSURL *url = [NSURL URLWithString:[@"http://hughbellamyapps.heliohost.org/Speak%20Easy/getUser.php" stringByAppendingString:paramString]];

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
            hud.label.text = @"Searching";
            self.message = @"Searching...";
            self.users = [[NSMutableArray alloc] init];
        }
        else {
            //If not, notify the user of an unknown error
            self.errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
            [self.errorNoticeView show];
        }
    }
    [searchBar resignFirstResponder];
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
        self.errorNoticeView = [WBErrorNoticeView errorNoticeInView:self.view title:@"Invalid Data" message:@"Please try again later."];
        [self.errorNoticeView show];
        self.message = NSLocalizedString(@"An Error Occurred", nil);
    }
    else if ([formattedStr isEqualToString:@"NU"]) {
        //Checks the scenario where we have no users
        self.message = @"No Users found";
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
                [self.users addObject:array];
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
    if (self.users.count == 0)
        return 1;
    return (NSInteger) self.users.count;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.users.count != 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (self.users.count == 0) {
        cell.tag = 0;
        cell.textLabel.text = self.message;
    }
    else {
        NSArray *userCellArray = self.users[(NSUInteger) indexPath.row];
        cell.tag = [userCellArray[0] integerValue];
        cell.textLabel.text = userCellArray[1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"toProfile" sender:@[@(cell.tag), cell.textLabel.text]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toProfile"]) {
        TTSInfoViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.ID = [sender[0] integerValue];
        destinationViewController.userName = sender[1];
    }
}
@end
