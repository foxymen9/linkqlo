//
//  AppDelegate.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "AppDelegate.h"

#import "SignInViewController.h"
#import "MyTabBarViewController.h"

#import "DataManager.h"
#import "FacebookManager.h"

// AWS
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSCognitoSync/Cognito.h>

// Localytics
#import "LocalyticsSession.h"

// Crashlytics
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)logout
{
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    [navController dismissViewControllerAnimated:NO completion:nil];
    [navController popToRootViewControllerAnimated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    // Initialize push notification.
#ifdef __IPHONE_8_0
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
    {
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
#else
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif
    
    // Initialize AWS Cognito
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          accountId:@"232089982381"
                                                          identityPoolId:@"us-east-1:64ec0511-1d01-4480-ac0f-e1a284816e7a"
                                                          unauthRoleArn:@"arn:aws:iam::232089982381:role/Cognito_linkqloUnauth_DefaultRole"
                                                          authRoleArn:@"arn:aws:iam::232089982381:role/Cognito_linkqloAuth_DefaultRole"];
    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    // Localytics
    [[LocalyticsSession shared] integrateLocalytics:@"74e76e5d4fd868bf4a86d68-03234c2e-71c3-11e4-2871-004a77f8b47f" launchOptions:launchOptions];
    
    // Crashlytics
    [Fabric with:@[CrashlyticsKit]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)updateBadge
{
    UINavigationController *vcRoot = (UINavigationController *)[[self window] rootViewController];
    for (UIViewController *vc in vcRoot.viewControllers)
    {
        if ([vc isKindOfClass:[MyTabBarViewController class]])
        {
            MyTabBarViewController *vcTab = (MyTabBarViewController *)vc;
            [vcTab updateBadge];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self updateBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"fb1526008010975981"])
    {
        BOOL handled = [[FacebookManager sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
        NSLog(@"<%@ (%p) %@ handled:%@>\r url: %@\r sourceApplication: %@", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), handled ? @"YES" : @"NO", url.absoluteString, sourceApplication);
        
        return handled;
    }

    if ([[url scheme] isEqualToString:@"myapp"])
    {
        NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
        
        NSString *token = d[@"oauth_token"];
        NSString *verifier = d[@"oauth_verifier"];
        NSLog(@"%@", d);
        
        if (self.regController != nil)
        {
            [self.regController setOAuthToken:token oauthVerifier:verifier];
        }
        else
        {
            UINavigationController *vcRoot = (UINavigationController *)[[self window] rootViewController];
            for (UIViewController *vc in vcRoot.viewControllers)
            {
                if ([vc isKindOfClass:[SignInViewController class]])
                {
                    SignInViewController *vcSignin = (SignInViewController *)vc;
                    [vcSignin setOAuthToken:token oauthVerifier:verifier];
                }
            }
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark Notification

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"])
    {
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
    }
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info
{
    NSLog(@"%@", info);

    NSInteger badges = [[[info objectForKey:@"aps"] objectForKey: @"badge"] intValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badges];

    [self updateBadge];

    NSMutableDictionary *customInfo = [info objectForKey:@"custom"];
    if (customInfo != nil)
    {
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"My device token = %@", token);
    
    [[DataManager shareDataManager] setDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to registered for remote notification");

    [[DataManager shareDataManager] setDeviceToken:nil];
}

@end
