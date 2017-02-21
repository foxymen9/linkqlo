//
//  SignInViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "SignInViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import "STTwitter.h"
#import "FacebookManager.h"

#define TWITTER_KEY @"36CSCM1OCQlJyHpjOzu1PFnCC"
#define TWITTER_SECRET @"ZDo1s1NRDqg2aakbbrkN7bvslM49orVIXI9WN5zxNfTbxgZvnv"

@interface SignInViewController () <FBManagerDelegate>

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) FacebookManager *fbManager;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.svMain.frame), 500);

    [[FacebookManager sharedInstance] setDelegate:self];
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userInfo = [prefs objectForKey:@"userInfo"];
    if (userInfo != nil)
    {
        NSString *strMailAddr = [userInfo objectForKey:@"email_address"];
        if (strMailAddr != nil && [strMailAddr isKindOfClass:[NSString class]] && strMailAddr.length > 0)
            self.txtEmail.text = strMailAddr;
    }

//    self.txtEmail.text = @"lee@linkqlo.com";
//    self.txtPassword.text = @"lee";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isValidMailAddress:(NSString *)mailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:mailAddress];
}

- (BOOL)processLogin
{
    [JSWaiter ShowWaiter:self title:@"Logging in..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSString *strMail = self.txtEmail.text;
    NSString *strPass = self.txtPassword.text;
    
    NSString *strDeviceToken = [[DataManager shareDataManager] getDeviceToken];
    if (strDeviceToken == nil) strDeviceToken = @"";
    
    NSDictionary *request = nil;
    if ([self isValidMailAddress:strMail])
    {
        request = @{
                    @"email_address"  : strMail,
                    @"password"       : strPass,
                    @"device_token"   : strDeviceToken,
                    };
    }
#ifdef DEBUG
    else
    {
        request = @{
                    @"user_name"  : strMail,
                    @"device_token" : strDeviceToken,
                    };
    }
#endif
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strAPIName = @"login";
    if ([self isValidMailAddress:strMail])
        strAPIName = @"login";
#ifdef DEBUG
    else
        strAPIName = @"login_name";
#endif
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:strAPIName request:request];
    
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
            // Brand List
            [[DataManager shareDataManager] setUserInfo:dicRet];
            
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setObject:strAPIName forKey:@"apiName"];
            [pref setObject:request forKey:@"loginRequest"];
            [pref synchronize];
            
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

