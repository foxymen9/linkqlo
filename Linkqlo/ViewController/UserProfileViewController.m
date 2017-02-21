//
//  UserProfileViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "UserProfileViewController.h"

#import "PostListViewController.h"
#import "UserListViewController.h"
#import "PostDetailViewController.h"

#import "PostCollectionViewCell.h"
#import "UICollectionViewWaterfallLayout.h"

#import "AppDelegate.h"
#import "ProfilePhotoView.h"
#import "UIImageView+WebCache.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import "FXBlurView.h"

@interface UserProfileViewController () <UICollectionViewDelegateWaterfallLayout>

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UIImageView *ivBack;
@property (nonatomic, assign) IBOutlet FXBlurView *viewBlur;

@property (nonatomic, assign) IBOutlet UILabel *lblFullName;
@property (nonatomic, assign) IBOutlet UILabel *lblUserName;
@property (nonatomic, assign) IBOutlet UILabel *lblGender;
@property (nonatomic, assign) IBOutlet UILabel *lblStatus;
@property (nonatomic, assign) IBOutlet UILabel *lblLocation;

@property (nonatomic, assign) IBOutlet UILabel *lblSimple;
@property (nonatomic, assign) IBOutlet UILabel *lblUpper;
@property (nonatomic, assign) IBOutlet UILabel *lblLower;
@property (nonatomic, assign) IBOutlet UILabel *lblFull;

@property (nonatomic, assign) IBOutlet UILabel *lblPosts;
@property (nonatomic, assign) IBOutlet UILabel *lblFollowers;
@property (nonatomic, assign) IBOutlet UILabel *lblFollowings;

@property (nonatomic, assign) IBOutlet UICollectionView *cvPosts;

@property (nonatomic, retain) NSMutableDictionary *userInfo;
@property (nonatomic, retain) NSMutableArray *aryUserPosts;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation UserProfileViewController

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
    
    UINib *cellNib = [UINib nibWithNibName:@"PostCollectionViewCell" bundle:nil];
    [self.cvPosts registerNib:cellNib forCellWithReuseIdentifier:@"postcollectionviewcell"];
    
    UICollectionViewWaterfallLayout *layout = [[UICollectionViewWaterfallLayout alloc] init];
    layout.delegate = self;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.cvPosts.collectionViewLayout = layout;

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(loadUserInfo) forControlEvents:UIControlEventValueChanged];
    [self.cvPosts addSubview:self.refreshControl];
    
    tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPosts)];
    [self.lblPosts addGestureRecognizer:tapGestur];
    tapGestur = nil;
    
    tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFollowings)];
    [self.lblFollowings addGestureRecognizer:tapGestur];
    tapGestur = nil;
    
    tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFollowers)];
    [self.lblFollowers addGestureRecognizer:tapGestur];
    tapGestur = nil;
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
    if ([segue.identifier isEqualToString:@"postdetail"])
    {
        PostDetailViewController *vcPostDetail = segue.destinationViewController;
        
        NSMutableDictionary *postInfo = (NSMutableDictionary *)sender;
        vcPostDetail.postID = [postInfo objectForKey:@"post_id"];
    }
    else if ([segue.identifier isEqualToString:@"user_posts"])
    {
        PostListViewController *vcPostList = (PostListViewController *)segue.destinationViewController;
        
        vcPostList.title = @"Posts";
        vcPostList.strAPIName = @"get_user_posts";
        
        NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        NSString *strUserID = [userInfo objectForKey:@"user_id"];
        NSDictionary *request = @{@"user_id" : strUserID, @"poster_id" : self.strUserID };
        vcPostList.dicRequest = request;
        
        vcPostList.isFollowing = [[self.userInfo objectForKey:@"is_following"] boolValue];
    }
    else if ([segue.identifier isEqualToString:@"user_friends"])
    {
        UserListViewController *vcUserList = (UserListViewController *)segue.destinationViewController;
        
        NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        NSString *strMyID = [userInfo objectForKey:@"user_id"];
        
        BOOL isMale = [[self.userInfo objectForKey:@"gender"] isEqualToString:@"male"];
        
        NSNumber *type = (NSNumber *)sender;
        if ([type integerValue] == 0) // Following
        {
            if (isMale)
                vcUserList.title = @"His Following";
            else
                vcUserList.title = @"Her Following";
            
            vcUserList.strAPIName = @"get_user_followings";
            vcUserList.strFieldName = @"followings";
            NSDictionary *request = @{@"my_id" : strMyID, @"user_id" : self.strUserID};
            vcUserList.dicRequest = request;
        }
        else if ([type integerValue] == 1) // Follower
        {
            if (isMale)
                vcUserList.title = @"His Followers";
            else
                vcUserList.title = @"Her Followers";
            
            vcUserList.strAPIName = @"get_user_followers";
            vcUserList.strFieldName = @"followers";
            NSDictionary *request = @{@"my_id" : strMyID, @"user_id" : self.strUserID};
            vcUserList.dicRequest = request;
        }
    }
}

