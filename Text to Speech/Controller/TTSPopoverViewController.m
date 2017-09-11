//
//  TTSPopoverViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSPopoverViewController.h"
#import "TTSHomeViewController.h"
#import "TTSBrain.h"

@implementation TTSPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.speedSlider.value = [TTSBrain getFloatForKey:@"rate" defaultValue:AVSpeechUtteranceDefaultSpeechRate];
    self.speedSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate;
    self.speedSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate;
    [self formatSlider:self.speedSlider toLabel:self.speedValue];

    self.pitchSlider.value = [TTSBrain getFloatForKey:@"pitch" defaultValue:1.0f];
    [self formatSlider:self.pitchSlider toLabel:self.pitchValue];
}

- (void)formatSlider:(UISlider *)slider toLabel:(UILabel *)label {
    label.text = [self floatToString:slider.value];
}

- (AVSpeechSynthesizer *)speechSynthesizer {
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
    }
    return _speechSynthesizer;
}

- (AVSpeechUtterance *)speechUtterance {
    if (!_speechUtterance) {
        _speechUtterance = [[AVSpeechUtterance alloc] initWithString:@"The quick brown fox jumps over the lazy dog"];
        _speechUtterance.rate = self.speedSlider.value;
        _speechUtterance.pitchMultiplier = self.pitchSlider.value;
    }
    return _speechUtterance;
}

- (IBAction)speedChanged:(UISlider *)sender {
    self.speechUtterance.rate = sender.value;
    [self formatSlider:self.speedSlider toLabel:self.speedValue];
}

- (NSString *)floatToString:(float)val {
    NSString *ret = [NSString stringWithFormat:@"%.5f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    while (c == 48 || c == 46) { // 0 or .
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
    }
    return ret;
}

- (IBAction)pitchChanged:(UISlider *)sender {
    self.speechUtterance.pitchMultiplier = sender.value;
    self.speechUtterance.preUtteranceDelay = 0.3;
    [self formatSlider:self.pitchSlider toLabel:self.pitchValue];
}

- (IBAction)reset:(id)sender {
    self.speedSlider.value = AVSpeechUtteranceDefaultSpeechRate;
    self.pitchSlider.value = 1.0f;
    self.speechUtterance.pitchMultiplier = 1.0;
    self.speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    [self formatSlider:self.speedSlider toLabel:self.speedValue];
    [self formatSlider:self.pitchSlider toLabel:self.pitchValue];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (IBAction)try:(UIButton *)sender {
    [self.speechSynthesizer speakUtterance:self.speechUtterance];
    sender.enabled = NO;
}

- (IBAction)confirm:(id)sender {
    [TTSBrain writeFloat:self.speedSlider.value forKey:@"rate"];
    [TTSBrain writeFloat:self.pitchSlider.value forKey:@"pitch"];
    [self.parent.presetPopover dismissPopoverAnimated:YES];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.goOnButton.enabled = YES;
}
@end
