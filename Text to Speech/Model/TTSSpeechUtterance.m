//
//  TTSSpeechUtterance.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 30/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSSpeechUtterance.h"

@implementation TTSSpeechUtterance

@synthesize speechString;

- (instancetype)initWithString:(NSString *)string {
    self = [super initWithString:string];
    return self;
}

@end
