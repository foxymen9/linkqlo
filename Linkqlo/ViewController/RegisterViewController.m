//
//  RegisterViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 12/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "RegisterViewController.h"

#import "AppDelegate.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import "STTwitter.h"
#import "FacebookManager.h"

#define TWITTER_KEY @"36CSCM1OCQlJyHpjOzu1PFnCC"
#define TWITTER_SECRET @"ZDo1s1NRDqg2aakbbrkN7bvslM49orVIXI9WN5zxNfTbxgZvnv"

@interface RegisterViewController () <FBManagerDelegate>

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UITextField *txtMailAddr;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) FacebookManager *fbManager;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[FacebookManager sharedInstance] setDelegate:self];
    
    self.svMain.contentSize = CGSizeMake(self.svMain.frame.size.width, 600);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.regController = self;
    
    if (!self.showLogoutButton)
        self.navigationItem.rightBarButtonItem = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.regController = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    
    float diff = (keyboardRect.origin.y < self.view.frame.size.height) ? keyboardRect.size.height : 0;
    
    [UIView animateWithDuration:0.2 animations:^ {
        self.svMain.frame = CGRectMake(self.svMain.frame.origin.x, self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.svMain.frame.origin.y - diff);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onLogout
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to logout without completing your profile? Your history and data will be lost." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Log out", nil];
    alertView.tag = 2;
    
    [alertView show];
}

- (BOOL)isValidMailAddress:(NSString *)mailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:mailAddress];
}

- (BOOL)processRegister
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return NO;
    
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    if (strUserID == nil || strUserID.length == 0)
        return NO;
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"email_address" : self.txtMailAddr.text,
                              @"password" : self.txtPassword.text,
                              };
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"update_user_mail" request:(NSMutableDictionary *)request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return NO;
        }
        else // Success
        {
            // Current User Info.
            [[DataManager shareDataManager] setUserInfo:dicRet];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Thank you for completing your profile with email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            alertView.tag = 1;
            
            [alertView show];

            return YES;
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return NO;
}

- (IBAction)onRegister:(id)sender
{
    [self.txtMailAddr resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    NSString *strMail = self.txtMailAddr.text;
    NSString *strPass = self.txtPassword.text;
    
    NSString *strMessage = nil;
    do {
        if (strMail.length == 0)
        {
            strMessage = @"Please input an e-mail address.";
            break;
        }
        
        if (![self isValidMailAddress:strMail])
        {
            strMessage = @"Please input a valid e-mail address.";
            break;
        }
        
        if (strPass.length == 0)
        {
            strMessage = @"Please input the password.";
            break;
        }
    } while (FALSE);
    
    if (strMessage != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self processRegister];
}

- (BOOL)processFacebookUser:(NSDictionary<FBGraphUser> *)fbUser
{
    NSLog(@"%@", fbUser);
    
    NSString *strMailAddr = [fbUser valueForKey:@"email"];
    if (strMailAddr == nil) strMailAddr = @"";
    NSString *strFirstName = [fbUser valueForKey:@"first_name"];
    NSString *strLastName = [fbUser valueForKey:@"last_name"];
    NSString *strFBID = [fbUser valueForKey:@"id"];
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", strFBID];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return NO;
    
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    if (strUserID == nil || strUserID.length == 0)
        return NO;
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"fb_id" : strFBID,
                              @"email_address" : strMailAddr,
                              @"first_name" : [NSString stringWithFormat:@"%@ %@", strFirstName, strLastName],
                              @"last_name" : @"",
                              @"photo_url" : userImageURL,
                              };
    
    NSLog(@"%@", request);
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"update_user_mail" request:request];
    
    NSLog(@"%@", dicRet);
    
    [JSWaiter HideWaiter];
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return NO;
        }
        else // Success
        {
            NSString *strSuccess = [dicRet objectForKey:@"success"];
            
            if (strSuccess != nil && [strSuccess isKindOfClass:[NSString class]])
            {
                // Current User Info.
                [[DataManager shareDataManager] setUserInfo:dicRet];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Thank you for completing your profile with Facebook." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                alertView.tag = 1;
                
                [alertView show];
                
                return YES;
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return NO;
}

- (void)reqFacebookUserInfo
{
    [JSWaiter ShowWaiter:self title:@"Logging in..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    [[FacebookManager sharedInstance] loadUserDetailsWithCompletionHandler:^(NSDictionary<FBGraphUser> *user, NSError *error)
     {
         if (error == nil)
         {
             [self processFacebookUser:user];
         }
         else
         {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error_facebook", nil)
                                         message:error.localizedDescription
                                        delegate:nil
                               cancelButtonTitle:NSLocalizedString(@"close", nil)
                               otherButtonTitles:nil] show];
             
             [JSWaiter HideWaiter];
         }
     }];
}

