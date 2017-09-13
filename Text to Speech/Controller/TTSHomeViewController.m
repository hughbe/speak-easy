//
//  TTSHomeViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBrain.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"
#import "TTSInfoViewController.h"
#import "TTSHomeViewController.h"

@implementation TTSHomeViewController
//More Options frames
CGRect original; //Hidden
CGRect adapted; //Shown
//Text View frame
CGRect adaptedTextView; //Squeezed frame
CGRect editingTextToSpeakFrame; //Normal editing frame
CGRect originalTextToSpeakFrame; //Non editing frame
WBErrorNoticeView *errorNotice;
WBSuccessNoticeView *successNotice;

- (void)viewDidLoad {
    [super viewDidLoad];
    //Format textView
    self.textToSpeak.layer.cornerRadius = 15.0f;
    self.textToSpeak.layer.borderWidth = 2.0f;
    [self.textToSpeak setPlaceholder:@"Enter text to speak"];

    //Sets up textView toolbar
    UIToolbar *toolbar = [[NSBundle mainBundle] loadNibNamed:@"InputAccessoryView" owner:self options:nil][0];
    [self.textToSpeak setInputAccessoryView:toolbar];

    self.moreOptionsView.hidden = YES;
    
    //Set original textToSpeak frame and begin setup of editing frame
    CGRect textRect = self.textToSpeak.frame;
    textRect.size.height = (self.view.frame.size.height / 3) * (CGFloat) 1.5 - textRect.origin.y;
    originalTextToSpeakFrame = textRect;
    [self.textToSpeak setFrame:originalTextToSpeakFrame];
    [self.textToSpeak setNeedsDisplay];

    //Setup the show+hide notifications to adapt the textView frame
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];

    //Dismiss keyboard on background tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];

    //Loads the UINavigationController parent of our popup view
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [myStoryboard instantiateViewControllerWithIdentifier:@"presetter"];

    //Sets up and configures the actual content view controller
    self.presetController = (TTSPresetterViewController *) navController.topViewController;
    self.presetController.motherControllerHome = self;
    self.presetController.taskType = TTSPresetTaskTypeCurrent;
    CGSize size = self.view.frame.size;
    self.presetController.preferredContentSize = size;
    //Create the popover controller and change its size to the largest possible

    WYPopoverBackgroundView *popoverAppearance = [WYPopoverBackgroundView appearance];
    [popoverAppearance setTintColor:[UIColor orangeColor]];
    [popoverAppearance setBorderWidth:2];

    //Sets up and configures the popup
    self.presetPopover = [[WYPopoverController alloc] initWithContentViewController:navController];
    self.presetPopover.delegate = self;
}

- (IBAction)unwindHome:(UIStoryboardSegue *)unwindSegue {
    //Sets up unwind segue to go Home
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //If we've already got text in our textView, don't do anything
    if (!self.textToSpeak.text || self.textToSpeak.text.length == 0) {
        NSString *text = [TTSBrain getStringForKey:@"defaultText" defaultValue:@""];
        if (![text isEqualToString:@"Not Set"])
            self.textToSpeak.text = text;
    }
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController {
    //Show successful notification
    successNotice = [WBSuccessNoticeView successNoticeInView:self.view title:@"Changes Saved"];
    [successNotice show];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    //Loading finished, so we can remove the activity indicator and hide the modal view controller
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    //Animates hiding the banner if the and ad failed to load
    if (self.bannerIsVisible) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = self.adView.frame;
            rect.origin.y = self.view.frame.size.height + rect.size.height;
            self.adView.frame = rect;
        }];
        self.bannerIsVisible = NO;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    //Animates showing the banner if an add is loaded
    if (!self.bannerIsVisible) {
        [UIView animateWithDuration:0.4 animations:^{

            CGRect rect = self.adView.frame;
            rect.origin.y = self.view.frame.size.height - rect.size.height;
            self.adView.frame = rect;
        }];
        self.bannerIsVisible = YES;
    }
}

