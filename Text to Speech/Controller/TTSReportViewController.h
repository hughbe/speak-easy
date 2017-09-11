//
//  TTSReportViewController.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 27/10/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

@import UIKit;

#import "SSCheckBoxView.h"
#import "WBErrorNoticeView.h"

typedef NS_ENUM(NSInteger, TTSReportType)
{
    TTSReportPreset,
    TTSReportUser
};

@interface TTSReportViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property(weak, nonatomic) IBOutlet UIPickerView *picker;
@property(weak, nonatomic) IBOutlet UIView *blockView;

@property(weak, nonatomic) IBOutlet UILabel *areasOfConcern;
@property(strong, nonatomic) IBOutlet UITextView *textView;

@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic) TTSReportType reportType;

@property(nonatomic) NSInteger ID;
@property(strong, nonatomic) NSString *string;
@property(strong, nonatomic) NSArray *defaultSource;

@property(strong, nonatomic) NSMutableData *mutData;
@property(strong, nonatomic) WBErrorNoticeView *notice;

@property(strong, nonatomic) UIFont *boldFont;
@property(strong, nonatomic) UIFont *lightFont;

@property(strong, nonatomic) SSCheckBoxView *block;

@end
