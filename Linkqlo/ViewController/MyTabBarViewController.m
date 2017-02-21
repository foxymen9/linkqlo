//
//  MyTabBarViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "MyTabBarViewController.h"

#import "AddPostViewController.h"

#import "WhatsNewViewController.h"
#import "MessagesViewController.h"
#import "DiscoverViewController.h"
#import "MeViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#define TAB_HEIGHT 50

@interface MyTabBarViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UIView *viewTabBar;

@property (nonatomic, retain) UIButton *tabHome;
@property (nonatomic, retain) UIButton *tabMessages;
@property (nonatomic, retain) UIButton *tabPost;
@property (nonatomic, retain) UIButton *tabDiscover;
@property (nonatomic, retain) UIButton *tabMe;

@property (nonatomic, retain) UILabel *lblBadge;

@property (nonatomic, assign) UIImageView *ivPostBack;

@property (nonatomic, assign) UIButton *btnCamera;
@property (nonatomic, assign) UIButton *btnPhotos;
@property (nonatomic, assign) UIButton *btnClose;

@end

@implementation MyTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
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
    if ([segue.identifier isEqualToString:@"post"])
    {
        UINavigationController *vcNavigation = segue.destinationViewController;
        for (UIViewController *vc in vcNavigation.viewControllers)
        {
            if ([vc isKindOfClass:[AddPostViewController class]])
            {
                AddPostViewController *vcPost = (AddPostViewController *)vc;
                vcPost.selectedPhoto = (UIImage *)sender;
            }
        }
    }
}

- (void)loadDatas
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;

//    if (![[DataManager shareDataManager] hasDatas])
//        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(loadDatas) userInfo:nil repeats:NO];
    
    [self updateBadge];
}

- (void) initView
{
    self.viewTabBar = [UIView new];
    self.viewTabBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - TAB_HEIGHT, CGRectGetWidth(self.view.frame), TAB_HEIGHT);
    
    UIImageView *ivBack = [UIImageView new];
    ivBack.image = [UIImage imageNamed:@"tab_back"];
    ivBack.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewTabBar.frame), CGRectGetHeight(self.viewTabBar.frame));
    
    [self.viewTabBar addSubview:ivBack];
    ivBack = nil;
    
    NSInteger buttonWidth = CGRectGetWidth(self.view.frame) / 5;
    NSInteger centerWidth = CGRectGetWidth(self.view.frame) - buttonWidth * 4;
    NSInteger buttonHeight = TAB_HEIGHT;
    
    self.tabHome = [[UIButton alloc] init];
    [self.tabHome.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.tabHome setImage:[UIImage imageNamed:@"tab_btn_home"] forState:UIControlStateNormal];
    [self.tabHome setImage:[UIImage imageNamed:@"tab_btn_home_sel"] forState:UIControlStateSelected];
    [self.tabHome addTarget:self action:@selector(onHome) forControlEvents:UIControlEventTouchUpInside];
    self.tabHome.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    self.tabHome.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.tabHome.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;

//    self.tabHome.center = CGPointMake(buttonWidth / 2, buttonHeight / 2);
    
    [self.viewTabBar addSubview:self.tabHome];
    
    self.tabMessages = [[UIButton alloc] init];
    [self.tabMessages.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.tabMessages setImage:[UIImage imageNamed:@"tab_btn_message"] forState:UIControlStateNormal];
    [self.tabMessages setImage:[UIImage imageNamed:@"tab_btn_message_sel"] forState:UIControlStateSelected];
    [self.tabMessages addTarget:self action:@selector(onMessages) forControlEvents:UIControlEventTouchUpInside];
    self.tabMessages.frame = CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight);
    self.tabMessages.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.tabMessages.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
//    self.tabMessages.center = CGPointMake(buttonWidth * 3 / 2, buttonHeight / 2);
    
    [self.viewTabBar addSubview:self.tabMessages];
    
    self.lblBadge = [[UILabel alloc] init];
    [self.lblBadge setTextColor:[UIColor whiteColor]];
    [self.lblBadge setBackgroundColor:[UIColor redColor]];
    self.lblBadge.frame = CGRectMake(self.tabMessages.frame.origin.x + self.tabMessages.frame.size.width - 32,
                                     self.tabMessages.frame.origin.y + 8, 16, 16);

    self.lblBadge.text = @"1";
    self.lblBadge.textAlignment = NSTextAlignmentCenter;
    self.lblBadge.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
    
    self.lblBadge.clipsToBounds = YES;
    self.lblBadge.layer.cornerRadius = self.lblBadge.frame.size.height / 2;
    
    [self.viewTabBar addSubview:self.lblBadge];
    [self updateBadge];
    
    self.tabPost = [[UIButton alloc] init];
    [self.tabPost.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.tabPost setImage:[UIImage imageNamed:@"tab_btn_post"] forState:UIControlStateNormal];
    [self.tabPost setImage:[UIImage imageNamed:@"tab_btn_post_sel"] forState:UIControlStateSelected];
    [self.tabPost addTarget:self action:@selector(onPost) forControlEvents:UIControlEventTouchUpInside];
    self.tabPost.frame = CGRectMake(buttonWidth * 2, 0, centerWidth, buttonHeight);
    self.tabPost.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.tabPost.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
