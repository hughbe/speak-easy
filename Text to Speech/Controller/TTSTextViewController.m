//
//  TTSTextViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 29/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSTextViewController.h"

@implementation TTSTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Setup our textView
    self.text.layer.cornerRadius = 15.0f;
    self.text.layer.borderWidth = 2.0f;
    [self.text setPlaceholder:@"Enter text to speak"];
    //Setup for keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    //When we appear load the current text value to our textView if any
    [super viewWillAppear:animated];
    if (![self.defaultText isEqualToString:@"Not Set"])
        self.text.text = self.defaultText;
    else
        self.text.text = @"";
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    //Gets keyboard size
    if (CGRectIsEmpty(self.editingFrame)) {
        NSDictionary *info = [aNotification userInfo];
        CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

        CGFloat yOffset = 5;
        CGFloat xOffset = 5;

        CGRect view = self.view.frame;
        CGRect newRect = CGRectMake(xOffset, yOffset, view.size.width - xOffset * 2, view.size.height - kbSize.height - yOffset);
        self.editingFrame = newRect;
    }

    [UIView animateWithDuration:0.25 animations:^{
        [self.text setFrame:self.editingFrame];
        [self.text setNeedsDisplay];
    }];
}

- (IBAction)choseText:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.delegate textWasChosen:self.text.text];
}
@end
