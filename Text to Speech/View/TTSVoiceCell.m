//
//  TTSVoiceCell.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBrain.h"
#import "TTSVoiceCell.h"
#import "WBErrorNoticeView.h"
#import "TTSInfoViewController.h"

@implementation TTSVoiceCell
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    //We're not playing, so show the play icon
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    //We're not playing, so show the play icon
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    //We're playing, so show the stop icon and stop the queueing animation
    self.animating = NO;
    [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
}

- (AVSpeechSynthesizer *)speechSynthesizer {
    //Lazily instantiates our speechSynthesizer and sets its delegate
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
    }
    return _speechSynthesizer;
}

- (TTSSpeechUtterance *)utterance {
    //Lazily instantiates our speechUtterance with some default text
    if (!_utterance)
        _utterance = (TTSSpeechUtterance *) [[TTSSpeechUtterance alloc] initWithString:@"This is an example of this preset"];
    return _utterance;
}


- (void)spinWithOptions:(UIViewAnimationOptions)options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:options
                     animations:^{
                         if (self.animating)
                             self.playButton.transform = CGAffineTransformRotate(self.playButton.transform, (CGFloat) M_PI / 2);
                         else
                             self.playButton.transform = CGAffineTransformIdentity;

                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             if (self.animating)
                                     // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions:UIViewAnimationOptionCurveLinear];
                             else if (options != UIViewAnimationOptionCurveEaseOut)
                                     // one last spin, with deceleration
                                 self.playButton.transform = CGAffineTransformIdentity;
                         }
                     }];
}

