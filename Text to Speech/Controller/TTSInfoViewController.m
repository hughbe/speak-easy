//
//  TTSInfoViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 27/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSVoiceCell.h"
#import "WBErrorNoticeView.h"
#import "TTSInfoViewController.h"
#import "TTSReportViewController.h"

@implementation TTSInfoViewController

NSInteger const toIncrementEachLoad = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.message = @"Load More";
    //Hide our adView on load as it hasn't loaded yet
    self.adView.alpha = 0.0;
    //Checks if our view controller is offline or online viewing
    if ([self.title isEqualToString:@"offline"]) {
        //We're offline
        self.infoType = TTSPresetInfoTypeOffline;
        //Create the navController for our presseter (id=presetter)
        UINavigationController *presetterNavController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"presetter"];
        //Allocate our presetter view controller and tell it about self
        self.presetterController = (TTSPresetterViewController *) presetterNavController.topViewController;
        self.presetterController.motherControllerInfo = self;
        CGSize size = self.view.frame.size;
        self.presetterController.preferredContentSize = size;
        //Create the popover controller and change its size to the largest possible

        self.presetterPopover = [[WYPopoverController alloc] initWithContentViewController:presetterNavController];
        self.presetterPopover.delegate = self;
    }
    else {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];

        self.presets = [NSMutableArray new];
        //We're online so lets get started working online!
        self.infoType = TTSPresetInfoTypeOnline;

        //Create the navController for our presseter (id=presetter)
        UINavigationController *presetterNavController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"presetter"];
        //Allocate our presetter view controller and tell it about self
        self.presetterController = (TTSPresetterViewController *) presetterNavController.topViewController;
        self.presetterController.motherControllerInfo = self;
        CGSize size = self.view.frame.size;
        self.presetterController.preferredContentSize = size;
        //Create the popover controller and change its size to the largest possible

        self.presetterPopover = [[WYPopoverController alloc] initWithContentViewController:presetterNavController];

        if (!self.ID || self.ID == [TTSBrain getUserID]) {
            self.ID = [TTSBrain getUserID];
            self.userName = @"My Presets";
        }

        if ([self.title isEqualToString:@"online"])
            self.onlineType = TTSPresetOnlineTypeGeneral;
        else if ([self.title isEqualToString:@"profile"]) {
            self.onlineType = TTSPresetOnlineTypeProfile;
            self.navigationItem.title = self.userName;
            if (self.ID != [TTSBrain getUserID]) {
                [self.profileOptionsButton setTitle:@"" forState:UIControlStateNormal];
                [self.profileOptionsButton setImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
            }
        }
        else {
            self.onlineType = TTSPresetOnlineTypeSingle;
            self.navigationItem.title = @"Preset";
        }
        [self update];
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    self.currentlyViewing = 0;
    [self.presets removeAllObjects];
    [self.tableView reloadData];
    self.message = @"Loading...";
    [self update];
    [refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //We've loaded so reload the data
    if (self.infoType == TTSPresetInfoTypeOffline)
        [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.currentlyViewing = self.presets.count;
    //Check's if we're logged in
    if (self.infoType == TTSPresetInfoTypeOnline && ![TTSBrain loggedIn] && !self.canceled) {
        [self performSegueWithIdentifier:@"toLogin" sender:nil];
    }
    else if (self.canceled) {
        self.canceled = NO;
        [self performSegueWithIdentifier:@"unwindPresets" sender:nil];
    }
    else if (self.infoType == TTSPresetInfoTypeOnline && self.sharePresetArray) {
        self.presetterController.presetArray = self.sharePresetArray;
        self.presetterController.taskType = TTSPresetTaskTypeShare;
        [self.presetterController reload];
        [self.presetterPopover presentPopoverFromBarButtonItem:self.addBarButtonItem permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.sharePresetArray = nil;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    //Animates hiding the banner if the and ad failed to load
    if (self.bannerIsVisible) {
        [UIView animateWithDuration:0.4 animations:^{
            self.adView.alpha = 0.0;
        }];
        self.bannerIsVisible = NO;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    //Animates showing the banner if an add is loaded
    if (!self.bannerIsVisible) {
        [UIView animateWithDuration:0.4 animations:^{
            self.adView.alpha = 1.0;
        }];
        self.bannerIsVisible = YES;
    }
}

- (IBAction)unwindPresets:(UIStoryboardSegue *)unwindSegue {
    //Sets up our unwindToPresets segue
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Checks what we're segueing to
    if ([segue.identifier isEqualToString:@"toLogin"]) {
        //Sets up a delegate for our userActionsViewController to receive cancellation message
        UINavigationController *navigationController = segue.destinationViewController;
        TTSShareViewController *shareViewController = navigationController.viewControllers[0];
        shareViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"share"]) {
        //By default, and select My Profile as we don't want to go Back immediately
        UITabBarController *tabBarController = segue.destinationViewController;
        tabBarController.selectedIndex = 2;
        UINavigationController *navigationController = tabBarController.viewControllers[2];
        TTSInfoViewController *viewController = navigationController.viewControllers[0];
        viewController.sharePresetArray = sender;
    }
    else if ([segue.identifier isEqualToString:@"goOnline"]) {
        //By default, the online home as we don't want to go Back immediately
        UITabBarController *tabBarController = segue.destinationViewController;
        tabBarController.selectedIndex = 1;
    }
    else if ([segue.identifier isEqualToString:@"toProfile"]) {
        UIButton *button = sender;
        TTSInfoViewController *profileViewController = segue.destinationViewController;
        profileViewController.ID = button.tag;
        profileViewController.userName = button.titleLabel.text;
    }
    else if ([segue.identifier isEqualToString:@"toReport"]) {
        TTSReportViewController *reporter = segue.destinationViewController;
        reporter.ID = [[sender objectAtIndex:0] integerValue];
        reporter.string = [sender objectAtIndex:1];
        if ([[sender objectAtIndex:2] isEqualToString:@"preset"]) {
            reporter.reportType = TTSReportPreset;
        }
        else {
            reporter.reportType = TTSReportUser;
        }
    }
}

- (void)userActionsDidCancel {
    //If we canceled logging in, tell this viewController that so that we prevent the sign in popover from appearing infinitely
    self.canceled = YES;
}

- (void)update {
    [self.connection cancel];
    //Sets up our type parameter depending on what we want to do
    self.loading = YES;
    NSString *paramValue;
    if (self.onlineType == TTSPresetOnlineTypeSingle) {
        paramValue = @"single";
    }
    else if (self.segmentedController.selectedSegmentIndex == 0) {
        paramValue = @"mostDownloaded";
    }
    else if (self.segmentedController.selectedSegmentIndex == 1) {
        paramValue = @"topRated";
    }
    else {
        paramValue = @"mostRecent";
    }

    //Create our parameter and add it to our request
    NSString *paramString = [NSString stringWithFormat:@"?type=%@&myID=%ld&limitStart=%ld", paramValue, (long) [TTSBrain getUserID], (long) self.currentlyViewing];
    if (self.onlineType != TTSPresetOnlineTypeGeneral
            ) {
        paramString = [paramString stringByAppendingFormat:@"&id=%ld", (long) self.ID];
    }

    paramString = [paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //Creates our request with a URL and sets it to be $_GET
    NSURL *url = [NSURL URLWithString:[@"http://hughbellamyapps.heliohost.org/Speak%20Easy/getPreset.php" stringByAppendingString:paramString]];

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
        if (self.onlineType == TTSPresetOnlineTypeSingle) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"Loading";
        }
        else {
            self.message = @"Loading...";
        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger) self.presets.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        //If not, notify the user of an unknown error
        self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
        self.notice.sticky = YES;
        [self.notice show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.loading = NO;
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
        self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Invalid Data" message:@"Please try again later."];
        self.notice.sticky = YES;
        [self.notice show];
    }
    else if ([formattedStr isEqualToString:@"InternalServerError(ErrorCode500)\n\n500\n<!--\n-->\n"]) {
        if (self.onlineType == TTSPresetOnlineTypeSingle) {
            self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Internal Server Error" message:@"Please try again later."];
            self.notice.sticky = YES;
            [self.notice show];
        }
        else {
            self.message = @"Internal Server Error";
        }
    }
    else if ([formattedStr isEqualToString:@"NP"]) {
        if (self.onlineType == TTSPresetOnlineTypeSingle) {
            self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Preset not found" message:@"Check the link you've been given"];
            self.notice.sticky = YES;
            [self.notice show];
        }       //Checks the scenario where we have no presets
        else if (self.onlineType == TTSPresetOnlineTypeProfile && self.currentlyViewing == 0) {
            //If we are on profile mode, but the user has no presets
            self.message = @"User has no presets";
        }
        else if (self.onlineType == TTSPresetOnlineTypeProfile) {
            //If we are on profile mode but there are no more presets to load
            self.message = @"User has no more presets";
        }
        else if (self.currentlyViewing == 0) {
            //We are on general mode, but there are no presets at all on the DB
            self.message = @"No presets to show";
        }
        else {
            //We are on general mode, but there are no presets at all on the DB
            self.message = @"No more presets to show";
        }
    }
    else if ([formattedStr isEqualToString:@"d"]) {
        //We've deleted the preset, so remove the preset from our array
        [self.presets removeObjectAtIndex:(NSUInteger) self.path.row];
        //Now start deleting the preset from the tableView and reload the tableView to maintain correct *row* values
        self.currentlyViewing--;
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[self.path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [self.tableView reloadData];
    }
    else if ([formattedStr isEqualToString:@"B"]) {
        //User is blocked
        self.message = @"User is blocked";
        self.blocked = YES;
    }
    else if ([formattedStr isEqualToString:@"UB"]) {
        //User is unblocked
        self.blocked = NO;
        [self refresh:nil];
    }
    else if ([formattedStr isEqualToString:@"BD"]) {
        //We've blocked the user
        //Loop through all our cells hiding them
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:0] - 1; i++) {
            uint lowerBound = 1;
            uint upperBound = 4;
            uint rndValue = lowerBound + arc4random() % (upperBound - lowerBound);

            UITableViewRowAnimation animation;
            if (rndValue == 1) {
                animation = UITableViewRowAnimationLeft;
            }
            else if (rndValue == 2) {
                animation = UITableViewRowAnimationBottom;
            }
            else if (rndValue == 3) {
                animation = UITableViewRowAnimationRight;
            }
            else {
                animation = UITableViewRowAnimationTop;
            }
            [self.presets removeObjectAtIndex:0];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:animation];
            [self.tableView endUpdates];
        }
        self.message = @"User Blocked!";
        self.blocked = YES;
        [self.tableView reloadData];
    }
            //We've got data
    else {
        //Recreate our presets array and parser
        //self.presets = [[NSMutableArray alloc] init];
        //Our data is a list of jsonObjects {...} separated by |
        NSArray *arrayOfOurJSONObjects = [str componentsSeparatedByString:@"|"];

        //Now lets loop through our
        for (NSUInteger i = 0; i < arrayOfOurJSONObjects.count; i++) {
            //Let's get the current jsonObject and parse it into an array
            NSString *jsonString = arrayOfOurJSONObjects[i];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if (dict) {
                NSMutableArray *array = [NSMutableArray new];
                //Lets format the array's numbers stored as strings to numbers
                NSNumber *speedNumber = @([(NSString *) dict[@"speed"] floatValue]);
                NSNumber *pitchNumber = @([(NSString *) dict[@"pitch"] floatValue]);
                NSNumber *downloadsNumber = @([(NSString *) dict[@"downloads"] integerValue]);
                NSNumber *ratingNumber = @([(NSString *) dict[@"rating"] integerValue]);

                NSString *dateAdded = dict[@"dateAdded"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *formattedDate = [dateFormatter dateFromString:dateAdded];
                NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
                [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *dateAddedFormatted = [dateFormatter2 stringFromDate:formattedDate];
                NSNumber *rated = dict[@"rated"];

                //Now add the following objects in order
                [array addObject:dict[@"id"]];
                [array addObject:dict[@"voice"]];
                [array addObject:speedNumber];
                [array addObject:pitchNumber];
                [array addObject:dict[@"text"]];
                [array addObject:dateAddedFormatted];
                [array addObject:downloadsNumber];
                [array addObject:ratingNumber];
                [array addObject:dict[@"author"]];
                [array addObject:rated];
                [array addObject:dict[@"authorName"]];

                //Add our formatted array to our main array
                if (self.onlineType == TTSPresetOnlineTypeSingle) {
                    self.presets = [@[array] mutableCopy];
                }
                else {
                    [self.presets addObject:array];
                }
            }
        }
        self.currentlyViewing = self.presets.count;
        if (arrayOfOurJSONObjects.count < toIncrementEachLoad) {
            //Checks the scenario where we have no presets
            if (self.onlineType == TTSPresetOnlineTypeProfile && self.currentlyViewing == 0) {
                //If we are on profile mode, but the user has no presets
                self.message = @"User has no presets";
            }
            else if (self.onlineType == TTSPresetOnlineTypeProfile) {
                //If we are on profile mode but there are no more presets to load
                self.message = @"User has no more presets";
            }
            else if (self.currentlyViewing == 0) {
                //We are on general mode, but there are no presets at all on the DB
                self.message = @"No presets to show";
            }
            else {
                //We are on general mode, but there are no presets at all on the DB
                self.message = @"No more presets to show";
            }
        }
        else {
            self.message = @"Load More";
        }
    }
    //We're done here so let's reload our view's data
    [self reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //If we failed, stop our progress HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    self.loading = NO;
    //Then tell the user that something went wrong
    self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Network Error" message:@"Check your network connection."];
    self.notice.sticky = YES;
    [self.notice show];
    self.message = @"Can't Connect";
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

#pragma mark - Table View delegate methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.infoType == TTSPresetInfoTypeOnline && !self.loading && self.onlineType != TTSPresetOnlineTypeSingle) {
        //When reaching bottom, load more
        CGFloat offs = (targetContentOffset->y + scrollView.  bounds.size.height);
        CGFloat val = (scrollView.contentSize.height);
        if (offs == val) {
            //Now update our data
            [self update];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.infoType == TTSPresetInfoTypeOffline) {
        //Title for section 0 is Current Preset, section 1 is Other Presets
        if (section == 0) {
            return @"Current Preset";
        }
        else if (self.presets.count > 0) {
            return @"Other Presets";
        }
        else {
            return nil;
        }
    }
    else if (self.onlineType == TTSPresetOnlineTypeGeneral) {
        return @"Online Presets";
    }
    else if (self.onlineType == TTSPresetOnlineTypeSingle) {
        return @"Preset:";
    }
    else {
        return self.userName;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Section 0 will have 1 cell (current view)
    if (section == 0 && self.infoType == TTSPresetInfoTypeOffline) {
        return 1;
    }
    //Section 1 will return the number of presets the user has
    if (self.infoType == TTSPresetInfoTypeOffline || self.onlineType == TTSPresetOnlineTypeSingle) {
        return (NSInteger) self.presets.count;
    }
    //If we're online, add on an extra cell for the info cell at the bottom
    return (NSInteger) self.presets.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.infoType == TTSPresetInfoTypeOffline) {
        if (self.presets.count == 0) {
            return 1;
        }
        else {
            return 2;//We have two sections in our table if we're offline
        }
    }
    else if (self.onlineType == TTSPresetOnlineTypeSingle) {
        if (self.presets.count == 0) {
            return 0;
        }
        else {
            return 1;
        }
    }
    else
        return 1; //When online we have one section
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //Checks if we tapped the bottom (load more) cell
    if ((NSUInteger) indexPath.row == self.presets.count) {
        //We tapped the bottom
        if (!self.loading) {
            [self update];
        }
    }
    else {
        //Get the tapped cell and reduce its height to the default
        self.selectedCell.defaultTextLabel.numberOfLines = 1;
        self.selectedCell.defaultTextLabel.lineBreakMode = NSLineBreakByClipping;
        CGRect rect = self.selectedCell.defaultTextLabel.frame;
        rect.size.height = self.selectedCell.voiceLabel.frame.size.height;
        self.height = rect.size.height;
        [self.selectedCell.defaultTextLabel setFrame:rect];
        
        //Get the tapped cell
        self.selectedCell = (TTSVoiceCell *) [tableView cellForRowAtIndexPath:indexPath];
        //Prepare our cell's textLabel for expansion
        self.selectedCell.defaultTextLabel.numberOfLines = 0;
        self.selectedCell.defaultTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.selectedIndexPath = indexPath;
        //...And expand the label showing the text value
        [self.selectedCell.defaultTextLabel sizeToFit];
        self.height = self.selectedCell.defaultTextLabel.frame.size.height;
        //Now refresh the tableView's layout
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((NSUInteger) indexPath.row != self.presets.count) {
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger size;
    if ((NSUInteger) indexPath.row == self.presets.count && self.infoType == TTSPresetInfoTypeOnline && self.onlineType != TTSPresetOnlineTypeSingle) {
        return 50;
    }
    if (self.infoType == TTSPresetInfoTypeOffline)
        size = 149;
    else
        size = 189;
    //Expand the tableViewCell if we want to show the full text value
    if (self.selectedIndexPath && indexPath.row == self.selectedIndexPath.row && indexPath.section == self.selectedIndexPath.section)
        return self.height + size - 26;
    else
        return size; //If not, return the default value for our tableViewCellHeight
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Dequeue our cell with id="Cell"
    static NSString *cellIdentifier = @"Cell";
    TTSVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSUInteger row = (NSUInteger) indexPath.row;
    NSInteger section = indexPath.section;
    cell.row = row;
    cell.section = section;
    cell.motherController = self;
    if (self.infoType == TTSPresetInfoTypeOffline) {
        //Checks what section the new cell is in
        if (section == 1 && row < self.presets.count) {
            //If we're in the content section and there is a valid amount of data, load the preset array for our new cell
            cell.makeCurrentButton.hidden = NO;
            cell.makeCurrentButton.enabled = YES;
            NSArray *presetArray = (self.presets)[row];
            cell.presetArray = [presetArray mutableCopy];
            //Sets it unique ID, formatted voice, speed, pitch and text
            cell.presetID = presetArray[0];
            cell.voiceLabel.text = [TTSBrain formatReadableStringFromLocaleString:presetArray[1]];

            float speed = [presetArray[2] floatValue];
            float pitch = [presetArray[3] floatValue];

            cell.speedLabel.text = [NSString stringWithFormat:@"%.02f", speed];
            cell.pitchLabel.text = [NSString stringWithFormat:@"%.02f", pitch];

            [cell.defaultTextLabel setText:presetArray[4]];
        }
        else if (indexPath.section == 0) {
            //If we're in the first section, load the current formatted voice, speed and pitch
            cell.makeCurrentButton.hidden = YES;
            cell.makeCurrentButton.enabled = NO;
            cell.presetID = @0;
            cell.languageID = [TTSBrain getStringForKey:@"language" defaultValue:@"en-GB"];
            CGFloat rate = [TTSBrain getFloatForKey:@"rate" defaultValue:AVSpeechUtteranceDefaultSpeechRate];
            CGFloat pitch = [TTSBrain getFloatForKey:@"pitch" defaultValue:1.0];
            NSString *defaultText = [TTSBrain getStringForKey:@"defaultText" defaultValue:@"Not set"];

            cell.voiceLabel.text = [TTSBrain formatReadableStringFromLocaleString:cell.languageID];
            cell.speedLabel.text = [NSString stringWithFormat:@"%.02f", rate];
            cell.pitchLabel.text = [NSString stringWithFormat:@"%.02f", pitch];
            [cell.defaultTextLabel setText:defaultText];
            cell.presetArray = [@[cell.languageID, @(rate), @(pitch), defaultText] mutableCopy];
        }
    }
    else if ((NSUInteger) indexPath.row == self.presets.count) {
        TTSBottomCell *bottomCell = [tableView dequeueReusableCellWithIdentifier:@"Bottom" forIndexPath:indexPath];
        bottomCell.infoLabel.text = self.message;
        return bottomCell;
    }
    else {
        //Setup our online viewController's cell
        NSArray *presetArray = self.presets[row];
        cell.presetArray = [presetArray mutableCopy];
        //Gets necessary values and formats them for display in our online cell
        cell.presetID = presetArray[0];
        cell.voiceLabel.text = [TTSBrain formatReadableStringFromLocaleString:presetArray[1]];

        float speed = [presetArray[2] floatValue];
        float pitch = [presetArray[3] floatValue];
        cell.downloads = [presetArray[6] integerValue];
        cell.rating = [presetArray[7] integerValue];
        NSString *ratingsString = [NSString stringWithFormat:@"+%ld", (long) cell.rating];

        //Sets the relevant display labels and variables to the applicable values from our presetArray
        cell.speedLabel.text = [NSString stringWithFormat:@"%.02f", speed];
        cell.pitchLabel.text = [NSString stringWithFormat:@"%.02f", pitch];

        [cell.defaultTextLabel setText:presetArray[4]];
        cell.createdDateLabel.text = presetArray[5];
        cell.downloadsLabel.text = [NSString stringWithFormat:@"%ld downloads", (long) cell.downloads];
        cell.ratingLabel.text = ratingsString;
        cell.rated = presetArray[9];
        cell.voteUpButton.highlighted = [cell.rated isEqual:@1];
        cell.authorValue.tag = [presetArray[8] integerValue];
        [cell.authorValue setTitle:presetArray[10] forState:UIControlStateNormal];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.infoType == TTSPresetInfoTypeOffline) {
        //Section 0 can't be edited, but the section 1 can be
        return indexPath.section != 0;
    }
    else if ((NSUInteger) indexPath.row != self.presets.count) {
        TTSVoiceCell *cell = (TTSVoiceCell *) [tableView cellForRowAtIndexPath:indexPath];
        return cell.authorValue.tag == [TTSBrain getUserID]; //Online presets can't be deleted!
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.infoType == TTSPresetInfoTypeOffline) {
        //Checks if we're deleting a cell
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            //Remove the current data point from our array
            [self.presets removeObjectAtIndex:(NSUInteger) indexPath.row];

            //Now, delete the cell from the table view
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            if (self.presets.count == 0) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [tableView endUpdates];
            //Finally, overwrite our old preset array with the new one in userDefaults
            [TTSBrain write:self.presets forKey:TTSPresetKey];
            [tableView reloadData];
        }
    }
    else {
        //Get the cell we're removing
        TTSVoiceCell *voiceCell = (TTSVoiceCell *) [tableView cellForRowAtIndexPath:indexPath];
        self.path = indexPath;
        NSInteger authorID = voiceCell.authorValue.tag;
        //Makes sure this is our own preset
        if (authorID == [TTSBrain getUserID]) {
            //Start a connection to delete our preset
            //Creates our request with a URL and sets it to be $_POST
            NSURL *url = [NSURL URLWithString:@"http://hughbellamyapps.heliohost.org/Speak%20Easy/deletePreset.php"];

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

            //Create our parameter and add it to our request
            NSString *paramString = [NSString stringWithFormat:@"authorID=%ld&presetID=%@", (long) [TTSBrain getUserID], voiceCell.presetID];

            NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];

            //Create and start a connection with our request
            self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [self.connection start];

            //Checks if we're successful
            if (self.connection) {
                //If we are, start the progress HUD and reset our data
                self.mutData = [NSMutableData data];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.label.text = @"Deleting";
            }
            else {
                //If not, notify the user of an unknown error
                self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
                self.notice.sticky = YES;
                [self.notice show];
            }
        }
    }
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    //We know the preset array has changed, so reload our data
    [self reloadData];
}

- (void)reloadData {
    //Reload the presets array and the reloads the table view
    if (self.infoType == TTSPresetInfoTypeOffline) {
        [self.presets removeAllObjects];
        self.presets = [[TTSBrain getArrayForKey:TTSPresetKey] mutableCopy];
    }
    [self.tableView reloadData];
}

- (IBAction)changeViewingType:(UISegmentedControl *)sender {
    //Hide any notice that may be displayed
    self.currentlyViewing = 0;
    self.notice.delay = 0.0;
    [self.notice dismissNotice];
    //Remove all current entries from our tableView
    [self.presets removeAllObjects];
    [self.tableView reloadData];
    //Now download the updated data
    [self update];
}

- (IBAction)newPreset:(UIButton *)sender {
    if (self.infoType == TTSPresetInfoTypeOffline) {
        //Open the presetter and tell it we're making a new preset
        self.presetterController.taskType = TTSPresetTaskTypeNew;
        [self.presetterController reload];
        [self.presetterPopover presentPopoverAsDialogAnimated:YES];
    }
    else if (self.ID == [TTSBrain getUserID]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.userName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Preset", @"Share", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    else {
        NSString *blockUnblock;
        if (self.blocked) {
            blockUnblock = @"Unblock";
        }
        else {
            blockUnblock = @"Block";
        }
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.userName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:blockUnblock, @"Share", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex&&self.ID != [TTSBrain getUserID]) {
        //Reporting
        [self performSegueWithIdentifier:@"toReport" sender:@[@(self.ID), self.userName, @"user"]];
    }
    else if (buttonIndex == 1 && self.ID != [TTSBrain getUserID]) {
        //Blocking
        NSString *unBlock = @"";
        if (self.blocked) {
            unBlock = @"un";
        }
        NSURL *url = [NSURL URLWithString:[[@"http://hughbellamyapps.heliohost.org/Speak%20Easy/" stringByAppendingString:unBlock] stringByAppendingString:@"block.php"]];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

        //Create our parameter and add it to our request
        NSString *paramString = [NSString stringWithFormat:@"userID=%ld&blockID=%ld", (long) [TTSBrain getUserID], (long) self.ID];

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
            if (self.blocked) {
                hud.label.text = @"Unblocking";
            }
            else {
                hud.label.text = @"Blocking";
            }
        }
        else {
            //If not, notify the user of an unknown error
            self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
            self.notice.sticky = YES;
            [self.notice show];
        }
    }
    else if((buttonIndex == 0 && self.ID == [TTSBrain getUserID])) {
        self.presetterController.taskType = TTSPresetTaskTypeShare;
        self.presetterController.shouldLoadCurrent = YES;
        [self.presetterController reload];
        [self.presetterPopover presentPopoverFromBarButtonItem:self.addBarButtonItem permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
    }
    else if ((buttonIndex == 2 && self.ID != [TTSBrain getUserID])||(buttonIndex == 1 && self.ID == [TTSBrain getUserID])) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Generating Link";
        
        NSString *type = @"";
        if(self.onlineType == TTSPresetOnlineTypeSingle) {
            type = @"P";
        }
        else {
            type = @"U";
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showShareOptions:) userInfo:@[@(self.ID), type] repeats:NO];
    }
}

-(void)showShareOptions:(NSTimer*)timer {
    
    //We've finished so we hide the HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

    
    NSString *shareURL = [[NSString stringWithFormat:@"http://hughbellamyapps.helihost.org/Speak Easy/get.php?id=%@", timer.userInfo[0]] stringByAppendingString:timer.userInfo[1]];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:@[shareURL] applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}
@end
