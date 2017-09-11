//
//  Presetter.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 27/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBrain.h"
#import "TTSHomeViewController.h"

@implementation TTSPresetterViewController
NSMutableData *mutData;
WBErrorNoticeView *notice;

- (void)viewDidDisappear:(BOOL)animated {
    //When we're exited, stop speaking
    [super viewDidDisappear:animated];
    [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    self.shouldLoadCurrent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Sets up our textValueButton/Label to allow it to expand when pressed and when changed
    self.textValue.titleLabel.numberOfLines = 0;
    self.textValue.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.textValue.titleLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionInitial context:NULL];
    //Sets up our speedSlider to prevent it from being over/under the max/min speed
    self.rateSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate;
    self.rateSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate;
    //Now reload the data for the 1st time to prevent non-loading bugs
    [self reload];
}

-(void)dealloc {
    [self.textValue.titleLabel removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //Size the textLabel to fit and find out what difference the new height is
    [self.textValue.titleLabel sizeToFit];
    CGFloat addedHeight = self.textValue.titleLabel.frame.size.height;
    CGRect rect = self.textValue.frame;
    rect.size.height = addedHeight;
    //Now, set the textValue's height to use the added height
    [self.textValue setFrame:rect];

    //Loops through our action buttons
    for (UIButton *button in self.actionButtons) {
        //Now we move them down below our textLabel to prevent overlapping - nicely animated
        CGRect frame = button.frame;
        frame.origin.y = self.textValue.frame.origin.y + rect.size.height + 10;
        [UIView animateWithDuration:0.25 animations:^{
            [button setFrame:frame];
        }];
    }

    //Now we get a random button and see if it is visible.
    UIButton *butt = (UIButton *) self.actionButtons[0];
    if (butt.frame.origin.y >= self.view.frame.size.height) {
        //If it isn't, extend the scrollView size to fit the changed height of our view - nicely animated of course
        CGSize size = self.scrollView.contentSize;
        size.height = butt.frame.origin.y + butt.frame.size.height + 15+self.adView.frame.size.height;
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentSize = size;
            CGRect adViewRect = self.adView.frame;
            adViewRect.origin.y=self.scrollView.contentSize.height-adViewRect.size.height;
            [self.adView setFrame:adViewRect];
        }];
    }
}

- (AVSpeechSynthesizer *)speechSynthesizer {
    //Lazily instantiates the speechSynthesizer and sets its delegate to self
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
    }
    return _speechSynthesizer;
}

- (TTSSpeechUtterance *)speechUtterance {
    //Lazily instantiates the speechUtterance with our default text
    if (!_speechUtterance)
        _speechUtterance = (TTSSpeechUtterance *) [[TTSSpeechUtterance alloc] initWithString:@"This is an example of your chosen preset"];

    //Sets the rate and pitch to be what we set it to be
    _speechUtterance.speechString = self.textValue.titleLabel.text;
    _speechUtterance.rate = self.rateSlider.value;
    _speechUtterance.pitchMultiplier = self.pitchSlider.value;
    _speechUtterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.languageID];
    return _speechUtterance;
}

- (void)reload {
    if (self.taskType == TTSPresetTaskTypeNew) {
        //If we're making a new preset, tell the user then set the pitch, rate and voice to default
        [self.presetType setTitle:@"New Preset" forState:UIControlStateNormal];
        self.pitchSlider.value = 1.0f;
        self.rateSlider.value = AVSpeechUtteranceDefaultSpeechRate;
        self.languageID = @"en-GB";
        [self textWasChosen:@"Not Set"];
    }
    else if (self.taskType == TTSPresetTaskTypeCurrent || self.shouldLoadCurrent) {
        //If we're changing the current preset tell the user then set the pitch, rate and voice to our current one
        if (self.taskType == TTSPresetTaskTypeCurrent)
            [self.presetType setTitle:@"Current Preset" forState:UIControlStateNormal];
        else
            [self.presetType setTitle:@"Share Preset" forState:UIControlStateNormal];
        self.rateSlider.value = [TTSBrain getFloatForKey:@"rate" defaultValue:AVSpeechUtteranceDefaultSpeechRate];
        self.pitchSlider.value = [TTSBrain getFloatForKey:@"pitch" defaultValue:1.0f];
        self.languageID = [TTSBrain getStringForKey:@"language" defaultValue:@"en-GB"];
        [self textWasChosen:[TTSBrain getStringForKey:@"defaultText" defaultValue:@"Not Set"]];
    }
    else {
        //If we're editing a preset, tell the user then set the pitch, rate and voice to the original preset value
        if (self.taskType == TTSPresetTaskTypeEdit) {
            [self.presetType setTitle:@"Edit Preset" forState:UIControlStateNormal];
            NSArray *presets = [[TTSBrain getArrayForKey:TTSPresetKey] mutableCopy];
            self.presetArray = presets[self.index];
        }
        else if (self.taskType == TTSPresetTaskTypeShare)
            [self.presetType setTitle:@"Share Preset" forState:UIControlStateNormal];

        self.languageID = (self.presetArray)[1];
        self.rateSlider.value = [(self.presetArray)[2] floatValue];
        self.pitchSlider.value = [(self.presetArray)[3] floatValue];
        [self textWasChosen:self.presetArray[4]];
    }

    //Sets up our voiceValue to size the content to fit
    self.voiceValue.titleLabel.minimumScaleFactor = 0.6;
    self.voiceValue.titleLabel.adjustsFontSizeToFitWidth = YES;

    //Shows the values of speed and pitch on our labels
    [self formatSlider:self.rateSlider toLabel:self.rateValue];
    [self formatSlider:self.pitchSlider toLabel:self.pitchValue];

    //Loads our voice to text
    [self.voiceValue setTitle:[TTSBrain formatReadableStringFromLocaleString:self.languageID] forState:UIControlStateNormal];
}

