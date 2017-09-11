//
//  TTSBrain.h
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

@import Social;
@import StoreKit;
@import AVFoundation;

#define TTSPresetKey @"presets"
#define TTSDatabaseSalt @"makichich1"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

typedef NS_ENUM(NSInteger, TTSPresetInfoType)
{
    TTSPresetInfoTypeOnline,
    TTSPresetInfoTypeOffline
};

typedef NS_ENUM(NSInteger, TTSPresetOnlineType)
{
    TTSPresetOnlineTypeGeneral,
    TTSPresetOnlineTypeProfile,
    TTSPresetOnlineTypeSingle
};

typedef NS_ENUM(NSInteger, TTSPresetTaskType)
{
    TTSPresetTaskTypeNew,
    TTSPresetTaskTypeEdit,
    TTSPresetTaskTypeCurrent,
    TTSPresetTaskTypeShare
};

typedef NS_ENUM(NSInteger, TTSVoiceViewingType)
{
    TTSVoiceViewingTypeModal,
    TTSVoiceViewingTypePush
};

typedef NS_ENUM(NSInteger, TTSSharingType)
{
    TTSSharingTypeLogin,
    TTSSharingTypeSignup
};

@interface TTSBrain : NSObject
- (void)speakWithText:(NSString *)text;

@property(strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property(nonatomic) float rate;
@property(nonatomic) float pitch;
@property(strong, nonatomic) NSString *languageID;

+ (void)write:(id)object forKey:(NSString *)key;

+(void)writeFloat:(float)object forKey:(NSString*)key;
+ (void)writeBoolForKey:(BOOL)value forKey:(NSString *)key;

+ (NSString *)getStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

+ (BOOL)getBoolForKey:(NSString *)key;

+ (float)getFloatForKey:(NSString *)key defaultValue:(float)defaultValue;

+ (void)presentSocialSheet:(NSString *)serviceType initialText:(NSString *)initialText controller:(UIViewController *)controller image:(UIImage *)image;

+ (void)presentAppStorePageWithIdentifier:(NSString *)identifier delegate:(UIViewController <SKStoreProductViewControllerDelegate> *)delegate viewController:(UIViewController *)viewController activityIndicator:(UIActivityIndicatorView *)activityIndicator;

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

+ (NSArray *)getArrayForKey:(NSString *)key;

//+(NSArray*)getPresetArrayForIndex:(NSUInteger)index;
+ (NSString *)formatReadableStringFromLocaleString:(NSString *)localeString;

+ (NSString *)floatToString:(float)val;

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString;

+ (NSString *)hashString:(NSString *)data withSalt:(NSString *)salt;

+ (NSNumber *)getNewIDAndUpdate:(BOOL)actUpon;

+ (BOOL)connected;

+ (void)logout;

+ (BOOL)loggedIn;

+ (void)loginWithEmail:(NSString *)email userID:(NSInteger)userID;

+ (NSString *)getEmail;

+ (NSInteger)getUserID;

+ (CGRect)popoverRect;
@end
