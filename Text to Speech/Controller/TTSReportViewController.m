//
//  TTSReportViewController.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 27/10/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBrain.h"
#import "MBProgressHUD.h"
#import "WBSuccessNoticeView.h"
#import "TTSReportViewController.h"

@implementation TTSReportViewController

- (NSArray *)defaultSource {
    //Creates our list of reasons to report and returns it
    if (!_defaultSource) {
        _defaultSource = @[@"Sexually Explicit", @"Hateful", @"Harassing", @"Likely to cause harm", @"Spam", @"Other"];
    }
    return _defaultSource;
}

- (UIFont *)boldFont {
    //Lazily instantiates our boldFont
    if (!_boldFont) {
        _boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    }
    return _boldFont;
}

- (UIFont *)lightFont {
    //Lazily instantiates our lightFont
    if (!_lightFont) {
        _lightFont = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    }
    return _lightFont;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Check's what sort of reporting we're doing
    if (self.reportType == TTSReportPreset) {
        //We're reporting a preset, so tell the user and show the necessary areas of reporting the text of a preset
        self.navigationItem.title = @"Reporting Preset";

        //Add a gesture recognizer to our defaultText label so that we can highlight areas of concern for the text
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wordPressed:)];
        [self.textView addGestureRecognizer:tapGestureRecognizer];

        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:self.string attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18.0f]}];

        self.areasOfConcern.hidden = NO;
        self.textView.hidden = NO;
    }
    else if (self.reportType == TTSReportUser) {
        //We're reporting a user, so tell the user and hide the unnecessary areas of reporting a user
        self.navigationItem.title = [@"Reporting " stringByAppendingString:self.string];
        self.areasOfConcern.hidden = YES;
        self.textView.hidden = YES;
        self.block = [[SSCheckBoxView alloc] initWithFrame:self.blockView.frame style:kSSCheckBoxViewStyleMono checked:NO];
        [self.block setText:@"Block User?"];
        [self.view addSubview:self.block];
        [self.blockView removeFromSuperview];
    }
}

- (void)wordPressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    //Gets the point where we tapped
    CGPoint location = [tapGestureRecognizer locationInView:self.textView];
    location.y += self.textView.contentOffset.y;


    UITextRange *textRange = [self.textView characterRangeAtPoint:location];
    NSInteger start = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:textRange.start];
    NSInteger end = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:textRange.end];

    NSRange range = NSMakeRange((NSUInteger) start, (NSUInteger) (end - start));

    [self.textView.text enumerateSubstringsInRange:NSMakeRange(0, [self.textView.text length]) options:NSStringEnumerationByWords usingBlock:^(NSString *word, NSRange wordRange, NSRange enclosingRange, BOOL *stop) {
        NSRange intersectionRange = NSIntersectionRange(range, wordRange);
        if (intersectionRange.length > 0) {

            NSMutableAttributedString *mutableAttributedString = [self.textView.attributedText mutableCopy];

            [mutableAttributedString enumerateAttribute:NSFontAttributeName inRange:wordRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id aValue, NSRange aRange, BOOL *enough) {
                if ([aValue isEqual:self.boldFont]) {
                    //We're currently bold so let's de-bold us
                    [mutableAttributedString addAttributes:@{NSFontAttributeName : self.lightFont, NSForegroundColorAttributeName : [UIColor blackColor]} range:aRange];
                }
                else {
                    //We're currently light so let's de-bold us
                    [mutableAttributedString addAttributes:@{NSFontAttributeName : self.boldFont, NSForegroundColorAttributeName : [UIColor redColor]} range:aRange];

                }
            }];
            self.textView.attributedText = mutableAttributedString;
        }
    }];

    /*
    //get location in text from text position at point
    UITextPosition *tapPos = [self.textView closestPositionToPoint:location];
    
    //fetch the word at this position (or nil, if not available)
    UITextRange *textRange = [self.textView.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    
    NSInteger start= [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:textRange.start];
    NSInteger end = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:textRange.end];
    
    NSRange range=NSMakeRange((NSUInteger)start, (NSUInteger)(end-start));
    
    UIFont *boldFont=[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    UIFont *lightFont=[UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    
    NSMutableAttributedString *mutableAttributedString = [self.textView.attributedText mutableCopy];
    
    [mutableAttributedString enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange aRange, BOOL *stop) {
        if([value isEqual:boldFont]) {
            //We're currently bold so let's de-bold us
            [mutableAttributedString addAttributes:@{NSFontAttributeName: lightFont, NSForegroundColorAttributeName: [UIColor blackColor]} range:aRange];
        }
        else {
            //We're currently light so let's de-bold us
            [mutableAttributedString addAttributes:@{NSFontAttributeName: boldFont, NSForegroundColorAttributeName: [UIColor redColor]} range:aRange];
            
        }
    }];
self.textView.attributedText=mutableAttributedString;*/
}