- (IBAction)speedChanged:(UISlider *)sender {
    //Format the speedLabel to show the new speed value
    [self formatSlider:self.rateSlider toLabel:self.rateValue];
}

- (IBAction)pitchChanged:(UISlider *)sender {
    //Give it a delay before speaking so it can pre render
    self.speechUtterance.preUtteranceDelay = 0.3;
    //Format the pitchLabel to show the new pitch value
    [self formatSlider:self.pitchSlider toLabel:self.pitchValue];
}

- (void)formatSlider:(UISlider *)slider toLabel:(UILabel *)label {
    //To format, we convert the slider value to a string and set the label's text to it
    label.text = [TTSBrain floatToString:slider.value];
}

- (void)voiceWasChosenWithID:(NSString *)localeID formatted:(NSString *)languageName {
    //When a voice was chosen, update our variables accordingly for languageID and formatted string
    self.languageID = localeID;
    [self.voiceValue setTitle:languageName forState:UIControlStateNormal];
}

- (void)textWasChosen:(NSString *)text {
    if ([text isEqualToString:@""])
        text = @"Not Set";
    //A new text was chosen, so we can update our variables accordingly
    [self.textValue setTitle:text forState:UIControlStateNormal];
}

- (IBAction)reset:(id)sender {
    //Reset the speedSlider and pitchSlider
    self.rateSlider.value = AVSpeechUtteranceDefaultSpeechRate;
    self.pitchSlider.value = 1.0f;
    //Next, reset our speech utterance's speed and pitch
    self.speechUtterance.pitchMultiplier = 1.0;
    self.speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    //Now, format our labels to show the values of our default speed and pitch
    [self formatSlider:self.rateSlider toLabel:self.rateValue];
    [self formatSlider:self.pitchSlider toLabel:self.pitchValue];
}

- (IBAction)try:(UIButton *)sender {
    //Start speaking and disable the button to prevent crashing by multiple speech instances at one time
    [self.speechSynthesizer speakUtterance:self.speechUtterance];
    sender.enabled = NO;
}

- (IBAction)showVoice:(id)sender {
    //Stop speaking and go to the change voice view controller
    [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self performSegueWithIdentifier:@"toVoice" sender:nil];
}

