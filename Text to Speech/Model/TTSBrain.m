//
//  TTSBrain.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSBrain.h"
#import "Reachability.h"

#include <sys/types.h>
#include <sys/sysctl.h>
#import <CommonCrypto/CommonHMAC.h>

@interface TTSBrain ()

- (void)updateVariables;

@end

@implementation TTSBrain

- (AVSpeechSynthesizer *)speechSynthesizer {
    //Lazily instantiates our speech synthesizer
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _speechSynthesizer;
}

- (void)speakWithText:(NSString *)text {
    //Load our current data points
    [self updateVariables];

    //Create a voice with the entered text
    AVSpeechUtterance *voice = [[AVSpeechUtterance alloc] initWithString:text];

    //Set the voice, rate and pitch for our new voice
    [voice setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:self.languageID]];
    [voice setRate:self.rate];
    [voice setPitchMultiplier:self.pitch];

    //Start speaking!
    [self.speechSynthesizer speakUtterance:voice];
}

- (void)updateVariables {
    //Load our userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Gets the voice, rate and pitch values and sets them to the appropriate variables within our brain
    self.languageID = [defaults objectForKey:@"language"];
    self.rate = [defaults floatForKey:@"rate"];
    self.pitch = [defaults floatForKey:@"pitch"];

    //Checks to see if we have invalid variables, and if so, make them valid
    if (!self.languageID) {
        self.languageID = @"en-GB";
    }
    if (self.rate <= 0.00) {
        self.rate = 0.3;
    }
    if (self.pitch >= 1.00) {
        self.pitch = 1;
    }
}