//    self.tabPost.center = CGPointMake(CGRectGetWidth(tabbarView.frame) / 2, buttonHeight / 2);
    
    [self.viewTabBar addSubview:self.tabPost];
    
    self.tabDiscover = [[UIButton alloc] init];
    [self.tabDiscover.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.tabDiscover setImage:[UIImage imageNamed:@"tab_btn_discover"] forState:UIControlStateNormal];
    [self.tabDiscover setImage:[UIImage imageNamed:@"tab_btn_discover_sel"] forState:UIControlStateSelected];
    [self.tabDiscover addTarget:self action:@selector(onDiscover) forControlEvents:UIControlEventTouchUpInside];
    self.tabDiscover.frame = CGRectMake(buttonWidth * 2 + centerWidth, 0, buttonWidth, buttonHeight);
    self.tabDiscover.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.tabDiscover.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
//    self.tabDiscover.center = CGPointMake(CGRectGetWidth(tabbarView.frame) - buttonWidth * 3 / 2, buttonHeight / 2);
    
    [self.viewTabBar addSubview:self.tabDiscover];
    
    self.tabMe = [[UIButton alloc] init];
    [self.tabMe.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.tabMe setImage:[UIImage imageNamed:@"tab_btn_me"] forState:UIControlStateNormal];
    [self.tabMe setImage:[UIImage imageNamed:@"tab_btn_me_sel"] forState:UIControlStateSelected];
    [self.tabMe addTarget:self action:@selector(onMe) forControlEvents:UIControlEventTouchUpInside];
    self.tabMe.frame = CGRectMake(buttonWidth * 3 + centerWidth, 0, buttonWidth, buttonHeight);
    self.tabMe.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.tabMe.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
//    self.tabMe.center = CGPointMake(CGRectGetWidth(tabbarView.frame) - buttonWidth / 2, buttonHeight / 2);
    
    [self.viewTabBar addSubview:self.tabMe];
    
    [self.view addSubview:self.viewTabBar];
    
    UIImageView *ivPostBack = [UIImageView new];
    ivPostBack.backgroundColor = [UIColor blackColor];
    ivPostBack.alpha = 0.0f;
    ivPostBack.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    [self.view addSubview:ivPostBack];
    self.ivPostBack = ivPostBack;
    
    UITapGestureRecognizer *tapGestur = nil;
    tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePostScreen)];
    self.ivPostBack.userInteractionEnabled = YES;
    [self.ivPostBack addGestureRecognizer:tapGestur];
    tapGestur = nil;
    
    UIButton *btnPhotos = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [btnPhotos setImage:[UIImage imageNamed:@"post_btn_library"] forState:UIControlStateNormal];
    [btnPhotos addTarget:self action:@selector(onPhoto) forControlEvents:UIControlEventTouchUpInside];
    btnPhotos.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 - 55, CGRectGetHeight(self.view.frame) + 120);
    
    [self.view addSubview:btnPhotos];
    self.btnPhotos = btnPhotos;
    
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [btnCamera setImage:[UIImage imageNamed:@"post_btn_camera"] forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(onCamera) forControlEvents:UIControlEventTouchUpInside];
    btnCamera.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 + 55, CGRectGetHeight(self.view.frame) + 120);
    
    [self.view addSubview:btnCamera];
    self.btnCamera = btnCamera;
    
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
    [btnClose setImage:[UIImage imageNamed:@"post_btn_close"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closePostScreen) forControlEvents:UIControlEventTouchUpInside];
    btnClose.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) + 40);
    
    [self.view addSubview:btnClose];
    self.btnClose = btnClose;
    
    [self updateTabBarButtons:0];
}

- (void) updateBadge
{
    NSInteger badgeCount = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    if (badgeCount == 0)
    {
        self.lblBadge.hidden = YES;
    }
    else
    {
        self.lblBadge.hidden = NO;
        [self.lblBadge setText:[NSString stringWithFormat:@"%d", (int)badgeCount]];
        [self.lblBadge sizeToFit];
        if (self.lblBadge.frame.size.width < self.lblBadge.frame.size.height)
            self.lblBadge.frame = CGRectMake(self.lblBadge.frame.origin.x,
                                             self.lblBadge.frame.origin.y,
                                             self.lblBadge.frame.size.height,
                                             self.lblBadge.frame.size.height);
    }
}

- (void) onHome
{
    [self updateTabBarButtons:0];

    UINavigationController *homeNav = (UINavigationController *)[self.viewControllers objectAtIndex:0];
    
    if ([homeNav isKindOfClass:[UINavigationController class]])
    {
        NSArray *viewControllers = homeNav.viewControllers;
        
        for (UIViewController *vc in viewControllers)
        {
            if ([vc isKindOfClass:[WhatsNewViewController class]])
            {
                [homeNav popToViewController:vc animated:NO];
                [(WhatsNewViewController *)vc scrollToTop];
            }
        }
    }
}