- (IBAction)showText:(id)sender {
    //Stop speaking and go to the change text view controller
    [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self performSegueWithIdentifier:@"toText" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Checking type of segue
    if ([segue.identifier isEqualToString:@"toVoice"]) {
        //If we're going to voice, tell it that we're going to it modally and set up the delegate to self to receive new voice chosen
        TTSVoiceViewController *voiceController = [segue destinationViewController];
        voiceController.voiceViewingType = TTSVoiceViewingTypeModal;
        voiceController.delegate = self;
        voiceController.preferredContentSize = self.preferredContentSize;
    }
    if ([segue.identifier isEqualToString:@"toText"]) {
        //If we're going to text, tell it that we're going to it modally and set up the delegate to self to receive our updated text
        TTSTextViewController *textController = [segue destinationViewController];
        textController.defaultText = self.textValue.titleLabel.text;
        textController.delegate = self;
        textController.preferredContentSize = self.preferredContentSize;
    }
}

- (IBAction)confirm:(id)sender {
    //Check what action we're doing
    if (self.taskType == TTSPresetTaskTypeCurrent) {
        //Changing our current preset
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.languageID forKey:@"language"];
        [defaults setFloat:self.rateSlider.value forKey:@"rate"];
        [defaults setFloat:self.pitchSlider.value forKey:@"pitch"];
        [defaults setObject:self.textValue.titleLabel.text forKey:@"defaultText"];
        [defaults synchronize];
    }
    else if (self.taskType == TTSPresetTaskTypeShare) {
        //Creates our request with a URL and sets it to be $_POST
        NSURL *url = [NSURL URLWithString:@"http://hughbellamyapps.heliohost.org/Speak%20Easy/newPreset.php"];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:7.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

        //Create our parameter and add it to our request
        NSString *paramString = [NSString stringWithFormat:@"userID=%ld&voice=%@&rate=%f&pitch=%f&text=%@", (long) [TTSBrain getUserID], self.languageID, self.rateSlider.value, self.pitchSlider.value, self.textValue.currentTitle];

        NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];

        //Create and start a connection with our request
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];

        //Checks if we're successful
        if (connection) {
            //If we are, start the progress HUD and reset our data
            mutData = [NSMutableData data];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"Loading";
        }
        else {
            //If not, notify the user of an unknown error
            notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Unknown error" message:@"Please try again later or check your internet connection"];
            notice.sticky = YES;
            [notice show];
        }
    }
    else {
        //We're changing or creating a preset, so load the preset array
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *array = [[TTSBrain getArrayForKey:TTSPresetKey] mutableCopy];

        //Format: ID, Language ID, speed, pitch and default text
        NSNumber *idValue = [TTSBrain getNewIDAndUpdate:YES];
        NSNumber *speedValue = @(self.rateSlider.value);
        NSNumber *pitchValue = @(self.pitchSlider.value);

        NSArray *presetArray = @[idValue, self.languageID, speedValue, pitchValue, self.textValue.titleLabel.text];

        if (self.taskType == TTSPresetTaskTypeNew)
                //Making a new preset-save as a new preset
            [array addObject:presetArray];
        else if (self.taskType == TTSPresetTaskTypeEdit) {
            //Editing a preset-overwrite
            [array removeObjectAtIndex:self.index];
            [array addObject:presetArray];
        }
        [userDefaults setObject:array forKey:TTSPresetKey];
        [userDefaults synchronize];
    }

    if (self.taskType != TTSPresetTaskTypeShare) {
        //We're done here, dismiss
        [self dismiss];
    }
}

- (IBAction)cancel:(id)sender {
    //If we're cancelling, dismiss us 
    [self dismiss];
}

- (void)dismiss {
    //Reload tableView's data and dismiss us
    [self.motherControllerInfo reloadData];
    [self.motherControllerHome.presetPopover dismissPopoverAnimated:YES];
    [self.motherControllerInfo.presetterPopover dismissPopoverAnimated:YES];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    //We finished speaking so we can enable our tryButton
    self.tryButton.enabled = YES;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    //We finished speaking so we can enable our tryButton
    self.tryButton.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //We've finished so we hide the HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

    //Now lets get our data in the form of a string
    NSString *str = [[NSString alloc] initWithData:mutData encoding:NSUTF8StringEncoding];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];

    //Check what our data means
    if ([str isEqualToString:@"i"] || [str isEqualToString:@""] || [str isEqualToString:@"mE"]) {
        //Something bad has happened, so lets notify the user
        notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Invalid Data" message:@"Please try again later."];
        [notice show];
    }
    else if([str isEqualToString:@"InternalServerError(ErrorCode500)\n\n500\n<!--\n\n-->\n"])
    {
        //Internal Server Error
        notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Internal Server Error" message:@"Lots of people are using Speak Easy, please try again later."];
        [notice show];
    }
    //We've got data
    else if ([str isEqualToString:@"c"]) {
        self.motherControllerInfo.sharePresetArray = nil;
        [self.motherControllerInfo update];
        [self.motherControllerHome.presetPopover dismissPopoverAnimated:YES];
        [self.motherControllerInfo.presetterPopover dismissPopoverAnimated:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //If we failed, stop our progress HUD
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    //Then tell the user that something went wrong
    notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Network Error" message:@"Check your network connection."];
    notice.sticky = YES;
    [notice show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //We've started so lets reset our data
    [mutData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //As we get data downloaded, add
    [mutData appendData:data];
}

@end
