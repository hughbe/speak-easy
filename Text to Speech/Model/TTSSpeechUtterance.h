//
//  TTSSpeechUtterance.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 30/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

@import AVFoundation;

@interface TTSSpeechUtterance : AVSpeechUtterance

@property(strong, nonatomic) NSString *speechString;

@end
