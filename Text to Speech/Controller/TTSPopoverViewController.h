//
//  TTSPopoverViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

@class TTSHomeViewController;

@import UIKit;

@import AVFoundation;

@interface TTSPopoverViewController : UIViewController <AVSpeechSynthesizerDelegate>

@property(strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property(weak, nonatomic) IBOutlet UIButton *goOnButton;
@property(strong, nonatomic) AVSpeechUtterance *speechUtterance;
@property(weak, nonatomic) IBOutlet UISlider *speedSlider;
@property(weak, nonatomic) IBOutlet UILabel *speedValue;
@property(weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property(weak, nonatomic) IBOutlet UILabel *pitchValue;
@property(strong, nonatomic) TTSHomeViewController *parent;
@end