- (void) onMessages
{
    [self updateTabBarButtons:1];

    UINavigationController *homeNav = (UINavigationController *)[self.viewControllers objectAtIndex:1];
    
    if ([homeNav isKindOfClass:[UINavigationController class]])
    {
        NSArray *viewControllers = homeNav.viewControllers;
        
        for (UIViewController *vc in viewControllers)
        {
            if ([vc isKindOfClass:[MessagesViewController class]])
                [homeNav popToViewController:vc animated:NO];
        }
    }
}

- (void) onPost
{
    //[self updateTabBarButtons:2];
    
    [self.view bringSubviewToFront:self.ivPostBack];
    
    [self.view bringSubviewToFront:self.btnCamera];
    [self.view bringSubviewToFront:self.btnPhotos];
    [self.view bringSubviewToFront:self.btnClose];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.ivPostBack.alpha = 0.8f;
        
        self.btnCamera.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 - 55, CGRectGetHeight(self.view.frame) - 120);
        self.btnPhotos.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 + 55, CGRectGetHeight(self.view.frame) - 120);
        self.btnClose.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) - 40);
       
    } completion:^(BOOL finished) {
        
    }];
}

- (void) onDiscover
{
    [self updateTabBarButtons:3];

    UINavigationController *homeNav = (UINavigationController *)[self.viewControllers objectAtIndex:3];
    
    if ([homeNav isKindOfClass:[UINavigationController class]])
    {
        NSArray *viewControllers = homeNav.viewControllers;
        
        for (UIViewController *vc in viewControllers)
        {
            if ([vc isKindOfClass:[DiscoverViewController class]])
                [homeNav popToViewController:vc animated:NO];
        }
    }
}

- (void) onMe
{
    [self updateTabBarButtons:4];

    UINavigationController *homeNav = (UINavigationController *)[self.viewControllers objectAtIndex:4];
    
    if ([homeNav isKindOfClass:[UINavigationController class]])
    {
        NSArray *viewControllers = homeNav.viewControllers;
        
        for (UIViewController *vc in viewControllers)
        {
            if ([vc isKindOfClass:[MeViewController class]])
                [homeNav popToViewController:vc animated:NO];
        }
    }
}

- (void) updateTabBarButtons:(int) index
{
    self.tabHome.selected = index == 0;
    self.tabMessages.selected = index == 1;
    self.tabPost.selected = index == 2;
    self.tabDiscover.selected = index == 3;
    self.tabMe.selected = index == 4;
    
    [self setSelectedIndex:index];
}

- (void)selectPhoto:(UIImagePickerControllerSourceType)sourceType
{
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = sourceType;
        picker.delegate = self;
        picker.editing = NO;
        picker.allowsEditing = YES;
        
        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
}

- (void) onCamera
{
    [self closePostScreen];
    
    [self selectPhoto:UIImagePickerControllerSourceTypeCamera];
    
//    [self gotoPostScreen];
}

- (void) onPhoto
{
    [self closePostScreen];
    
    [self selectPhoto:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
//    [self gotoPostScreen];
}

- (void) closePostScreen
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.ivPostBack.alpha = 0.0f;
        
        self.btnCamera.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 - 55, CGRectGetHeight(self.view.frame) + 120);
        self.btnPhotos.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2 + 55, CGRectGetHeight(self.view.frame) + 120);
        self.btnClose.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) + 40);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) gotoPostScreen:(UIImage *)selectedPhoto
{
    [self performSegueWithIdentifier:@"post" sender:selectedPhoto];
}

- (void) hideTabBar
{
    self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.tabBar.frame), CGRectGetHeight(self.tabBar.frame));
    self.viewTabBar.frame = CGRectMake(self.viewTabBar.frame.origin.x, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.viewTabBar.frame), CGRectGetHeight(self.viewTabBar.frame));
}

- (void) showTabBar
{
    self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.tabBar.frame), CGRectGetWidth(self.tabBar.frame), CGRectGetHeight(self.tabBar.frame));
    self.viewTabBar.frame = CGRectMake(self.viewTabBar.frame.origin.x, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.viewTabBar.frame), CGRectGetWidth(self.viewTabBar.frame), CGRectGetHeight(self.viewTabBar.frame));
}

- (BOOL) isShowTabBar
{
    return self.viewTabBar.frame.origin.y < CGRectGetHeight(self.view.frame);
}

#pragma mark UINavigationControllerDelegate

#pragma mark UIImagePickerControllerDelegate

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 640;
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution)
    {
        CGFloat ratio = width/height;
        if (ratio > 1)
        {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"image %@", NSStringFromCGSize(imageCopy.size));
    
    return imageCopy;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *postPhoto = [self scaleAndRotateImage:editedImage];

        [self gotoPostScreen:postPhoto];
    }];
}

@end