- (IBAction)dismissKeyboard {
    //Dismisses the Keyboard
    [self.textToSpeak resignFirstResponder];
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    [errorNotice dismissNotice];
    //Gets keyboard size
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    //Initialises the More Options shown and hidden frame
    if (CGRectIsEmpty(original)) {
        original = self.moreOptionsView.frame;
        original.origin.y = kbSize.height - original.size.height;

        adapted = self.moreOptionsView.frame;
        adapted.origin.y = kbSize.height;
        adapted.size.height = 0;

        [self.moreOptionsView setFrame:adapted];
        self.moreOptionsView.hidden = NO;
    }

    //Initialises the editing frame if necessary
    if (CGRectIsEmpty(editingTextToSpeakFrame)) {
        CGRect rect = self.textToSpeak.frame;

        //Sets up the offset for x and y
        CGFloat yOffset = 15;
        CGFloat xOffset = 10;
        rect.origin.y = yOffset;
        rect.origin.x = xOffset;

        //Sets up height and width of editing frame and sets it
        rect.size.height = self.view.frame.size.height - yOffset - kbSize.height - 5;
        rect.size.width = self.view.frame.size.width - xOffset * 2;
        editingTextToSpeakFrame = rect;

        //Now, update the textView frame
        adaptedTextView = editingTextToSpeakFrame;
        adaptedTextView.size.width -= original.size.width - adaptedTextView.origin.x;
        adaptedTextView.origin.x = original.size.width;
    }

    //Animate to editing frame
    [UIView animateWithDuration:0.25 animations:^{
        [self.textToSpeak setFrame:editingTextToSpeakFrame];
        [self.textToSpeak setNeedsDisplay];
    }                completion:^(BOOL finished) {
        [self.textToSpeak setNeedsDisplay];
    }];
}

- (void)keyboardWasHidden:(NSNotification *)aNotification {
    //Animate return to original frame
    [UIView animateWithDuration:0.25 animations:^{
        [self.moreOptionsView setFrame:adapted];
        [self.textToSpeak setFrame:originalTextToSpeakFrame];
        [self.textToSpeak setNeedsDisplay];
    }                completion:^(BOOL finished) {
        [self.textToSpeak setNeedsDisplay];
    }];
    self.moreOptionsView.hidden = YES;
}

- (IBAction)showExtraOptions:(UIBarButtonItem *)sender {
    //Disables the show button to prevent multiple taps
    sender.enabled = NO;
    self.moreOptionsView.hidden = NO;

    //Check if the view is hidden
    if (CGRectEqualToRect(self.moreOptionsView.frame, adapted)) {
        //If so, show the view
        [UIView animateWithDuration:0.25 animations:^{
            [self.moreOptionsView setFrame:original];
            [self.textToSpeak setFrame:adaptedTextView];
            [self.textToSpeak setNeedsDisplay];
        }                completion:^(BOOL finished) {
            sender.enabled = YES;
            [self.textToSpeak setNeedsDisplay];
        }];
    }
    else {
        //If its shown, hide the view
        [UIView animateWithDuration:0.25 animations:^{
            [self.moreOptionsView setFrame:adapted];
        }                completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.textToSpeak setFrame:editingTextToSpeakFrame];
                [self.textToSpeak setNeedsDisplay];
            }                completion:^(BOOL done) {
                //Enables the extra options button, then refreshes the textView, prevents scaling bug
                sender.enabled = YES;
                [self.textToSpeak setNeedsDisplay];
            }];
        }];
    }
}

- (IBAction)showVoice:(id)sender {
    //Stop speaking and segue to the voice choose view
    [self.brain.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self performSegueWithIdentifier:@"toVoice" sender:Nil];
}

- (IBAction)showPresets:(id)sender {
    //Stop speaking and segue to the choose view
    [self.brain.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self performSegueWithIdentifier:@"toPresets" sender:Nil];
}