- (IBAction)onRegisterFB:(id)sender
{
    FacebookManager *fbManager = [FacebookManager sharedInstance];
    if ([fbManager isSessionOpen])
    {
        [self reqFacebookUserInfo];
    }
    else
    {
        [fbManager login];
    }
}

- (void)processTwitterUser:(NSDictionary *)twUser
{
    NSLog(@"%@", twUser);
    
    NSString *twitterID = [twUser objectForKey:@"id_str"];
    NSString *strFullName = [twUser objectForKey:@"name"];
    NSString *urlProfileImage = [twUser objectForKey:@"profile_image_url"];
    
    // Larger dimension profile image.
    urlProfileImage = [urlProfileImage stringByReplacingOccurrencesOfString:@"_normal." withString:@"."];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return;
    
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    if (strUserID == nil || strUserID.length == 0)
        return;
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"tw_id" : twitterID,
                              @"first_name" : strFullName,
                              @"last_name" : @"",
                              @"photo_url" : urlProfileImage,
                              };
    
    NSLog(@"%@", request);
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"update_user_mail" request:request];
    
    NSLog(@"%@", dicRet);
    
    [JSWaiter HideWaiter];
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        else // Success
        {
            NSString *strSuccess = [dicRet objectForKey:@"success"];
            
            if (strSuccess != nil && [strSuccess isKindOfClass:[NSString class]])
            {
                // Current User Info.
                [[DataManager shareDataManager] setUserInfo:dicRet];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Thank you for completing your profile with Twitter." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                alertView.tag = 1;
                
                [alertView show];
                
                return;
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    [JSWaiter ShowWaiter:self title:@"Logging in..." type:0];
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        [JSWaiter HideWaiter];
        
        [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            [self.twitter getUsersShowForUserID:userID orScreenName:screenName includeEntities:nil successBlock:^(NSDictionary *user) {
                [self processTwitterUser:user];
            } errorBlock:^(NSError *error) {
                //
            }];
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", error.debugDescription);
        }];
    } errorBlock:^(NSError *error) {
        [JSWaiter HideWaiter];
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (IBAction)onRegisterTW:(id)sender
{
    [JSWaiter ShowWaiter:self title:@"Logging in..." type:0];
    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        [self.twitter getUserInformationFor:username successBlock:^(NSDictionary *user) {
            [self processTwitterUser:user];
        } errorBlock:^(NSError *error) {
            [JSWaiter HideWaiter];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_twitter", nil)
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }];
        
    } errorBlock:^(NSError *error) {
        self.twitter = nil;
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_KEY consumerSecret:TWITTER_SECRET];
        [self.twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
            NSLog(@"-- url: %@", url);
            NSLog(@"-- oauthToken: %@", oauthToken);
            
            [[UIApplication sharedApplication] openURL:url];
        } authenticateInsteadOfAuthorize:NO
                            forceLogin:@(YES)
                            screenName:nil
                         oauthCallback:@"myapp://twitter_access_tokens/"
                            errorBlock:^(NSError *error) {
                                NSLog(@"-- error: %@", error);
                            }];
    }];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (alertView.tag == 2 && buttonIndex == 1)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:nil forKey:@"apiName"];
        [prefs setObject:nil forKey:@"loginRequest"];
        [prefs synchronize];
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate logout];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtMailAddr)
        [self.txtPassword becomeFirstResponder];
    else if (textField == self.txtPassword)
        [self.txtMailAddr becomeFirstResponder];
    
    return YES;
}

#pragma mark FBManagerDelegate

-(void)FBLogin:(BOOL)flag
{
    [self reqFacebookUserInfo];
}

@end
