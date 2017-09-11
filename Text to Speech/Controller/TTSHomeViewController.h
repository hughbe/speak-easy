//
//  TTSHomeViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

@import iAd;
@import StoreKit;
@import AVFoundation;

#import "TTSTextView.h"
#import "WYPopoverController.h"
#import "TTSPresetterViewController.h"

@interface TTSHomeViewController : UIViewController <UITextViewDelegate, AVSpeechSynthesizerDelegate, ADBannerViewDelegate, SKStoreProductViewControllerDelegate, WYPopoverControllerDelegate>

@property(weak, nonatomic) IBOutlet TTSTextView *textToSpeak;

@property(weak, nonatomic) IBOutlet ADBannerView *adView;
@property(weak, nonatomic) IBOutlet UIView *moreOptionsView;

@property(weak, nonatomic) IBOutlet UIButton *playButton2;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property(strong, nonatomic) WYPopoverController *presetPopover;
@property(weak, nonatomic) TTSPresetterViewController *presetController;

@property(strong, nonatomic) TTSBrain *brain;
@property(nonatomic, assign) BOOL bannerIsVisible;
@end