- (IBAction)showSpeedPitch:(id)sender {
    //Hide the keyboard and show the new popover
    [self.textToSpeak resignFirstResponder];
    [self.presetPopover presentPopoverFromRect:[TTSBrain popoverRect] inView:self.view permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
    [self.presetController reload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Check's what we're segueing to
    if ([segue.identifier isEqualToString:@"toVoice"]) {
        //Sets up our voice picker's voiceViewingType to prevent delegate from acting
        TTSVoiceViewController *voice = segue.destinationViewController;
        voice.voiceViewingType = TTSVoiceViewingTypePush;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    //If the text is no longer nothing, hide the notification bar
    if (![textView.text isEqualToString:@""]) {
        errorNotice.delay = 0.0;
        [errorNotice dismissNotice];
        successNotice.delay = 0.0;
        [successNotice dismissNotice];
    }
}

- (IBAction)share:(UIButton *)sender {
    //Share the app
    switch (sender.tag) {
        //Show App Store Share
        case 400:
            [TTSBrain presentAppStorePageWithIdentifier:/*@"716763156"*/@"537623249" delegate:self viewController:self activityIndicator:self.activityIndicator];
            break;
            //Show Facebook Share
        case 401:
            [TTSBrain presentSocialSheet:SLServiceTypeFacebook initialText:@"I'm using Text to Speech, and there're loads of great voices, and I can change the pitch and rate! So much fun! http://bit.ly/16MiBQS" controller:self image:nil];
            break;
            //Show Twitter Share
        case 402:
            [TTSBrain presentSocialSheet:SLServiceTypeTwitter initialText:@"I'm using Text to Speech, and there're loads of great voices, and I can change the pitch and rate! So much fun! http://bit.ly/16MiBQS" controller:self image:nil];
            break;
        case 7:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://hughbellamyapps.wufoo.com/forms/text-to-speech-support-and-suggestions/"]];
            break;
        default:
            break;
    }
}

- (TTSBrain *)brain {
    //Lazily instantiate the brain
    if (!_brain) {
        _brain = [[TTSBrain alloc] init];
        _brain.speechSynthesizer.delegate = self;
    }
    return _brain;
}

- (IBAction)playSynthesiser:(id)sender {
    //Refresh the play button
    [self refreshPlayButton];
}

- (void)refreshPlayButton {
    //Toggles status of playing
    //Checks if brain isn't speaking
    if (![self.brain.speechSynthesizer isSpeaking]) {
        //Checks if user has entered some text
        if (![self.textToSpeak.text isEqualToString:@""]) {
            //If it has, start playing, and change play images to stop images
            [self.playButton setImage:[UIImage imageNamed:@"stop"]];
            [self.playButton2 setImage:[UIImage imageNamed:@"stopSketch"] forState:UIControlStateNormal];
            [self.brain speakWithText:self.textToSpeak.text];
        }
        else {
            errorNotice = [WBErrorNoticeView errorNoticeInView:self.view title:@"No Text Entered" message:@"Try again"];
            [errorNotice show];
        }
        //If not, notify the user of this failure
    }
    else {
        //If it is speaking, how the play button and stop speaking immediately
        [self.playButton setImage:[UIImage imageNamed:@"play"]];
        [self.playButton2 setImage:[UIImage imageNamed:@"playSketch"] forState:UIControlStateNormal];
        [self.brain.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (void)resetPlayButtons {
    //Resetting the play buttons to their original icons
    [self.playButton setImage:[UIImage imageNamed:@"play"]];
    [self.playButton2 setImage:[UIImage imageNamed:@"playSketch"] forState:UIControlStateNormal];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    //Reset the play buttons to show that the speech is finished
    [self resetPlayButtons];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    //Reset the play buttons to show that the speech is finished
    [self resetPlayButtons];
}
@end
