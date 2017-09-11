//
//  TTSVoiceViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSVoiceCell.h"
#import "MBProgressHUD.h"
#import "TTSVoiceViewController.h"

@implementation TTSVoiceViewController
NSString *language;

- (AVSpeechSynthesizer *)speechSynthesizer {
    //Lazily instantiating our speech synthesizer and sets its delegate to self
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
    }
    return _speechSynthesizer;
}

- (AVSpeechUtterance *)speechUtterance {
    //Lazily instantiating our speech utterance with the default text and sets the rate lower to make it more audible and clear
    if (!_speechUtterance) {
        _speechUtterance = [[AVSpeechUtterance alloc] initWithString:@"This is an example of your chosen voice"];
        [_speechUtterance setRate:(float) 0.3];
    }
    return _speechUtterance;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    //When its finished, hide the HUD and enable the tableView
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    self.tableView.userInteractionEnabled = YES;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    //When its canceled, hide the HUD and enable the tableView
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    self.tableView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adView.alpha = 0.0;

    //Loads all speech voices
    NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
    self.data = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [voices count]; i++) {
        //Converts the AVSpeechVoice instances to their language values and adds them to our data array
        NSString *string = ((AVSpeechSynthesisVoice *) voices[i]).language;
        [self.data addObject:string];;
    }
    //Gets our initialLanguage;
    language = [TTSBrain getStringForKey:@"language" defaultValue:@"en-GB"];
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 0;
    [self.tableView.tableHeaderView setFrame:frame];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    //Animates hiding the banner if the and ad failed to load
    if (self.bannerIsVisible) {
        [UIView animateWithDuration:0.4 animations:^{
            self.adView.alpha = 0.0;
            CGRect frame = self.tableView.tableHeaderView.frame;
            frame.size.height = 0;
            [self.tableView.tableHeaderView setFrame:frame];
        }];
        self.bannerIsVisible = NO;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    //Animates showing the banner if an ad loaded
    if (!self.bannerIsVisible) {
        [UIView animateWithDuration:0.4 animations:^{
            self.adView.alpha = 1.0;
            CGRect frame = self.tableView.tableHeaderView.frame;
            frame.size.height = banner.frame.size.height;
            [self.tableView.tableHeaderView setFrame:frame];
        }];
        self.bannerIsVisible = YES;
    }
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //Formats a readable language name from our current language chosen
    NSString *languageName = [TTSBrain formatReadableStringFromLocaleString:[TTSBrain getStringForKey:@"language" defaultValue:@"en-GB"]];

    return [@"Current Voice: " stringByAppendingString:languageName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Returns the number of entries in our array7
    return (NSInteger) [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Loads the tableViewCell
    static NSString *CellIdentifier = @"Cell";
    TTSVoiceCell *cell = (TTSVoiceCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:1.000 green:0.177 blue:0.402 alpha:1.000];
    bgColorView.layer.cornerRadius = 7;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];

    //Gets the languageID and language name
    NSString *languageID = (self.data)[(NSUInteger) indexPath.row];
    NSString *languageName = [TTSBrain formatReadableStringFromLocaleString:languageID];

    //Sets the respective labels to the variables we created before
    cell.voiceLabel.text = languageName;
    cell.languageID = languageID;
    cell.tintColor = self.tableView.tintColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Gets the selected cell
    TTSVoiceCell *cell = (TTSVoiceCell *) [tableView cellForRowAtIndexPath:indexPath];
    cell.tintColor = [UIColor whiteColor];
    //Changes our selected language to the cell's language
    language = cell.languageID;
    //Unhides our tick box
    self.goOnButton.hidden = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTSVoiceCell *cell = (TTSVoiceCell *) [tableView cellForRowAtIndexPath:indexPath];
    cell.tintColor = self.tableView.tintColor;
}

- (IBAction)saveLanguage:(id)sender {
    //If we're modal, send a message to the delegate telling it of the chosen language
    if (self.voiceViewingType == TTSVoiceViewingTypeModal)
        [self.delegate voiceWasChosenWithID:language formatted:[TTSBrain formatReadableStringFromLocaleString:language]];
            //If we're pushed, write the languageID to our current language
    else if (self.voiceViewingType == TTSVoiceViewingTypePush)
        [TTSBrain write:language forKey:@"language"];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Gets the cell which was tapped
    TTSVoiceCell *cell = (TTSVoiceCell *) [tableView cellForRowAtIndexPath:indexPath];
    //Sets the language to be the cell's languageID
    [self.speechUtterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:cell.languageID]];
    //Starts speaking
    [self.speechSynthesizer speakUtterance:self.speechUtterance];
    //Show an activityViewIndicator and disable the tableView to prevent multiple voices at one time

    //Start the activityViewIndicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.label.text = @"PLAYING";
    tableView.userInteractionEnabled = NO;

}
@end
