//
//  Presetter.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 27/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//
@import iAd;
@import AVFoundation;
@class TTSInfoViewController;
@class TTSHomeViewController;
@class TTSPresetterViewController;

#import "TTSSpeechUtterance.h"
#import "TTSTextViewController.h"
#import "TTSInfoViewController.h"
#import "TTSVoiceViewController.h"


@interface TTSPresetterViewController : UIViewController
        <AVSpeechSynthesizerDelegate, TTSVoicePickerDelegate, TTSTextDelegate, ADBannerViewDelegate>

@property(strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property(strong, nonatomic) TTSSpeechUtterance *speechUtterance;

@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UIButton *tryButton;
@property(weak, nonatomic) IBOutlet UISlider *rateSlider;
@property(weak, nonatomic) IBOutlet UILabel *rateValue;
@property(weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property(weak, nonatomic) IBOutlet UILabel *pitchValue;
@property(weak, nonatomic) IBOutlet UIButton *voiceValue;
@property(weak, nonatomic) IBOutlet UIButton *textValue;
@property(weak, nonatomic) NSString *languageID;

@property(weak, nonatomic) TTSInfoViewController *motherControllerInfo;
@property(weak, nonatomic) TTSHomeViewController *motherControllerHome;
@property(nonatomic) NSUInteger index;
@property(nonatomic) TTSPresetTaskType taskType;
@property(weak, nonatomic) IBOutlet UIButton *presetType;
@property(strong, nonatomic) NSMutableArray *presetArray;

- (void)reload;

@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *actionButtons;
@property(weak, nonatomic) IBOutlet ADBannerView *adView;
@property(nonatomic, assign) BOOL bannerIsVisible;
@property(nonatomic, assign) BOOL shouldLoadCurrent;
@end