- (void)initView
{
    NSString *strFullName = [NSString stringWithFormat:@"%@", [self.userInfo objectForKey:@"first_name"]];
    NSString *strUserName = [NSString stringWithFormat:@"@%@", [self.userInfo objectForKey:@"user_name"]];
    
    if (strFullName.length > 0)
        [self setTitle:strFullName];
    else
        [self setTitle:strUserName];
    
    NSString *strPhotoURL = [self.userInfo objectForKey:@"photo_url"];
    [self.ivBack setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    [self.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    self.lblFullName.text = strFullName;
    self.lblUserName.text = strUserName;
    
    NSString *strGender = [self.userInfo objectForKey:@"gender"];
    if ([strGender isEqualToString:@"male"]) strGender = @"Male";
    else if ([strGender isEqualToString:@"female"]) strGender = @"Female";
    self.lblGender.text = [NSString stringWithFormat:@"Gender: %@", strGender];
    
    self.lblStatus.text = [NSString stringWithFormat:@"Status: %@", [self.userInfo objectForKey:@"status"]];
    self.lblLocation.text = [NSString stringWithFormat:@"Location: %@", [self.userInfo objectForKey:@"location"]];
    
    NSMutableArray *followers = [self.userInfo objectForKey:@"followers"];
    if (followers != nil)
        self.lblFollowers.text = [NSString stringWithFormat:@"%lu", (unsigned long)followers.count];
    else
        self.lblFollowers.text = @"0";
    
    NSMutableArray *followings = [self.userInfo objectForKey:@"followings"];
    if (followings != nil)
        self.lblFollowings.text = [NSString stringWithFormat:@"%lu", (unsigned long)followings.count];
    else
        self.lblFollowings.text = @"0";
    
    NSMutableDictionary *specInfo = [self.userInfo objectForKey:@"spec"];
    
    NSString *myGender = [[[DataManager shareDataManager] getUserInfo] objectForKey:@"gender"];
    NSString *userGender = [self.userInfo objectForKey:@"gender"];
    if ([myGender isEqualToString:userGender])
    {
        float similarity = [[DataManager shareDataManager] calcSimpleSimilarity:specInfo];
        [self.lblSimple setText:[NSString stringWithFormat:@"%ld%%", (long)(similarity * 100)]];
        
        similarity = [[DataManager shareDataManager] calcUpperSimilarity:specInfo];
        [self.lblUpper setText:[NSString stringWithFormat:@"%ld%%", (long)(similarity * 100)]];
        
        similarity = [[DataManager shareDataManager] calcLowerSimilarity:specInfo];
        [self.lblLower setText:[NSString stringWithFormat:@"%ld%%", (long)(similarity * 100)]];
        
        similarity = [[DataManager shareDataManager] calcFullSimilarity:specInfo];
        [self.lblFull setText:[NSString stringWithFormat:@"%ld%%", (long)(similarity * 100)]];
    }
    else
    {
        self.lblSimple.text = @"";
        self.lblUpper.text = @"";
        self.lblLower.text = @"";
        self.lblFull.text = @"";
    }
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    if ([strUserID isEqualToString:self.strUserID])
        self.navigationItem.rightBarButtonItem = nil;
    
    if ([[self.userInfo objectForKey:@"is_following"] boolValue])
        [self.navigationItem.rightBarButtonItem setTitle:@"Following"];
    else
        [self.navigationItem.rightBarButtonItem setTitle:@"Follow"];
}

- (void)loadUserInfo
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"friend_id" : self.strUserID,
                              };
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"get_user_info" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        self.userInfo = [dicRet mutableCopy];
        
        [self initView];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
    
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    request = @{
                @"user_id" : strUserID,
                @"poster_id" : self.strUserID,
                };
    NSLog(@"%@", request);
    
    dicRet = [_webMgr requestWithAction:@"get_user_posts" request:request];

    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        self.aryUserPosts = [dicRet objectForKey:@"posts"];
        
        [self.cvPosts reloadData];
        [self.cvPosts.collectionViewLayout invalidateLayout];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
    
    self.lblPosts.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.aryUserPosts.count];
    
    [self.refreshControl endRefreshing];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    if (self.userInfo == nil || self.aryUserPosts == nil)
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(loadUserInfo) userInfo:nil repeats:NO];
}