- (IBAction)actionChosen:(id)sender {
    //Gets which button was pressed and the variables assigned to said labels
    NSInteger index;
    if ([sender isKindOfClass:[UIBarButtonItem class]])
        index = ((UIBarButtonItem *) sender).tag;
    else
        index = ((UIButton *) sender).tag;

    NSUInteger row = self.row;
    NSInteger section = self.section;
    //Find out which button was pressed
    if (index == 1) {
        if (section == 0 && !self.authorValue) {
            //Creates an utterance from our current preset
            self.utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:[TTSBrain getStringForKey:@"language" defaultValue:@"en-GB"]];
            self.utterance.rate = [TTSBrain getFloatForKey:@"rate" defaultValue:AVSpeechUtteranceDefaultSpeechRate];
            self.utterance.pitchMultiplier = [TTSBrain getFloatForKey:@"pitch" defaultValue:1.0];
            self.utterance.speechString = [TTSBrain getStringForKey:@"defaultText" defaultValue:@"Not Set"];
        }
        else {
            //Creates an utterance from the selected preset
            self.utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:(self.presetArray)[1]];
            self.utterance.rate = [(self.presetArray)[2] floatValue];
            self.utterance.pitchMultiplier = [(self.presetArray)[3] floatValue];
            self.utterance.speechString = (self.presetArray)[4];
        }

        //Checks if we're speaking
        if (self.speechSynthesizer.isSpeaking)
                //If we are, stop
            [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        else {
            //Star our queueing animation
            [self.playButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
            //Animate play button to "loading"
            if (!self.animating) {
                self.animating = YES;
                [self spinWithOptions:UIViewAnimationOptionCurveEaseIn];
            }
            //Then queue our speechUtterance
            [self.speechSynthesizer speakUtterance:self.utterance];
        }
    }
    else if (index == 2) {
        //Edit preset
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger) row inSection:section];
        [self.motherController tableView:self.motherController.tableView didDeselectRowAtIndexPath:indexPath];
        //Checks if we're editing a custom preset or our current one
        if (section == 0)
            self.motherController.presetterController.taskType = TTSPresetTaskTypeCurrent;
        else
            self.motherController.presetterController.taskType = TTSPresetTaskTypeEdit;
        //Provides the controller with data and reloads it's contents
        self.motherController.presetterController.index = row;
        [self.motherController.presetterController reload];

        //Shows the popover
        [self.motherController.presetterPopover presentPopoverAsDialogAnimated:YES];
    }
    else if (index == 3) {
        //Preliminary connection check
        if ([TTSBrain connected]) {
            //We're sharing our preset
            if (section == 0) {
                //Get our current values
                NSNumber *idValue = @0;

                NSString *languageID = [TTSBrain getStringForKey:@"language" defaultValue:@"en-GB"];

                NSNumber *speedValue = @([TTSBrain getFloatForKey:@"rate" defaultValue:AVSpeechUtteranceDefaultSpeechRate]);

                NSNumber *pitchValue = @([TTSBrain getFloatForKey:@"pitch" defaultValue:1.0]);

                NSString *text = [TTSBrain getStringForKey:@"text" defaultValue:@""];

                //Format: ID, Language ID, speed, pitch and text
                self.presetArray = [@[idValue, languageID, speedValue, pitchValue, text] mutableCopy];
            }
            //We're sharing a saved preset
            [self.motherController performSegueWithIdentifier:@"share" sender:self.presetArray];
        }
        else {
            //We have no connection, so tell the user this
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.motherController.view title:@"Network Error" message:@"Check your network connection."];
            [notice show];
        }
    }
    else if (index == 8) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Make Current" delegate:self cancelButtonTitle:@"NO" destructiveButtonTitle:Nil otherButtonTitles:@"YES", nil];
        sheet.tag = 1;
        [sheet showFromRect:self.frame inView:self animated:YES];
    }
    else if (index == 4) {
        //Checks if we're logged in
        if ([TTSBrain loggedIn]) {
            //Ask user whether they want to add this to their preset library
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Add to preset library" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"YES", nil];
            sheet.tag = 0;
            [sheet showFromRect:self.frame inView:self animated:YES];
        }
        else {
            [self showLoginMessage];
        }
    }
    else if (index == 5) {
        //Checks if we're logged in
        if ([TTSBrain loggedIn]) {
            //Preliminary internet check
            if ([TTSBrain connected]) {
                [self update:@"rate"];
            }
            else {
                [self showErrorMessage];
            }
        }
        else {
            [self showLoginMessage];
        }
    }
    else if (index == 7) {
        NSString *destructiveTitle = @"Report";
        if (self.authorValue.tag == [TTSBrain getUserID]) {
            destructiveTitle = @"Delete";
        }

        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveTitle otherButtonTitles:@"Share", nil];
        sheet.tag = 2;
        [sheet showFromRect:self.frame inView:self animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Checks which action sheet we're dealing with
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            //Checks if we have internet connection
            if ([TTSBrain connected]) {
                //We've confirmed downloading, so get started
                [self update:@"download"];
            }
            else {
                //No connection, notify the user
                [self showErrorMessage];
            }
        }
    }
    else if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            //We're making this our current preset
            //Firstly, get the current preset that we're swapping with
            NSArray *currentPreset = @[[TTSBrain getNewIDAndUpdate:YES], [TTSBrain getStringForKey:@"language" defaultValue:@"en-GB"], @([TTSBrain getFloatForKey:@"rate" defaultValue:AVSpeechUtteranceDefaultSpeechRate]), @([TTSBrain getFloatForKey:@"pitch" defaultValue:0.50f]), [TTSBrain getStringForKey:@"defaultText" defaultValue:@"Not Set"]];

            //Now load our list of custom presets
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *array = [[defaults objectForKey:TTSPresetKey] mutableCopy];
            //Now add the swapped on to the least and remove us from it
            [array addObject:currentPreset];
            [array removeObject:self.presetArray];
            //Now synchronize
            [defaults setObject:array forKey:TTSPresetKey];
            //Now that we no longer exist on the custom presets, add our data to our current preset and save all our changes
            [defaults setObject:self.presetArray[1] forKey:@"language"];
            [defaults setFloat:[self.presetArray[2] floatValue] forKey:@"rate"];
            [defaults setFloat:[self.presetArray[3] floatValue] forKey:@"pitch"];
            [defaults setObject:self.presetArray[4] forKey:@"defaultText"];
            [defaults synchronize];

            //Now that we've done that, refresh our motherController's tableView with our new data
            self.motherController.presets = array;
            [self.motherController.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            [self.motherController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger) self.row inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
    else if (actionSheet.tag == 2) {
        //We're showing more options, so check which button we've pressed
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            //Checks if we're reporting or deleting
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report"]) {
                //We're reporting so pass on our preset ID and open the reporting view
                [self.motherController performSegueWithIdentifier:@"toReport" sender:@[self.presetID, self.defaultTextLabel.text, @"preset"]];
            }
            else {
                //We're deleting so pass that on to our motherController's tableView
                [self.motherController tableView:self.motherController.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[self.motherController.tableView indexPathForCell:self]];
            }
        }
        else if (buttonIndex == 1) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.motherController.view animated:YES];
            hud.label.text = @"Generating Link";
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self.motherController selector:@selector(showShareOptions:) userInfo:@[self.presetID, @"P"] repeats:NO];
        }
    }
}

