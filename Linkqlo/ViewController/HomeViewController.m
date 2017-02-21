//
//  HomeViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "HomeViewController.h"

#import "TryToFollowViewController.h"
#import "WhatsNewViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)gotoNextScreen
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || strUserID.length == 0)
        return;
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              };
    
    NSLog(@"%@", request);
    
    if (![[DataManager shareDataManager] hasDatas])
    {
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
    }
/*
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"get_user_followings" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSMutableArray *aryFollowings = [dicRet objectForKey:@"followings"];
        if (aryFollowings.count == 0)
            [self gotoTryFollowScreen];
        else
            [self gotoWhatsNewScreen];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
*/
    [self gotoWhatsNewScreen];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(gotoNextScreen) withObject:nil afterDelay:0.1f];
}

- (void) gotoTryFollowScreen
{
    TryToFollowViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TryFollow"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (void) gotoWhatsNewScreen
{
    WhatsNewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WhatsNew"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

@end
