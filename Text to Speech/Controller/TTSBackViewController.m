//
//  TTSBackViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 11/10/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBackViewController.h"

@implementation TTSBackViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSegueWithIdentifier:@"home" sender:nil];
}

@end
