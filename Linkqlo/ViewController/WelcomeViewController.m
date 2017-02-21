//
//  WelcomeViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "WelcomeViewController.h"

// For test only
#import "MyTabBarViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface WelcomeViewController ()
{
    NSString *_strAPIName;
    NSDictionary *_dicRequest;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UIPageControl *pageControl;

@property (nonatomic, assign) IBOutlet UIButton *btnStart;
@property (nonatomic, assign) IBOutlet UIButton *btnLogin;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDatas
{
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              };
    
    NSMutableArray *aryUsernames = [_webMgr requestWithAction:@"get_user_names" request:request];
    
    NSLog(@"%@", aryUsernames);
    
    if (aryUsernames != nil)
        [[DataManager shareDataManager] setUsernamesArray:aryUsernames];
    
    NSMutableArray *aryBrands = [_webMgr requestWithAction:@"get_brands" request:nil];
    
    NSLog(@"%@", aryBrands);
    
    if (aryBrands != nil)
        [[DataManager shareDataManager] setBrandsArray:aryBrands];
    
    NSMutableArray *aryClothingTypes = [_webMgr requestWithAction:@"get_clothings" request:request];
    
    NSLog(@"%@", aryClothingTypes);
    
    if (aryClothingTypes != nil)
        [[DataManager shareDataManager] setClothingTypesArray:aryClothingTypes];
    
    [JSWaiter HideWaiter];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];

    [self gotoNextScreen:[[DataManager shareDataManager] getUserInfo]];
}

- (void)processAutoLogin
{
    if (_strAPIName == nil || _dicRequest == nil)
        return;
    
    [JSWaiter ShowWaiter:self title:@"Logging in..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSLog(@"%@", _dicRequest);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:_strAPIName request:_dicRequest];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setObject:nil forKey:@"apiName"];
            [pref setObject:nil forKey:@"loginRequest"];
            [pref synchronize];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
        }
        else // Success
        {
            [[DataManager shareDataManager] setUserInfo:dicRet];
            
            [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
            [self performSelector:@selector(loadDatas) withObject:nil afterDelay:0.1];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self collocateSubviews];
    
    // For test only
    // Go to main screen
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *strAPIName = [NSString stringWithFormat:@"%@", [pref objectForKey:@"apiName"]];
    NSDictionary *request = [pref objectForKey:@"loginRequest"];
    if (strAPIName != nil && request != nil)
    {
        _strAPIName = strAPIName;
        _dicRequest = request;
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(processAutoLogin) userInfo:nil repeats:NO];
    }
}

- (void) collocateSubviews
{
    NSInteger screenWidth = CGRectGetWidth(self.view.frame);
    NSInteger screenHeight = CGRectGetHeight(self.view.frame);
    self.svMain.frame = self.view.frame;
    
    UIView *subView = nil;

    NSInteger left = 0;
    for (int pageIndex = 0; pageIndex < 5; pageIndex++)
    {
        subView = [self.svMain viewWithTag:(pageIndex + 1)];
        subView.frame = CGRectMake(left, 0,  screenWidth, screenHeight);
        left += screenWidth;
    }
    
    self.svMain.contentSize = CGSizeMake(left, screenHeight);
    
    self.btnStart.frame = CGRectMake(0, screenHeight - 60, screenWidth / 2, 60);
    self.btnStart.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.btnStart.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnLogin.frame = CGRectMake(screenWidth / 2, screenHeight - 60, screenWidth / 2, 60);
    self.btnLogin.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.btnLogin.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (IBAction)onStart:(id)sender
{
    [self performSegueWithIdentifier:@"newsignup" sender:nil];
}

- (IBAction)onLogin:(id)sender
{
    [self performSegueWithIdentifier:@"signin" sender:nil];
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

- (void) gotoMainScreen
{
    [self performSegueWithIdentifier:@"main" sender:nil];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int pageIndex = self.svMain.contentOffset.x / CGRectGetWidth(self.svMain.frame);
    
    self.pageControl.currentPage = pageIndex;
}

@end
