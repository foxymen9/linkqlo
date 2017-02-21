//
//  PostListViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "PostListViewController.h"

#import "PostCollectionViewCell.h"
#import "UICollectionViewWaterfallLayout.h"

#import "MyTabBarViewController.h"
#import "PostDetailViewController.h"

#import "UIImageView+WebCache.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import <QuartzCore/QuartzCore.h>

@interface PostListViewController () <UICollectionViewDelegateWaterfallLayout>
{
    BOOL _isHiding;
    BOOL _isShowing;
    CGRect _rcNavBarFrame;
    CGRect _rcCollectionView;
    
    CGFloat _scrollOffset;
}

@property (nonatomic, assign) IBOutlet UICollectionView *cvPosts;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, retain) NSMutableArray *aryPosts;

@end

@implementation PostListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _isHiding = NO;
    _isShowing = NO;
    
    self.navigationController.navigationBarHidden = NO;
    
    _rcNavBarFrame = self.navigationController.navigationBar.frame;
    _rcCollectionView = self.cvPosts.frame;
    
    _scrollOffset = 0;
    
    UINib *cellNib = [UINib nibWithNibName:@"PostCollectionViewCell" bundle:nil];
    [self.cvPosts registerNib:cellNib forCellWithReuseIdentifier:@"postcollectionviewcell"];
    
    UICollectionViewWaterfallLayout *layout = [[UICollectionViewWaterfallLayout alloc] init];
    layout.delegate = self;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.cvPosts.collectionViewLayout = layout;

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(loadPosts) forControlEvents:UIControlEventValueChanged];
    [self.cvPosts addSubview:self.refreshControl];
    
    if ([self.strAPIName isEqualToString:@"get_user_posts"])
    {
        NSInteger userID = [[self.dicRequest objectForKey:@"user_id"] integerValue];
        NSInteger posterID = [[self.dicRequest objectForKey:@"poster_id"] integerValue];
        if (userID == posterID)
            self.navigationItem.rightBarButtonItem = nil;
        else
        {
            if (self.isFollowing)
                [self.navigationItem.rightBarButtonItem setTitle:@"Following"];
            else
                [self.navigationItem.rightBarButtonItem setTitle:@"Follow"];
        }
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
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
//        vcPostDetail.postInfo = sender;
    }
}

