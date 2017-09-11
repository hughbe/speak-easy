//
//  TTSVoiceCell.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;
@class TTSInfoViewController;

#import "TTSSpeechUtterance.h"

@interface TTSVoiceCell : UITableViewCell <AVSpeechSynthesizerDelegate, UIActionSheetDelegate, NSURLConnectionDelegate>

@property(weak, nonatomic) NSString *languageID;
@property(strong, nonatomic) NSNumber *presetID;
@property(weak, nonatomic) IBOutlet UILabel *voiceLabel;
@property(weak, nonatomic) IBOutlet UILabel *speedLabel;
@property(weak, nonatomic) IBOutlet UILabel *pitchLabel;
@property(weak, nonatomic) IBOutlet UILabel *defaultTextLabel;
@property(weak, nonatomic) IBOutlet UIButton *authorValue;
@property(weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property(weak, nonatomic) IBOutlet UILabel *downloadsLabel;
@property(weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property(weak, nonatomic) IBOutlet UIButton *makeCurrentButton;
@property(nonatomic) NSInteger downloads;
@property(nonatomic) NSInteger rating;
@property(nonatomic) NSNumber *rated;

@property(weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property(weak, nonatomic) IBOutlet UIButton *playButton;
@property(weak, nonatomic) IBOutlet UIButton *voteUpButton;
@property(weak, nonatomic) IBOutlet UIButton *downloadButton;

@property(strong, nonatomic) NSMutableData *downloadedData;
@property(strong, nonatomic) NSMutableArray *presetArray;

@property(weak, nonatomic) TTSInfoViewController *motherController;

@property(strong, nonatomic) TTSSpeechUtterance *utterance;
@property(strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;

@property(nonatomic) NSInteger section;
@property(nonatomic) NSUInteger row;

@property(nonatomic) BOOL animating;
@end
