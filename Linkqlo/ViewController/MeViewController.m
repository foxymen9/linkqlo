//
//  MeViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "MeViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import "AppDelegate.h"
#import "ProfilePhotoView.h"
#import "UIImageView+WebCache.h"

#import "WebViewController.h"
#import "PostListViewController.h"
#import "UserListViewController.h"
#import "RegisterViewController.h"

#import "FXBlurView.h"

#import <MessageUI/MessageUI.h>

// Crashlytics
//#import <Crashlytics/Crashlytics.h>

#define URL_TERMS @"http://linkqlo.com/terms/"
#define URL_POLICY @"http://linkqlo.com/privacy-policy/"
#define URL_HELP @"http://linkqlo.com/help"
#define URL_ABOUT @"http://linkqlo.com/about"

@interface MeViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UIImageView *ivBack;
@property (nonatomic, assign) IBOutlet FXBlurView *viewBlur;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UILabel *lblFullName;
@property (nonatomic, assign) IBOutlet UILabel *lblUserName;
@property (nonatomic, assign) IBOutlet UILabel *lblGender;
@property (nonatomic, assign) IBOutlet UILabel *lblStatus;
@property (nonatomic, assign) IBOutlet UILabel *lblLocation;

@property (nonatomic, assign) IBOutlet UILabel *lblPosts;
@property (nonatomic, assign) IBOutlet UILabel *lblFollowings;
@property (nonatomic, assign) IBOutlet UILabel *lblFollowers;
@property (nonatomic, assign) IBOutlet UILabel *lblLikes;

@property (nonatomic, assign) IBOutlet UILabel *lblDate;
@property (nonatomic, assign) IBOutlet UILabel *lblVersion;

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ivProfile.layer.masksToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    
    self.ivProfile.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.ivProfile.layer.borderColor = [[UIColor blackColor] CGColor];
    
    UITapGestureRecognizer *tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfile)];
    [self.ivProfile addGestureRecognizer:tapGestur];
    tapGestur = nil;

    self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.svMain.frame), 820);
    
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    self.lblDate.text = [NSString stringWithFormat:@"Build Version: %@.%@", appInfo[@"CFBundleShortVersionString"], appInfo[@"CFBundleVersion"]];
    self.lblVersion.text = [NSString stringWithFormat:@"Build Time: %@", appInfo[@"BuildDate"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"posts"])
    {
        PostListViewController *vcPostList = (PostListViewController *)segue.destinationViewController;

        NSNumber *type = (NSNumber *)sender;
        if ([type integerValue] == 0) // My Posts
        {
            vcPostList.title = @"Posts";
            vcPostList.strAPIName = @"get_user_posts";
            
            NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
            if (userInfo != nil)
            {
                NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
                if (strUserID != nil && strUserID.length > 0)
                {
                    NSDictionary *request = @{@"user_id" : strUserID, @"poster_id" : strUserID};
                    vcPostList.dicRequest = request;
                }
            }
        }
        else if ([type integerValue] == 1) // My Likes
        {
            vcPostList.title = @"Likes";
            vcPostList.strAPIName = @"get_user_likes";
            
            NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
            if (userInfo != nil)
            {
                NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
                if (strUserID != nil && strUserID.length > 0)
                {
                    NSDictionary *request = @{
                                              @"user_id" : strUserID,
                                              @"poster_id" : strUserID,
                                              };
                    
                    vcPostList.dicRequest = request;
                }
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"userlist"])
    {
        UserListViewController *vcUserList = (UserListViewController *)segue.destinationViewController;

        NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
        
        NSNumber *type = (NSNumber *)sender;
        if ([type integerValue] == 0) // Following
        {
            vcUserList.title = @"Following";
            vcUserList.strAPIName = @"get_user_followings";
            vcUserList.strFieldName = @"followings";
            NSDictionary *request = @{@"my_id" : strUserID, @"user_id" : strUserID};
            vcUserList.dicRequest = request;
        }
        else if ([type integerValue] == 1) // Follower
        {
            vcUserList.title = @"Followers";
            vcUserList.strAPIName = @"get_user_followers";
            vcUserList.strFieldName = @"followers";
            NSDictionary *request = @{@"my_id" : strUserID, @"user_id" : strUserID};
            vcUserList.dicRequest = request;
        }
    }
    else if ([segue.identifier isEqualToString:@"webview"])
    {
        WebViewController *vcWeb = (WebViewController *)segue.destinationViewController;
        
        NSString *url = (NSString *)sender;
        if ([url isEqualToString:URL_TERMS]) // Terms of Service
        {
            vcWeb.title = @"Terms of Service";
            vcWeb.strNavigate = url;
        }
        else if ([url isEqualToString:URL_POLICY]) // Privacy Policy
        {
            vcWeb.title = @"Privacy Policy";
            vcWeb.strNavigate = url;
        }
        else if ([url isEqualToString:URL_HELP]) // Help
        {
            vcWeb.title = @"Help";
            vcWeb.strNavigate = url;
        }
        else if ([url isEqualToString:URL_ABOUT]) // About
        {
            vcWeb.title = @"About Linkqlo";
            vcWeb.strNavigate = url;
        }
    }
    else if ([segue.identifier isEqualToString:@"register"])
    {
        UINavigationController *navController = segue.destinationViewController;
        RegisterViewController *vcRegister = (RegisterViewController *)[navController topViewController];
        vcRegister.showLogoutButton = YES;
    }
}