- (void)tapProfile
{
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"ProfilePhotoView" owner:self options:nil];
    ProfilePhotoView* viewPhoto = [nib objectAtIndex:0];
    
    NSString *strPhotoURL = [self.userInfo objectForKey:@"photo_url"];
    [viewPhoto initView:strPhotoURL];
    AppDelegate* app = [[UIApplication sharedApplication] delegate];
    [app.window addSubview:viewPhoto];
}

- (void)tapPosts
{
    [self performSegueWithIdentifier:@"user_posts" sender:nil];
}

- (void)tapFollowings
{
    [self performSegueWithIdentifier:@"user_friends" sender:@"0"];
}

- (void)tapFollowers
{
    [self performSegueWithIdentifier:@"user_friends" sender:@"1"];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)followFrield:(BOOL)follow
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"friend_id" : self.strUserID,
                              };
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strAPIName = nil;
    if (follow)
        strAPIName = @"follow_friend";
    else
        strAPIName = @"unfollow";
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:strAPIName request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        if (strError != nil && strError.length > 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return NO;
        }
        
        NSString *strSuccess = [dicRet objectForKey:@"success"];
        if (strSuccess != nil && strSuccess.length > 0)
        {
            if ([strAPIName isEqualToString:@"follow_friend"])
                [self.userInfo setValue:@"1" forKey:@"is_following"];
            else if ([strAPIName isEqualToString:@"unfollow"])
                [self.userInfo setValue:@"0" forKey:@"is_following"];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
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

- (IBAction)onFollow:(id)sender
{
    if ([[self.userInfo objectForKey:@"is_following"] boolValue])
        [self followFrield:NO];
    else
        [self followFrield:YES];
    
    if ([[self.userInfo objectForKey:@"is_following"] boolValue])
        [self.navigationItem.rightBarButtonItem setTitle:@"Following"];
    else
        [self.navigationItem.rightBarButtonItem setTitle:@"Follow"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.aryUserPosts == nil)
        return 0;
    
    return self.aryUserPosts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSString *)getTimeIntervalString:(NSDate *)date
{
    NSTimeInterval localDiff = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSTimeInterval interval = -[date timeIntervalSinceNow] - localDiff;
    NSInteger minutes = ((NSInteger)(interval / 60.f) % 60);
    if (minutes == 0)
        minutes = 1;
    
    NSInteger hours = (NSInteger)(interval / 3600.f);
    NSInteger days = (NSInteger)(interval / 86400.f);
    
    NSString *strInterval = nil;
    if (days > 0)
    {
        strInterval = [NSString stringWithFormat:@"%ldd", (long)days];
    }
    else
    {
        if (hours > 0)
        {
            strInterval = [NSString stringWithFormat:@"%ldh", (long)hours];
        }
        else
        {
            if (minutes > 0)
            {
                strInterval = [NSString stringWithFormat:@"%ldm", (long)minutes];
            }
        }
    }
    
    return strInterval;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"postcollectionviewcell";
    
    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSMutableDictionary *postInfo = [self.aryUserPosts objectAtIndex:indexPath.row];
    if (postInfo != nil)
        [cell setPostInfo:postInfo layOut:collectionView.collectionViewLayout];
    
    cell.layer.cornerRadius = 4;
    cell.clipsToBounds = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *postInfo = [self.aryUserPosts objectAtIndex:indexPath.row];
    if (postInfo == nil)
        return;
    
    BOOL found = NO;
//    for (UIViewController *vcPrevious in self.navigationController.viewControllers)
//    {
//        if ([vcPrevious isKindOfClass:[PostDetailViewController class]])
//        {
//            found = YES;
//            PostDetailViewController *vcPostDetail = (PostDetailViewController *)vcPrevious;
//            vcPostDetail.postID = [postInfo objectForKey:@"post_id"];
//            [self.navigationController popToViewController:vcPrevious animated:NO];
//            break;
//        }
//    }
    
    if (!found)
    {
        [self performSegueWithIdentifier:@"postdetail" sender:postInfo];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewWaterfallLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = (self.cvPosts.frame.size.width - 20) / 2;
    collectionViewLayout.itemWidth = cellWidth;
    
    NSMutableDictionary *postInfo = [self.aryUserPosts objectAtIndex:indexPath.row];
    if (postInfo == nil)
        return 0;
    
    CGSize contentSize = [PostCollectionViewCell sizeForPostInfo:postInfo cellWidth:cellWidth];
    return contentSize.height;
}

@end
