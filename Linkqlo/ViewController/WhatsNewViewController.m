//
//  WhatsNewViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "WhatsNewViewController.h"

#import "PostCollectionViewCell.h"
#import "UICollectionViewWaterfallLayout.h"

#import "MyTabBarViewController.h"
#import "PostDetailViewController.h"

#import "Prepare1ViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface WhatsNewViewController () <UICollectionViewDelegateWaterfallLayout>
{
    BOOL _isFirstTime;
    int _selectecMenuIndex;
    
    UIButton *_btnAll;

    BOOL _isHiding;
    BOOL _isShowing;
    CGRect _rcNavBarFrame;
    CGRect _rcCollectionView;
    
    CGFloat _scrollOffset;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMenu;
@property (nonatomic, assign) IBOutlet UIView *viewMenu;

@property (nonatomic, assign) IBOutlet UICollectionView *cvPosts;

@property (nonatomic, assign) IBOutlet UIBarButtonItem *btnPop;

@property (nonatomic, retain) NSMutableArray *aryNewPosts;
@property (nonatomic, retain) NSMutableArray *aryDisplayPosts;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation WhatsNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _isFirstTime = YES;
    _btnAll = nil;
    _selectecMenuIndex = 0;
    
    _isHiding = NO;
    _isShowing = NO;
    
    _rcNavBarFrame = self.navigationController.navigationBar.frame;
    _rcCollectionView = self.cvPosts.frame;
    
    _scrollOffset = 0;
    
    self.aryDisplayPosts = [[NSMutableArray alloc] init];
    
    [self _initView];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(getNewPosts) forControlEvents:UIControlEventValueChanged];
    [self.cvPosts addSubview:self.refreshControl];
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
        vcPostDetail.postID = [NSString stringWithFormat:@"%@", [postInfo objectForKey:@"post_id"]];
        //        vcPostDetail.postInfo = sender;
    }
}

- (void)getNewPosts
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
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"get_new_posts" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        self.aryNewPosts = [dicRet objectForKey:@"posts"];
        
        if (_isFirstTime)
        {
            _isFirstTime = NO;
            
            // Select "All" button.
            [self onMenu:_btnAll];
        }
        else
        {
            // Update UI with currently selected buttons.
            [self onMenu:nil];
        }
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
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.viewMenu.frame = CGRectMake(self.viewMenu.frame.origin.x, self.viewMenu.frame.origin.y, CGRectGetWidth(self.viewMenu.frame), 0);
    [self.btnPop setImage:[UIImage imageNamed:@"whatsnew_btn_pop"]];

    BOOL needsRefresh = [[NSUserDefaults standardUserDefaults] boolForKey:@"NeedsToRefresh"];
    if (self.aryNewPosts == nil || needsRefresh)
    {
        if (needsRefresh)
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NeedsToRefresh"];
        
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(getNewPosts) userInfo:nil repeats:NO];
    }
}

- (void) _initView
{
    UINib *cellNib = [UINib nibWithNibName:@"PostCollectionViewCell" bundle:nil];
    [self.cvPosts registerNib:cellNib forCellWithReuseIdentifier:@"postcollectionviewcell"];
    
    UICollectionViewWaterfallLayout *layout = [[UICollectionViewWaterfallLayout alloc] init];
    layout.delegate = self;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.cvPosts.collectionViewLayout = layout;
    
    NSMutableArray *aryTags = [[DataManager shareDataManager] getClothingTypesArray];
    
    float width = 80; float height = 24; float gap = 10;
    for (int n = 0 ; n < aryTags.count + 1; n ++) {
        
        UIButton *button = [[UIButton alloc] init];

        if (n == 0)
        {
            button.tag = n + 1;
            [button setTitle:@"All" forState:UIControlStateNormal];
        }
        else
        {
            button.tag = [[aryTags[n - 1] objectForKey:@"clothing_id"] integerValue] + 1;
            NSString *strTitle = [NSString stringWithFormat:@"%@", [aryTags[n - 1] objectForKey:@"clothing_type"]];
            [button setTitle:strTitle forState:UIControlStateNormal];
        }

        button.frame = CGRectMake(0, 0, width, height);
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = height / 2;
        button.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
//        button.layer.borderColor = [[DataManager shareDataManager] getBackgroundColor].CGColor;
//        [button setTitleColor:[[DataManager shareDataManager] getBackgroundColor] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor blackColor].CGColor;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.center = CGPointMake(gap + width / 2 + (width + gap) * n, CGRectGetHeight(self.svMenu.frame) / 2);
        
        [button addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.svMenu addSubview:button];
        
        if (n == 0)
            _btnAll = button;
    }
    
    self.svMenu.contentSize = CGSizeMake(gap + (width + gap) * (aryTags.count + 1), CGRectGetHeight(self.svMenu.frame));
}

- (void)scrollToTop
{
    [self.cvPosts setContentOffset:CGPointMake(self.cvPosts.contentOffset.x, 0)];
}

- (IBAction)onAddPeople:(id)sender
{
    [self performSegueWithIdentifier:@"addpeople" sender:nil];
}