+ (void)write:(id)object forKey:(NSString *)key {
    //Load userDefaults, write the object and then synchronise the userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

+ (void)writeFloat:(float)object forKey:(NSString *)key {
    //Load userDefaults, write the float and then synchronise the userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:object forKey:key];
    [defaults synchronize];
}

+ (void)writeBoolForKey:(BOOL)value forKey:(NSString *)key {
    //Load userDefaults, write the BOOL then synchronise the userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:key];
    [defaults synchronize];
}

+ (BOOL)getBoolForKey:(NSString *)key {
    //Load userDefaults and return the BOOL for said key
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (NSString *)getStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    //Load userDefaults, and gets the string value for our entered key
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    //If the string is invalid, set it to a valid string provided as a parameter
    if ([string isEqualToString:@""] || string.length == 0 || string == nil)
        string = defaultValue;
    return string;
}

+ (float)getFloatForKey:(NSString *)key defaultValue:(float)defaultValue {
    //Load userDefaults, and gets the float value for our entered key
    float floatPoint = [[NSUserDefaults standardUserDefaults] floatForKey:key];
    //If the float is invalid, set it to a valid float provided as a parameter
    if (floatPoint <= 0) {
        floatPoint = defaultValue;
    }
    
    return floatPoint;
}

+ (NSArray *)getArrayForKey:(NSString *)key {
    //Load userDefaults, and gets the array value for our entered key
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
    //If there is no array for the key, return an empty array
    if (!array)
        array = [[NSArray alloc] init];

    return array;
}

+ (NSArray *)getPresetArrayForIndex:(NSUInteger)index {
    //Gets our preset array
    NSArray *mainArray = [self getArrayForKey:TTSPresetKey];
    NSArray *presetArray;
    //Checks if the parameter index is valid
    if (index < [mainArray count])
        presetArray = mainArray[index]; //If so return the valid array
    else
        presetArray = [[NSArray alloc] init]; //If not, return an empty array
    return presetArray;
}

+ (NSString *)formatReadableStringFromLocaleString:(NSString *)localeString {
    //Creates a locale with the identifier eg "en-GB"
    NSLocale *languageLocale = [NSLocale localeWithLocaleIdentifier:localeString];
    //Converts this locale into a formatter string eg "English (United Kingdom)" and returns it
    NSString *language = [languageLocale displayNameForKey:NSLocaleIdentifier value:[languageLocale localeIdentifier]];
    return language;
}

+ (NSString *)floatToString:(float)val {
    //Format the float to 2 decimal places
    NSString *ret = [NSString stringWithFormat:@"%.2f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    //Cut down trailing zeroes for user ease of reading
    while (c == 48 || c == 46) { // 0 or .
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
    }
    return ret;
}

+ (void)presentSocialSheet:(NSString *)serviceType initialText:(NSString *)initialText controller:(UIViewController *)controller image:(UIImage *)image {
    //Create a sheet for the chosen service type
    SLComposeViewController *sheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    //Sets the sheet's text to what we requested
    [sheet setInitialText:initialText];
    //Adds an image to it, if any
    [sheet addImage:image];
    //Shows the sheet
    [controller presentViewController:sheet animated:YES completion:nil];
}

+ (void)presentAppStorePageWithIdentifier:(NSString *)identifier delegate:(UIViewController <SKStoreProductViewControllerDelegate> *)delegate viewController:(UIViewController *)viewController activityIndicator:(UIActivityIndicatorView *)activityIndicator {
    if (activityIndicator) {
        //If we have an activity indicator, animate and unhide it
        [activityIndicator startAnimating];
        activityIndicator.hidden = NO;
    }

    //Create the store view controller
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];

    //Set its delegate to what was requested, if any
    [storeProductViewController setDelegate:delegate];
    //Loads the view controller
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : identifier} completionBlock:^(BOOL result, NSError *error) {
        if (!error)
            [viewController presentViewController:storeProductViewController animated:YES completion:nil];
                //If nothing went wrong, show the view controller
        else {
            //If something happened, show an error alert and stop the activity indicator
            [self showAlertViewWithTitle:@"Unable to connect" message:@"The internet's down! Run to the woods and hide! \n \n Please connect to the internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [activityIndicator stopAnimating];
            activityIndicator.hidden = YES;
        }
    }];

}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    //Create an alertView with the title, message, delegate and cancel button set
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];

    //Checks if we have other button titles
    if (otherButtonTitles != nil) {
        //If so, add a button with this title
        [alertView addButtonWithTitle:otherButtonTitles];
        //Loops through the entered button titles
        va_list args;
        va_start(args, otherButtonTitles);
        NSString *buttonTitle = nil;
        while ((buttonTitle = va_arg(args, NSString*)))
            [alertView addButtonWithTitle:buttonTitle];

        va_end(args);
    }
    //Now, show the alert view
    [alertView show];
}

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    //Setup regexes for validating email
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    //Create validator
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    //Checks if it is valid
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString *)hashString:(NSString *)data withSalt:(NSString *)salt {
    //Converts the data and salt to CStrings
    const char *cKey = [salt cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    //Generates a SHA256 hash for the data and salt
    NSString *hash;

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
}

+ (NSNumber *)getNewIDAndUpdate:(BOOL)actUpon {
    //Load userDefaults and get the ID integer
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger newId = [defaults integerForKey:@"id"];
    //if we've never created a preset, then the newID can be 0
    if (!newId)
        newId = 0;
    //Now, increment the newID
    newId++;
    //If asked to, update the userDefault's ID and synchronise it
    if (actUpon) {
        [defaults setInteger:newId forKey:@"id"];
        [defaults synchronize];
    }
    //Return the NSNumber wrapped newID integer
    return @(newId);
}

+ (BOOL)connected {
    //Use Apple's reachability class to get the connection and check if we're connected
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return (networkStatus != NotReachable);
}

+ (NSInteger)getUserID {
    //Get the integer value for key 'userID' from userDefaults
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"userID"];
}

+ (NSString *)getEmail {
    //Get the string value for key 'userEmail' from userDefaults with a default value of 'invalid'
    return [self getStringForKey:@"userEmail" defaultValue:@"invalid"];
}

+ (void)loginWithEmail:(NSString *)email userID:(NSInteger)userID {
    //Loads userDefaults,signs us in by adding userID and userEmail to the userDefaults and then saves userDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:userID forKey:@"userID"];
    [defaults setObject:email forKey:@"userEmail"];
    [defaults synchronize];
}

+ (void)logout {
    //To logout we remove the userID and userEmail values from userDefaults and synchronise it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userID"];
    [defaults removeObjectForKey:@"userEmail"];
    [defaults synchronize];
}

+ (BOOL)loggedIn {
    //If we have no value for our email address in userDefaults, we're not logged in
    return ![[self getEmail] isEqualToString:@"invalid"];
}

+ (CGRect)popoverRect {
    //Creates a rect and centers is on the screen's width center
    CGRect rect = CGRectZero;
    rect.origin.x = [UIScreen mainScreen].bounds.size.width / 2;
    return rect;
}
@end
