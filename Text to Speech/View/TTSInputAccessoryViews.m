//
//  TTSInputAccessoryViews.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 29/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSInputAccessoryViews.h"

@implementation TTSInputAccessoryViews

- (IBAction)dismissTextField:(id)sender {
    [self.textField resignFirstResponder];
}

@end