- (NSString *)HTMLStringFromAttributedString:(NSAttributedString *)attributedString {
    //Creates a plain text reference
    NSMutableString *HTMLString = [[attributedString string] mutableCopy];
    //Creates a large range of the whole attributedString
    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    __block NSUInteger lengthAdded = 0;

    //Go Through the attributed string checking for font change
    [attributedString enumerateAttribute:NSFontAttributeName inRange:attributedStringRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        //Checks if we're at a bold area
        if ([value isEqual:self.boldFont]) {
            [HTMLString insertString:@"<b>" atIndex:range.location + lengthAdded];
            lengthAdded += 3;
            [HTMLString insertString:@"</b>" atIndex:range.location + range.length + lengthAdded];
            lengthAdded += 4;
        }
    }];
    NSLog(@"%@", HTMLString);
    return HTMLString;
}

- (IBAction)report:(id)sender {
    //We're confirming the reporting of the user or preset
    NSURL *url = [NSURL URLWithString:@"http://hughbellamyapps.heliohost.org/Speak%20Easy/report.php"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSString *reportTypeParam;
    NSString *reportStringParam;
    if (self.reportType == TTSReportPreset) {
        reportTypeParam = @"preset";
        reportStringParam = [self HTMLStringFromAttributedString:self.textView.attributedText];
    }
    else {
        reportTypeParam = @"user";
        reportStringParam = self.string;
    }

    NSString *paramString = [NSString stringWithFormat:@"reporterID=%ld&reportType=%@&reportedID=	%ld&reportReason=%@&reportString=%@&block=%@", (long) [TTSBrain getUserID], reportTypeParam, (long) self.ID, self.defaultSource[(NSUInteger) [self.picker selectedRowInComponent:0]], reportStringParam, [NSNumber numberWithBool:self.block.checked]];

    NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

    if (connection) {
        self.mutData = [NSMutableData data];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Reporting";
    }
    else {
        self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Error Connecting" message:@"Try again later or check your internet connection"];
        [self.notice show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //We've finished loading so lets hide the progress bar
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

    //Formats our data
    NSString *str = [[NSString alloc] initWithData:self.mutData encoding:NSUTF8StringEncoding];
    //str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    //Now checks what the data means to us
    if ([str isEqualToString:@"i"] || [str isEqualToString:@""] || [str isEqualToString:@"mE"]) {
        //Invalid data
        self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Invalid Data" message:@"Please try again later or inform the developer"];
        [self.notice show];
    }
    else {
        NSString *title;
        if ([str isEqualToString:@"U"]) {
            title = @"User Reported. Thank You";
        }
        else {
            title = @"Preset Reported. Thank You";
        }

        WBSuccessNoticeView *successNoticeView = [WBSuccessNoticeView successNoticeInView:self.scrollView title:title];
        [successNoticeView show];
        self.scrollView.userInteractionEnabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self.navigationController selector:@selector(popToRootViewControllerAnimated:) userInfo:nil repeats:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //We've failed, so lets enable our proceed button, hide the HUD and tell the user
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    self.notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Error Connecting" message:@"Try again later or check your internet connection"];
    [self.notice show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //We've received a response, so reset our data and prepare to receive new data
    [self.mutData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //As we receive data, add the received data onto our current data
    [self.mutData appendData:data];
}

#pragma mark UIPicker Delegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //We have as many rows as source objects
    return (NSInteger) self.defaultSource.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    //We have only one component
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //The title of a row is the value of our array of reasons for reporting at the row's index
    return self.defaultSource[(NSUInteger) row];
}
@end