- (IBAction)onPop:(id)sender
{
    [UIView animateWithDuration:0.3f animations:^{
        if(CGRectGetHeight(self.viewMenu.frame) == 50)
        {
            self.viewMenu.frame = CGRectMake(self.viewMenu.frame.origin.x, self.viewMenu.frame.origin.y, CGRectGetWidth(self.viewMenu.frame), 0);
            
            [self.btnPop setImage:[UIImage imageNamed:@"whatsnew_btn_pop"]];
        }
        else
        {
            self.viewMenu.frame = CGRectMake(self.viewMenu.frame.origin.x, self.viewMenu.frame.origin.y, CGRectGetWidth(self.viewMenu.frame), 50);
            
            [self.btnPop setImage:[UIImage imageNamed:@"whatsnew_btn_pop_up"]];
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)onMenu:(id)sender
{
    [self.aryDisplayPosts removeAllObjects];
    NSArray *subviews = self.svMenu.subviews;
    
    UIButton *button = (UIButton *)sender;
    if (button == nil)
    {
        for (UIView *subview in subviews)
        {
            if ([subview isKindOfClass:[UIButton class]] && ((UIButton *)subview).isSelected)
            {
                if (self.aryNewPosts != nil)
                {
                    if (subview.tag == 1)
                    {
                        [self.aryDisplayPosts addObjectsFromArray:self.aryNewPosts];
                    }
                    else
                    {
                        NSInteger clothingID = subview.tag - 1;
                        
                        for (NSMutableDictionary *postInfo in self.aryNewPosts)
                        {
                            if ([[postInfo objectForKey:@"clothing_id"] integerValue] == clothingID)
                            {
                                [self.aryDisplayPosts addObject:postInfo];
                            }
                        }
                    }
                }
            }
        }
    }
    else
    {
        for (UIView *subview in subviews)
        {
            if ([subview isKindOfClass:[UIButton class]])
            {
                if (button.tag == 1)
                {
                    if (subview == button)
                    {
                        button.selected = YES;
                    }
                    else
                    {
                        ((UIButton *)subview).selected = NO;
                    }
                }
                else
                {
                    if (subview.tag == 1)
                    {
                        ((UIButton *)subview).selected = NO;
                    }
                    else if (subview == button)
                    {
                        button.selected = !button.isSelected;
                    }
                }
                
                if (((UIButton *)subview).isSelected)
                {
//                    subview.backgroundColor = [[DataManager shareDataManager] getBackgroundColor];
                    subview.backgroundColor = [UIColor blackColor];
                    [(UIButton *)subview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    
                    if (self.aryNewPosts != nil)
                    {
                        if (subview.tag == 1)
                        {
                            [self.aryDisplayPosts addObjectsFromArray:self.aryNewPosts];
                        }
                        else
                        {
                            NSInteger clothingID = subview.tag - 1;
                            
                            for (NSMutableDictionary *postInfo in self.aryNewPosts)
                            {
                                if ([[postInfo objectForKey:@"clothing_id"] integerValue] == clothingID)
                                {
                                    [self.aryDisplayPosts addObject:postInfo];
                                }
                            }
                        }
                    }
                }
                else
                {
                    subview.backgroundColor = [UIColor whiteColor];
//                    [(UIButton *)subview setTitleColor:[[DataManager shareDataManager] getBackgroundColor] forState:UIControlStateNormal];
                    [(UIButton *)subview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
        }
    }
    
    [self.cvPosts reloadData];
    [self.cvPosts.collectionViewLayout invalidateLayout];
}

#pragma mark UIScrollViewDelegate

- (void)hideBars
{
    if (_isHiding || _isShowing)
        return;
    
    _isHiding = YES;
    
    if (CGRectGetHeight(self.viewMenu.frame) > 0)
    {
        self.viewMenu.frame = CGRectMake(self.viewMenu.frame.origin.x, self.viewMenu.frame.origin.y, CGRectGetWidth(self.viewMenu.frame), 0);
        [self.btnPop setImage:[UIImage imageNamed:@"whatsnew_btn_pop"]];
    }

    self.viewMenu.hidden = YES;
    
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

            self.viewMenu.hidden = NO;
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
    if (self.aryDisplayPosts == nil)
        return 0;
    
    if (self.aryDisplayPosts.count == 0)
    {
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
    
    return self.aryDisplayPosts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"postcollectionviewcell";
    
    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    

    NSMutableDictionary *postInfo = [self.aryDisplayPosts objectAtIndex:indexPath.row];
    
    if (postInfo != nil)
        [cell setPostInfo:postInfo layOut:collectionView.collectionViewLayout];
    
    cell.layer.cornerRadius = 4;
    cell.clipsToBounds = YES;
    
    return cell;
}

- (void)gotoPrepareScreen
{
    Prepare1ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Prepare1"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSMutableArray *specInfo = [userInfo objectForKey:@"spec"];
    if (specInfo == nil || [specInfo count] == 0)
    {
        [self showBars];
        [self gotoPrepareScreen];
        return;
    }

    if (self.aryDisplayPosts == nil)
        return;
    
    NSMutableDictionary *postInfo = [self.aryDisplayPosts objectAtIndex:indexPath.row];
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
    
    NSMutableDictionary *postInfo = [self.aryDisplayPosts objectAtIndex:indexPath.row];
    if (postInfo == nil)
        return 0;
    
    CGSize contentSize = [PostCollectionViewCell sizeForPostInfo:postInfo cellWidth:cellWidth];
    return contentSize.height;
}

@end