- (IBAction)onDone:(id)sender
{
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    NSString *strMail = self.txtEmail.text;
    NSString *strPass = self.txtPassword.text;
    
    NSString *strMessage = nil;
    do {
        if (strMail.length == 0)
        {
            strMessage = @"Please input an e-mail address.";
            break;
        }
        
#ifdef DEBUG
        if ([self isValidMailAddress:strMail])
        {
            if (strPass.length == 0)
            {
                strMessage = @"Please input the password.";
                break;
            }
        }
#else
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
#endif
    } while (FALSE);
    
    if (strMessage != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([self processLogin])
    {
        NSMutableDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        if (userInfo != nil)
            [self gotoNextScreen:userInfo];
    }
}

- (IBAction)onForgot:(id)sender
{
    [self performSegueWithIdentifier:@"forgot" sender:nil];
}

- (void)gotoNextScreen:(NSMutableDictionary *)userInfo
{
/*
    BOOL isFirstTime = [[userInfo objectForKey:@"is_first"] boolValue];
    if (isFirstTime)
    {
        [self gotoProfileScreen];
        return;
    }
    
    NSString *strPhotoURL = [userInfo objectForKey:@"photo_url"];
    NSString *strEmailAddr = [userInfo objectForKey:@"email_address"];
    NSString *strFirstName = [userInfo objectForKey:@"first_name"];
    NSString *strLastName =  [userInfo objectForKey:@"last_name"];
    NSString *strUserName = [userInfo objectForKey:@"user_name"];
    NSString *strGender = [userInfo objectForKey:@"gender"];
//    NSString *strStatus = [userInfo objectForKey:@"status"];
//    NSString *strLocation = [userInfo objectForKey:@"location"];
    if (strPhotoURL == nil || strPhotoURL.length == 0 ||
        strEmailAddr == nil || strEmailAddr.length == 0 ||
        strFirstName == nil || strFirstName.length == 0 ||
        strLastName == nil || strLastName.length == 0 ||
        strUserName == nil || strUserName.length == 0 ||
        strGender == nil || strGender.length == 0)
    {
        [self gotoProfileScreen];
        return;
    }
    
    NSMutableArray *specInfo = [userInfo objectForKey:@"spec"];
    if (specInfo == nil || [specInfo count] == 0)
    {
//        [self gotoPrepareScreen];
        [self gotoMainScreen];
        return;
    }
*/    
    [self gotoMainScreen];
}

- (void) gotoProfileScreen
{
    [self performSegueWithIdentifier:@"completeprofile" sender:nil];
}

- (void) gotoPrepareScreen
{
    [self performSegueWithIdentifier:@"prepare1" sender:nil];
}

- (void) gotoMainScreen
{
    [self performSegueWithIdentifier:@"main" sender:nil];
}

- (void)processFacebookUser:(NSDictionary<FBGraphUser> *)fbUser
{
    NSLog(@"%@", fbUser);
    
    NSString *strMailAddr = [fbUser valueForKey:@"email"];
    if (strMailAddr == nil) strMailAddr = @"";
    NSString *strFirstName = [fbUser valueForKey:@"first_name"];
    NSString *strLastName = [fbUser valueForKey:@"last_name"];
    NSString *strUserName = [fbUser valueForKey:@"name"];
    strUserName = [[strUserName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strGender = [fbUser valueForKey:@"gender"];
    NSString *strFBID = [fbUser valueForKey:@"id"];
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", strFBID];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strDeviceToken = [[DataManager shareDataManager] getDeviceToken];
    if (strDeviceToken == nil) strDeviceToken = @"";
    
    NSDictionary *request = @{
                              @"fb_id"          : strFBID,
                              @"email_address"  : strMailAddr,
                              @"first_name"     : [NSString stringWithFormat:@"%@ %@", strFirstName, strLastName],
                              @"last_name"      : @"",
                              @"user_name"      : strUserName,
                              @"gender"         : strGender,
                              @"photo_url"      : userImageURL,
                              @"device_token"   : strDeviceToken,
                              };
    
    NSLog(@"%@", request);
    
    NSString *strAPIName = @"fblogin";
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:strAPIName request:request];
    
    NSLog(@"%@", dicRet);
    
    [JSWaiter HideWaiter];
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            strError = @"You have not signed up an account yet. To sign up, please go back to the previous screen and click \"Start Me Up\" button";
            
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
                
                NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
                [pref setObject:strAPIName forKey:@"apiName"];
                [pref setObject:request forKey:@"loginRequest"];
                [pref synchronize];
                
                [self gotoNextScreen:dicRet];
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

- (IBAction)onFacebook:(id)sender
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
    NSString *strUserName = [twUser objectForKey:@"screen_name"];
    strUserName = [[strUserName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *urlProfileImage = [twUser objectForKey:@"profile_image_url"];
    
    // Larger dimension profile image.
    urlProfileImage = [urlProfileImage stringByReplacingOccurrencesOfString:@"_normal." withString:@"."];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strDeviceToken = [[DataManager shareDataManager] getDeviceToken];
    if (strDeviceToken == nil) strDeviceToken = @"";
    
    NSDictionary *request = @{
                              @"tw_id"          : twitterID,
                              @"first_name"     : strFullName,
                              @"last_name"      : @"",
                              @"user_name"      : strUserName,
                              @"photo_url"      : urlProfileImage,
                              @"device_token"   : strDeviceToken,
                              };
    
    NSLog(@"%@", request);
    
    NSString *strAPIName = @"twlogin";
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:strAPIName request:request];
    
    NSLog(@"%@", dicRet);
    
    [JSWaiter HideWaiter];
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            strError = @"You have not signed up an account yet. To sign up, please go back to the previous screen and click \"Start Me Up\" button";
            
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
                
                NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
                [pref setObject:strAPIName forKey:@"apiName"];
                [pref setObject:request forKey:@"loginRequest"];
                [pref synchronize];
                
                [self gotoNextScreen:dicRet];
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

- (IBAction)onTwitter:(id)sender
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
        //        [JSWaiter HideWaiter];
        
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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtEmail)
        [self.txtPassword becomeFirstResponder];
    else if (textField == self.txtPassword)
        [self.txtEmail becomeFirstResponder];
    
    return YES;
}

#pragma mark FBManagerDelegate

-(void)FBLogin:(BOOL)flag
{
    [self reqFacebookUserInfo];
}

@end