- (void)loadPosts
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSLog(@"%@", self.dicRequest);
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:self.strAPIName request:self.dicRequest];
    
    [JSWaiter HideWaiter];

    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSMutableArray *aryPosts = [dicRet objectForKey:@"posts"];
        if (aryPosts != nil)
            self.aryPosts = [aryPosts mutableCopy];
        else
            self.aryPosts = nil;
        
        [self.cvPosts reloadData];
        [self.cvPosts.collectionViewLayout invalidateLayout];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }

    [self.refreshControl endRefreshing];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL needsRefresh = [[NSUserDefaults standardUserDefaults] boolForKey:@"NeedsToRefresh"];
    if ((self.strAPIName != nil && self.strAPIName.length > 0 && self.dicRequest != nil && self.aryPosts == nil) || needsRefresh)
    {
        if (needsRefresh)
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NeedsToRefresh"];
        
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(loadPosts) userInfo:nil repeats:NO];
    }
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)followFrield:(BOOL)follow
{
    [JSWaiter ShowWaiter:self title:@"Processing..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    NSString *strPosterID = [self.dicRequest objectForKey:@"poster_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"friend_id" : strPosterID,
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
                self.isFollowing = YES;
            else if ([strAPIName isEqualToString:@"unfollow"])
                self.isFollowing = NO;
            
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
    if (self.isFollowing)
        [self followFrield:NO];
    else
        [self followFrield:YES];
    
    if (self.isFollowing)
        [self.navigationItem.rightBarButtonItem setTitle:@"Following"];
    else
        [self.navigationItem.rightBarButtonItem setTitle:@"Follow"];
}

#pragma mark UIScrollViewDelegate

- (void)hideBars
{
    if (_isHiding || _isShowing)
        return;
    
    _isHiding = YES;
    
    [UIView animateWithDuration: 0.3 delay: 0 options: UIViewAnimationOptionCurveLinear animations: ^(void) {
        self.cvPosts.frame = CGRectMake(0, -44, self.view.frame.size.width, self.view.frame.size.height + 44);
        
        MyTabBarViewController *tabbarController = (MyTabBarViewController *)self.navigationController.tabBarController;
        [tabbarController hideTabBar];
        
        CGFloat navBarX = self.navigationController.navigationBar.frame.origin.x;
        CGFloat navBarWidth = self.navigationController.navigationBar.frame.size.width;
        CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
        self.navigationController.navigationBar.frame = CGRectMake(navBarX, 0, navBarWidth, navBarHeight);
    } completion: ^(BOOL finished) {
        if(finished) {
            _isHiding = NO;
            [self.navigationController.navigationBar setHidden: YES];
        }
    }];
}

- (void)showBars
{
    if (_isShowing || _isHiding)
        return;
    
    _isShowing = YES;
    
    [UIView animateWithDuration: 0.3 animations: ^(void) {
        MyTabBarViewController *tabbarController = (MyTabBarViewController *)self.navigationController.tabBarController;
        [tabbarController showTabBar];
        
        [self.navigationController.navigationBar setHidden: NO];
        self.navigationController.navigationBar.frame = _rcNavBarFrame;
        
        self.cvPosts.frame = _rcCollectionView;
    } completion:^(BOOL finished) {
        if (finished) {
            _isShowing = NO;
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.cvPosts)
        return;
    
    CGFloat currentScrollOffset = scrollView.contentOffset.y;
    if (currentScrollOffset < 0)
        return;
    
    if (currentScrollOffset <= _scrollOffset)
        [self showBars];
    else
        [self hideBars];
    
    _scrollOffset = currentScrollOffset;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.aryPosts == nil)
        return 0;
    
    if (self.aryPosts.count == 0)
    {
        // Display a message when the table is empty
        NSString *strMessage = @"No post is currently available.\nPlease pull down to refresh.";
        if (collectionView.backgroundView == nil)
        {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, collectionView.bounds.size.width, collectionView.bounds.size.height)];
            
            messageLabel.text = strMessage;
            messageLabel.textColor = [UIColor lightGrayColor];
            messageLabel.numberOfLines = 2;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont italicSystemFontOfSize:18.0f];
            [messageLabel sizeToFit];
            
            collectionView.backgroundView = messageLabel;
        }
        else if (collectionView.backgroundView != nil && [collectionView.backgroundView isKindOfClass:[UILabel class]])
        {
            [(UILabel *)collectionView.backgroundView setText:strMessage];
        }
    }
    else
    {
        if (collectionView.backgroundView != nil)
        {
            [collectionView.backgroundView removeFromSuperview];
            collectionView.backgroundView = nil;
        }
    }
    
    return self.aryPosts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"postcollectionviewcell";
    
    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSMutableDictionary *postInfo = [self.aryPosts objectAtIndex:indexPath.row];
    
    if (postInfo != nil)
        [cell setPostInfo:postInfo layOut:collectionView.collectionViewLayout];
    
    cell.layer.cornerRadius = 4;
    cell.clipsToBounds = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.aryPosts == nil)
        return;
    
    NSMutableDictionary *postInfo = [self.aryPosts objectAtIndex:indexPath.row];
    if (postInfo == nil)
        return;

    [self showBars];
    [self performSegueWithIdentifier:@"postdetail" sender:postInfo];
}

#pragma mark UICollectionViewDelegateWaterfallLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewWaterfallLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = (self.cvPosts.frame.size.width - 20) / 2;
    collectionViewLayout.itemWidth = cellWidth;
    
    NSMutableDictionary *postInfo = [self.aryPosts objectAtIndex:indexPath.row];
    if (postInfo == nil)
        return 0;

    CGSize contentSize = [PostCollectionViewCell sizeForPostInfo:postInfo cellWidth:cellWidth];
    return contentSize.height;
}

@end
