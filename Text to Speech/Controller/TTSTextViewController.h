//
//  TTSTextViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 29/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSTextView.h"

@protocol TTSTextDelegate <NSObject>
@required
- (void)textWasChosen:(NSString *)text;
@end

@interface TTSTextViewController : UIViewController <UITextViewDelegate>
@property(weak, nonatomic) id <TTSTextDelegate> delegate;
@property(weak, nonatomic) IBOutlet TTSTextView *text;
@property(weak, nonatomic) NSString *defaultText;
@property(nonatomic) CGRect editingFrame;
@end
