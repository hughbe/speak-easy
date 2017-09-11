//
//  TTSAppDelegate.m
//  Text to Speech
//
//  Created by Hugh Bellamy on 25/09/2013.
//  Copyright (c) 2013 Hugh Bellamy. All rights reserved.
//

#import "TTSAppDelegate.h"
#import "TTSInfoViewController.h"

@implementation TTSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    //Get's what we are presenting
    NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Get's what type of object we're getting
    NSString *type = [text substringFromIndex:text.length-1];
    NSString *ID = [text substringToIndex:text.length-1];
    
    //Makes sure that the object is of the right type
    if([type isEqualToString:@"P"]||[type isEqualToString:@"U"]) {
        
        //Creates our online tabBarController
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"share"];
        
        //Selects our single or preset view depending on what we're getting
        if([type isEqualToString:@"P"]) {
            [tabBarController setSelectedIndex:1];
        }
        else {
            [tabBarController setSelectedIndex:2];
        }
        
        //Get's the navigationController associated with our single or preset viewControllers
        UINavigationController *navigationController = (UINavigationController *) tabBarController.selectedViewController;

        //Get's the single or preset viewController according to what we're doing
        TTSInfoViewController *viewController;
        if([type isEqualToString:@"P"]) {
            viewController = (TTSInfoViewController *) [storyboard instantiateViewControllerWithIdentifier:@"single"];
        }
        else {
            viewController = navigationController.viewControllers[0];
        }
        
        //Set's the ID
        viewController.ID = [ID integerValue];
        viewController.userName = @"User's Presets";
        
        //If we're viewing a single preset, add it to our navigationController's stack
        if([type isEqualToString:@"P"]) {
            [navigationController pushViewController:viewController animated:YES];
        }
        
        //Recreate our window with our online tabBarController
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = tabBarController;
        [self.window makeKeyAndVisible];
    }
    return YES;
}

@end