- (void)update:(NSString *)type {
    //Create a POST request for our updatePreset URL
    NSURL *url = [NSURL URLWithString:@"http://hughbellamyapps.heliohost.org/Speak%20Easy/updatePreset.php"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];

    //Setup our parameters, type ('download' or 'rate') presetID and our userID and adds the parameters to our request
    NSInteger idInteger = [self.presetArray[0] integerValue];

    NSString *paramString = [NSString stringWithFormat:@"type=%@&id=%ld&userID=%ld", type, (long) idInteger, (long) [TTSBrain getUserID]];

    NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];

    //Start our connection for this request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

    //Checks if we had success creating this connection
    if (connection) {
        //If so, reset our data and show the loading HUD
        self.downloadedData = [[NSMutableData alloc] init];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.motherController.view animated:YES];
        hud.label.text = @"Updating";
    }
    else {
        [self showErrorMessage]; //Tells the user that there was a problem
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //If we failed, tell the user and hide the HUD
    [self hideHUD];
    [self showErrorMessage];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //We loaded, so lets stop the HUD and format our received data
    [self hideHUD];
    NSString *str = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];

    if ([str isEqualToString:@"i"] || [str isEqualToString:@"mysql_error"] || [str isEqualToString:@""])
        [self showErrorMessage]; //Invalid data/an error occurred
    else if ([str isEqualToString:@"d"] || [str isEqualToString:@"dNI"]) {
        //We downloaded this preset
        //So add 1 to our download number
        if ([str isEqualToString:@"d"]) {
            NSInteger newDownloadInteger = [self.presetArray[6] integerValue] + 1;
            NSNumber *newDownloadNumber = @(newDownloadInteger);

            //Update our current preset number in our preset array
            self.presetArray[6] = newDownloadNumber;
            //Update the main controller's presets array and reload the controller's tableView
            self.motherController.presets[self.row] = self.presetArray;
            [self.motherController reloadData];
        }
        //ADDING OF PRESET OCCURS HERE

        //Create a copy of this preset
        NSMutableArray *adaptedPresetArray = [self.presetArray mutableCopy];
        //Lets remove unnecessary details (author, rating, downloads and dateCreated)
        for (NSInteger i = 0; i <= 3; i++)
            [adaptedPresetArray removeLastObject];

        adaptedPresetArray[0] = [TTSBrain getNewIDAndUpdate:YES];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *installedPresets = [[TTSBrain getArrayForKey:TTSPresetKey] mutableCopy];
        [installedPresets addObject:adaptedPresetArray];
        [defaults setObject:installedPresets forKey:TTSPresetKey];
        [defaults synchronize];

        [self.motherController performSegueWithIdentifier:@"toPresets" sender:adaptedPresetArray];
    }
    else if ([str isEqualToString:@"cRYO"]) {
        WBErrorNoticeView *error = [WBErrorNoticeView errorNoticeInView:self.motherController.tableView title:@"Can't rate your own preset" message:@"Nice Try"];
        [error show];
    }
    else if ([str isEqualToString:@"nNR"]) {
        //The preset is no longer rated
        //Reduce our rating by 1
        NSInteger newRatingInteger = [self.presetArray[7] integerValue] - 1;
        NSNumber *newRatingNumber = @(newRatingInteger);

        //Update our current preset number in our preset array
        self.presetArray[7] = newRatingNumber;
        self.presetArray[9] = @0;
        //Update the main controller's presets array and reload the controller's tableView
        self.motherController.presets[self.row] = self.presetArray;
        [self.motherController reloadData];
    }
    else if ([str isEqualToString:@"nR"]) {
        //The preset is now rated
        //Reduce add rating by 1
        NSInteger newRatingInteger = [self.presetArray[7] integerValue] + 1;
        NSNumber *newRatingNumber = @(newRatingInteger);

        //Update our current preset number in our preset array
        self.presetArray[7] = newRatingNumber;
        self.presetArray[9] = @1;
        //Update the main controller's presets array and reload the controller's tableView
        self.motherController.presets[self.row] = self.presetArray;
        [self.motherController reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //When we start
    [self.downloadedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //When we receive data, add it onto our data already downloaded
    [self.downloadedData appendData:data];
}

- (void)hideHUD {
    //Send a message to our HUD thread to hide it
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.motherController.view animated:YES];
    });
}

- (void)showErrorMessage {
    //Tell the user that we had an error
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.motherController.view title:@"Connection Error" message:@"Something's gone wrong, check your internet connection or come back later. If this is a persistent error, please notify the developer"];
    [notice show];
}

- (void)showLoginMessage {
    //Tell the user to login
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.motherController.view title:@"Login" message:@"You're not logged in. Please login."];
    [notice show];
}
@end