- (void)loadUserInfo
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              };
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"get_user_counts" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strCount = [NSString stringWithFormat:@"%@", [dicRet objectForKey:@"posts"]];
        if (strCount != nil) self.lblPosts.text = strCount; else self.lblPosts.text = @"";
        strCount = [NSString stringWithFormat:@"%@", [dicRet objectForKey:@"followers"]];
        if (strCount != nil) self.lblFollowers.text = strCount; else self.lblFollowers.text = @"";
        strCount = [NSString stringWithFormat:@"%@", [dicRet objectForKey:@"followings"]];
        if (strCount != nil) self.lblFollowings.text = strCount; else self.lblFollowings.text = @"";
        strCount = [NSString stringWithFormat:@"%@", [dicRet objectForKey:@"likes"]];
        if (strCount != nil) self.lblLikes.text = strCount; else self.lblLikes.text = @"";
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

    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo != nil)
    {
        NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"photo_url"]];
        [self.ivBack setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
        [self.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
        
        self.lblFullName.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"first_name"]];
        
        NSString *strUserName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
        self.lblUserName.text = [NSString stringWithFormat:@"@%@", strUserName];
        
        NSString *strGender = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"gender"]];
        if ([strGender isEqualToString:@"male"]) strGender = @"Male";
        else if ([strGender isEqualToString:@"female"]) strGender = @"Female";
        self.lblGender.text = [NSString stringWithFormat:@"Gender: %@", strGender];
        
        NSString *strStatus = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"status"]];
        self.lblStatus.text = [NSString stringWithFormat:@"Status: %@", strStatus];

        NSString *strLocation = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"location"]];
        self.lblLocation.text = [NSString stringWithFormat:@"Location: %@", strLocation];
    }

    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(loadUserInfo) userInfo:nil repeats:NO];
}

- (void)tapProfile
{
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"ProfilePhotoView" owner:self options:nil];
    ProfilePhotoView* viewPhoto = [nib objectAtIndex:0];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"photo_url"]];
    [viewPhoto initView:strPhotoURL];
    AppDelegate* app = [[UIApplication sharedApplication] delegate];
    [app.window addSubview:viewPhoto];
}

- (IBAction)onAddPeople:(id)sender
{
    [self performSegueWithIdentifier:@"addpeople" sender:nil];
}

- (IBAction)onEdit:(id)sender
{
    [self performSegueWithIdentifier:@"editprofile" sender:nil];
}

- (IBAction)onSetBSI:(id)sender
{
    [self performSegueWithIdentifier:@"bsi" sender:nil];
}

- (IBAction)onPosts:(id)sender
{
//    DiscoverPostsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Posts"];
//    
//    [self.navigationController pushViewController:vc animated:YES];
    [self performSegueWithIdentifier:@"posts" sender:[NSNumber numberWithInt:0]];
}

- (IBAction)onFollowing:(id)sender
{
    [self gotoUserListScreen:0];
}

- (IBAction)onFollowers:(id)sender
{
    [self gotoUserListScreen:1];
}

- (IBAction)onLike:(id)sender
{
    [self performSegueWithIdentifier:@"posts" sender:[NSNumber numberWithInt:1]];
}

- (IBAction)onFeedback:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please set an E-mail account and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;

    [picker setToRecipients:@[@"feedback@linkqlo.com"]];
    
    NSString* strSubject = @"Feedback for Linkqlo's iOS app";
    [picker setSubject:strSubject];

    picker.navigationBar.barStyle = UIBarStyleDefault;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onTerms:(id)sender
{
    [self performSegueWithIdentifier:@"webview" sender:URL_TERMS];
}

- (IBAction)onPolicy:(id)sender
{
    [self performSegueWithIdentifier:@"webview" sender:URL_POLICY];
}

- (IBAction)onHelp:(id)sender
{
    [self performSegueWithIdentifier:@"webview" sender:URL_HELP];
}

- (IBAction)onAbout:(id)sender
{
    [self performSegueWithIdentifier:@"webview" sender:URL_ABOUT];
}

- (IBAction)onLogout:(id)sender
{
//    [[Crashlytics sharedInstance] crash];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strMailAddr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"email_address"]];
    NSString *strFBID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"fb_id"]];
    NSString *strTWID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"tw_id"]];
    if (strMailAddr.length == 0 && strFBID.length == 0 && strTWID.length == 0)
    {
        [self performSegueWithIdentifier:@"register" sender:nil];
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:nil forKey:@"apiName"];
        [prefs setObject:nil forKey:@"loginRequest"];
        [prefs synchronize];
        
        [self.navigationController.tabBarController.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) gotoUserListScreen:(NSInteger)type
{
    [self performSegueWithIdentifier:@"userlist" sender:[NSNumber numberWithInteger:type]];
}

#pragma mark MFMailControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed - Unknown Error :-("
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = -1;
            [alert show];
        }
            
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
