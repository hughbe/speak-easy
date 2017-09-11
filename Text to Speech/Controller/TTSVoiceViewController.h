//
//  TTSVoiceViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import <iAd/iAd.h>
#import <UIKit/UIKit.h>
#import "TTSBrain.h"

@protocol TTSVoicePickerDelegate <NSObject>
@required
- (void)voiceWasChosenWithID:(NSString *)localeID formatted:(NSString *)languageName;
@end

@interface TTSVoiceViewController : UITableViewController <AVSpeechSynthesizerDelegate, ADBannerViewDelegate>;
@property(weak, nonatomic) IBOutlet UIButton *goOnButton;
@property(weak, nonatomic) IBOutlet ADBannerView *adView;
@property(nonatomic, assign) BOOL bannerIsVisible;
@property(strong, nonatomic) NSMutableArray *data;
@property(nonatomic) TTSVoiceViewingType voiceViewingType;
@property(weak, nonatomic) id <TTSVoicePickerDelegate> delegate;
@property(strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property(strong, nonatomic) AVSpeechUtterance *speechUtterance;
@end
