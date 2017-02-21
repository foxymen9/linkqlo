//
//  PostDetailViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "PostDetailViewController.h"

#import "PostListViewController.h"
#import "UserProfileViewController.h"

#import "CommentTableViewCell.h"
#import "ContactTableViewCell.h"
#import "SliderTableViewCell.h"

#import "KILabel.h"
#import "InsetTextField.h"
#import "UIImageView+WebCache.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface PostDetailViewController () <UIActionSheetDelegate, CommentTableViewCellDelegate, MFMailComposeViewControllerDelegate>
{
    NSString *_strKeyword;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UIView *viewMain;
@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;
@property (nonatomic, assign) IBOutlet UILabel *lblName;
@property (nonatomic, assign) IBOutlet UILabel *lblPercent;
@property (nonatomic, assign) IBOutlet UILabel *lblUpdate;

@property (nonatomic, assign) IBOutlet UIScrollView *svImages;
@property (nonatomic, assign) IBOutlet UIPageControl *pgImages;

@property (nonatomic, assign) IBOutlet UIView *viewContent;
@property (nonatomic, assign) IBOutlet KILabel *lblContent;

@property (nonatomic, assign) IBOutlet UIView *viewClothing;
@property (nonatomic, assign) IBOutlet UILabel *lblClothing;
@property (nonatomic, assign) IBOutlet UILabel *lblLike;
@property (nonatomic, assign) IBOutlet UILabel *lblReply;
@property (nonatomic, assign) IBOutlet UILabel *lblShare;

@property (nonatomic, assign) IBOutlet UIView *viewReport;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar1;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar2;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar3;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar4;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar5;
@property (nonatomic, assign) IBOutlet UILabel *lblBrand;
@property (nonatomic, assign) IBOutlet UILabel *lblModel;
@property (nonatomic, assign) IBOutlet UILabel *lblSize;
@property (nonatomic, assign) IBOutlet UILabel *lblRecommend;

@property (nonatomic, assign) IBOutlet UIView *viewFitting;
@property (nonatomic, assign) IBOutlet UITableView *tvFittingReport;

@property (nonatomic, assign) IBOutlet UIView *viewOthers;
@property (nonatomic, assign) IBOutlet UILabel *lblCommentCount;
@property (nonatomic, assign) IBOutlet UITableView *tvReplies;

@property (nonatomic, assign) IBOutlet UIView *viewReply;
@property (nonatomic, assign) IBOutlet InsetTextField *txtReply;

@property (nonatomic, assign) IBOutlet UITableView *tvContacts;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, retain) NSMutableArray *aryKeys1;
@property (nonatomic, retain) NSMutableArray *aryValues1;

@property (nonatomic, retain) NSMutableArray *aryKeys2;
@property (nonatomic, retain) NSMutableArray *aryValues2;

@property (nonatomic, retain) NSMutableArray *aryReplies;
@property (nonatomic, retain) NSMutableArray *aryContacts;
@property (nonatomic, retain) NSMutableArray *aryDisplay;
@property (nonatomic, retain) NSMutableDictionary *postDetailInfo;

@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.ivProfile.layer.masksToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    self.ivProfile.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.ivProfile.layer.borderColor = [[UIColor blackColor] CGColor];
    
//    self.txtReply.borderStyle = UITextBorderStyleLine;
    
    self.txtReply.layer.cornerRadius = 5;
    self.txtReply.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.txtReply.layer.borderColor = [[UIColor colorWithRed:98.f / 255.f green:98.f / 255.f blue:98.f / 255.f alpha:1.f] CGColor];
    
    self.postDetailInfo = nil;

//    UITapGestureRecognizer *tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
//    [self.svMain addGestureRecognizer:tapGestur];
//    tapGestur = nil;
    UITapGestureRecognizer *tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfile)];
    [self.ivProfile addGestureRecognizer:tapGestur];
    tapGestur = nil;
    
    tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfile)];
    [self.lblName addGestureRecognizer:tapGestur];
    tapGestur = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(getPostDetails) forControlEvents:UIControlEventValueChanged];
    [self.svMain addSubview:self.refreshControl];
    
    self.tvContacts.hidden = YES;
    self.tvContacts.backgroundColor = [UIColor whiteColor];
    
    self.tvContacts.layer.shadowOffset = CGSizeMake(1, 0);
    self.tvContacts.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.tvContacts.layer.shadowRadius = 5;
    self.tvContacts.layer.shadowOpacity = 1;

    self.aryContacts = [[NSMutableArray alloc] init];
    
//    for (NSMutableDictionary *userInfo in [[DataManager shareDataManager] getUsernamesArray])
//    {
//        NSString *strPhotoURL = [userInfo objectForKey:@"photo_url"];
//        NSString *strContent = [NSString stringWithFormat:@"%@ %@", [userInfo objectForKey:@"first_name"], [userInfo objectForKey:@"last_name"]];
//        NSString *strDetails = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
//        
//        NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                         strPhotoURL, @"photo",
//                                         strContent, @"content",
//                                         strDetails, @"details",
//                                         nil];
//        
//        [self.aryContacts addObject:itemInfo];
//    }
//
//    for (NSMutableDictionary *brandInfo in [[DataManager shareDataManager] getBrandsArray])
//    {
//        NSString *strContent = [brandInfo objectForKey:@"brand_name"];
//        
//        NSArray* words = [strContent componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        NSString* noSpaceString = [words componentsJoinedByString:@""];
//        NSString *strDetails = [noSpaceString lowercaseString];
//        
//        NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                         strContent, @"content",
//                                         strDetails, @"details",
//                                         nil];
//        
//        [self.aryContacts addObject:itemInfo];
//    }
    
    _strKeyword = nil;

    self.lblContent.automaticLinkDetectionEnabled = YES;
    self.lblContent.linkDetectionTypes = KILinkDetectionTypeUserHandle | KILinkDetectionTypeHashtag;
    self.lblContent.linkTapHandler = ^(KILinkType linkType, NSString *string, NSRange range) {
        if (linkType == KILinkTypeUserHandle || linkType == KILinkTypeHashtag)
        {
            [self tapLink:string];
        }
    };
    
    [self.tvFittingReport registerNib:[UINib nibWithNibName:@"SliderTableViewCell" bundle:nil] forCellReuseIdentifier:@"slider"];

    self.tvContacts.frame = CGRectMake(self.svMain.frame.origin.x,
                                       self.svMain.frame.origin.y - self.tvContacts.frame.size.height,
                                       self.svMain.frame.size.width,
                                       self.tvContacts.frame.size.height);
}

- (void)tapView
{
    [self.txtReply resignFirstResponder];
}

- (void)tapProfile
{
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return;
    
    NSString *strCurUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    NSString *strPosterUserID = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"user_id"]];
    if ([strCurUserID isEqualToString:strPosterUserID])
        return;
    
    [self performSegueWithIdentifier:@"userprofile" sender:nil];
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
    if ([segue.identifier isEqualToString:@"userprofile"])
    {
        NSString *strUserID = nil;
        if (sender != nil)
            strUserID = (NSString *)sender;
        else
            strUserID = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"user_id"]];
        
        UserProfileViewController *vcUserProfie = segue.destinationViewController;
        vcUserProfie.strUserID = strUserID;
    }
    else if ([segue.identifier isEqualToString:@"postlist"])
    {
        NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
        
        PostListViewController *vcPostList = segue.destinationViewController;
        NSMutableDictionary *brandInfo = sender;
        vcPostList.title = [NSString stringWithFormat:@"%@", [brandInfo objectForKey:@"brand_name"]];
        vcPostList.strAPIName = @"search_by_brand";
        vcPostList.dicRequest = @{@"user_id" : strUserID, @"brand_name" : [NSString stringWithFormat:@"%@", [brandInfo objectForKey:@"brand_name"]]};
    }
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

- (void)initViews
{
    CGFloat contentHeight = 0;
    
    if (self.postDetailInfo != nil)
    {
        NSString *strContent = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"content"]];
//        [self setTitle:strContent];
        
        NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"user_photo_url"]];
        [self.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL]];

        NSString *strUserName = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"first_name"]];
        if (strUserName.length == 0)
            strUserName = [NSString stringWithFormat:@"@%@", [self.postDetailInfo objectForKey:@"user_name"]];
        
        self.lblName.text = strUserName;

        NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        NSInteger myID = [[userInfo objectForKey:@"user_id"] integerValue];
        NSInteger posterID = [[self.postDetailInfo objectForKey:@"user_id"] integerValue];
        
        self.lblPercent.text = @"";

        if (myID == posterID)
            self.lblPercent.hidden = YES;
        else
        {
            NSString *myGender = [NSString stringWithFormat:@"%@", [[[DataManager shareDataManager] getUserInfo] objectForKey:@"gender"]];
            NSString *userGender = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"gender"]];
            if ([myGender isEqualToString:userGender])
            {
                self.lblPercent.hidden = NO;
                
                NSInteger bsiType;
                NSInteger clothingID = [[self.postDetailInfo objectForKey:@"clothing_id"] integerValue];
                
                NSMutableDictionary *specInfo = [self.postDetailInfo objectForKey:@"specs"];
                float similarity = [[DataManager shareDataManager] calcSimilarity:specInfo clothingID:clothingID bsiType:&bsiType];
                if (similarity == 0)
                {
                    bsiType = 0;
                    similarity = [[DataManager shareDataManager] calcSimpleSimilarity:specInfo];
                }
                
                NSString *strBSIType = nil;
                if (bsiType == 0) strBSIType = @"Simple Match";
                else if (bsiType == 1) strBSIType = @"Full Body Match";
                else if (bsiType == 2) strBSIType = @"Upper Body Match";
                else if (bsiType == 3) strBSIType = @"Lower Body Match";
                else if (bsiType == 4) strBSIType = @"Simple Match";
                
                [self.lblPercent setText:[NSString stringWithFormat:@"%ld%% %@", (long)(similarity * 100), strBSIType]];
            }
            else
            {
                self.lblPercent.hidden = YES;
            }
        }

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strUpdatedTime = [self.postDetailInfo objectForKey:@"updated"];
        if (strUpdatedTime == nil)
            strUpdatedTime = [self.postDetailInfo objectForKey:@"updated"];
        
        NSDate *lastUpdateTime = [formatter dateFromString:[NSString stringWithFormat:@"%@", strUpdatedTime]];
        NSString *strUdate = [NSString stringWithFormat:@"%@", [self getTimeIntervalString:lastUpdateTime]];
        self.lblUpdate.text = strUdate;
        
        NSInteger imageWidth = [[self.postDetailInfo objectForKey:@"photo_width"] integerValue];
        NSInteger imageHeight = [[self.postDetailInfo objectForKey:@"photo_height"] integerValue];
        
        if (imageWidth != 0 && imageHeight != 0)
            self.viewMain.frame = CGRectMake(self.viewMain.frame.origin.x, self.viewMain.frame.origin.y, self.viewMain.frame.size.width, self.viewMain.frame.size.width * imageHeight / imageWidth + 65);
        else
            self.viewMain.frame = CGRectMake(self.viewMain.frame.origin.x, self.viewMain.frame.origin.y, self.viewMain.frame.size.width, self.viewMain.frame.size.width / 4 * 3 + 65);
        
        contentHeight += self.viewMain.frame.origin.y + self.viewMain.frame.size.height;
        
        NSURL *urlCoverPhoto = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"photo_url"]]];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.svImages addSubview:imageView];
        
        CGRect curRect = self.svImages.frame;
        imageView.frame = CGRectMake(0, 0, curRect.size.width, curRect.size.height);
        [imageView setImageWithURL:urlCoverPhoto];
        
        self.pgImages.hidden = YES;
        self.pgImages.numberOfPages = 1;
        self.svImages.contentSize = CGSizeMake(curRect.size.width, curRect.size.height);
        
        NSArray *photos = [self.postDetailInfo objectForKey:@"photos"];
        if (photos != nil && photos.count > 0)
        {
            for (NSMutableDictionary *imageInfo in photos)
            {
                NSURL *urlPhoto = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [imageInfo objectForKey:@"photo_url"]]];
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.backgroundColor = [UIColor blackColor];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self.svImages addSubview:imageView];
                
                imageView.frame = CGRectMake(self.svImages.contentSize.width, 0, curRect.size.width, curRect.size.height);
                [imageView setImageWithURL:urlPhoto];

                if (self.pgImages.hidden == YES)
                    self.pgImages.hidden = NO;
                
                self.pgImages.numberOfPages ++;
                self.svImages.contentSize = CGSizeMake(self.svImages.contentSize.width + curRect.size.width, curRect.size.height);
            }
        }
        
        [self.lblContent setText:strContent];
        
        CGRect curFrame = self.lblContent.frame;
        CGSize contentSize = [self.lblContent sizeThatFits:CGSizeMake(curFrame.size.width, 99999.0f)];
        self.viewContent.frame = CGRectMake(self.viewContent.frame.origin.x, contentHeight, self.viewContent.frame.size.width, contentSize.height + 16);
        
        contentHeight += self.viewContent.frame.size.height;
        
        self.viewClothing.frame = CGRectMake(self.viewClothing.frame.origin.x, contentHeight, self.viewClothing.frame.size.width, self.viewClothing.frame.size.height);
        
        // lblClothing
        self.lblClothing.textColor = [UIColor blackColor];
        
        NSInteger clothingID = [[self.postDetailInfo objectForKey:@"clothing_id"] integerValue];
        if (clothingID != 0)
            self.lblClothing.text = [[DataManager shareDataManager] getClothingTypeName:clothingID];
        else
            self.lblClothing.text = @"";
        
        curRect = self.lblClothing.frame;
        CGSize expectSize = [self.lblClothing sizeThatFits:CGSizeMake(99999.0f, curRect.size.height)];
        self.lblClothing.frame = CGRectMake(curRect.origin.x, curRect.origin.y, expectSize.width + 20, curRect.size.height);
        
        self.lblClothing.layer.borderColor = [[UIColor blackColor] CGColor];
        self.lblClothing.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        self.lblClothing.layer.cornerRadius = 10.0;
        
        self.lblLike.text = [NSString stringWithFormat:@"%d", [[self.postDetailInfo objectForKey:@"post_likes"] intValue]];
        self.lblReply.text = [NSString stringWithFormat:@"%d", [[self.postDetailInfo objectForKey:@"post_comments"] intValue]];
        self.lblShare.text = [NSString stringWithFormat:@"%d", [[self.postDetailInfo objectForKey:@"post_shares"] intValue]];
        
        BOOL hasLiked = [[self.postDetailInfo objectForKey:@"post_liked"] boolValue];
        UIButton *btnLike = (UIButton *)[self.viewClothing viewWithTag:99];
        if (btnLike != nil)
        {
            if (hasLiked)
                [btnLike setImage:[UIImage imageNamed:@"whatsnew_icon_love_act@3x.png"] forState:UIControlStateNormal];
            else
                [btnLike setImage:[UIImage imageNamed:@"whatsnew_icon_love@3x.png"] forState:UIControlStateNormal];
        }
        
        contentHeight += self.viewClothing.frame.size.height;
        
        if ([[self.postDetailInfo objectForKey:@"has_fitting_report"] boolValue])
        {
            self.viewReport.frame = CGRectMake(self.viewReport.frame.origin.x, contentHeight, self.viewReport.frame.size.width, self.viewReport.frame.size.height);
            contentHeight += self.viewReport.frame.size.height;
            
            NSInteger ratingOverall = [[self.postDetailInfo objectForKey:@"overall_rating"] integerValue];
            if (ratingOverall > 0)
                [self.ivStar1 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
            else
                [self.ivStar1 setImage:[UIImage imageNamed:@"post_icon_star"]];
            
            if (ratingOverall > 1)
                [self.ivStar2 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
            else
                [self.ivStar2 setImage:[UIImage imageNamed:@"post_icon_star"]];
            
            if (ratingOverall > 2)
                [self.ivStar3 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
            else
                [self.ivStar3 setImage:[UIImage imageNamed:@"post_icon_star"]];
            
            if (ratingOverall > 3)
                [self.ivStar4 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
            else
                [self.ivStar4 setImage:[UIImage imageNamed:@"post_icon_star"]];
            
            if (ratingOverall > 4)
                [self.ivStar5 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
            else
                [self.ivStar5 setImage:[UIImage imageNamed:@"post_icon_star"]];
            
//            NSInteger brandID = [[self.postDetailInfo objectForKey:@"brand_id"] integerValue];
//            if (brandID != 0)
//                self.lblBrand.text = [[DataManager shareDataManager] getBrandName:brandID];
//            else
//                self.lblBrand.text = @"";
            self.lblBrand.text = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"brand_name"]];
            
            self.lblModel.text = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"cloth_model"]];
            
            self.lblSize.text = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"sizing"]];
            
            self.lblRecommend.text = [[self.postDetailInfo objectForKey:@"is_recommended"] boolValue] ? @"Yes" : @"No";
            
            NSString *strFittingReport = [NSString stringWithFormat:@"%@", [self.postDetailInfo objectForKey:@"fitting_report"]];
            NSData *jsonData = [strFittingReport dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dicFittingReport = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            self.aryKeys1 = [[NSMutableArray alloc] init];
            self.aryValues1 = [[NSMutableArray alloc] init];
            for (NSString *strKey in dicFittingReport.allKeys)
            {
                [self.aryKeys1 addObject:strKey];
                NSInteger answer = [[dicFittingReport objectForKey:strKey] integerValue];
//                [self.aryValues1 addObject:[[DataManager shareDataManager] getAnswerString:strKey forAnswer:answer]];
                [self.aryValues1 addObject:[NSString stringWithFormat:@"%d", (int)answer]];
            }
            
            self.aryKeys2 = [[NSMutableArray alloc] init];
            self.aryValues2 = [[NSMutableArray alloc] init];
            [self.aryKeys2 addObject:@"Comfort"];
            NSInteger rating = [[self.postDetailInfo objectForKey:@"comfort_rating"] integerValue];
//            if (rating == 0)
//                [self.aryValues2 addObject:@"n/a"];
//            else
//                [self.aryValues2 addObject:[NSString stringWithFormat:@"%ld Stars", (long)rating]];
            [self.aryValues2 addObject:[NSNumber numberWithInteger:rating]];
            
            [self.aryKeys2 addObject:@"Quality"];
            rating = [[self.postDetailInfo objectForKey:@"quality_rating"] integerValue];
//            if (rating == 0)
//                [self.aryValues2 addObject:@"n/a"];
//            else
//                [self.aryValues2 addObject:[NSString stringWithFormat:@"%ld Stars", (long)rating]];
            [self.aryValues2 addObject:[NSNumber numberWithInteger:rating]];
            
            [self.aryKeys2 addObject:@"Style"];
            rating = [[self.postDetailInfo objectForKey:@"style_rating"] integerValue];
//            if (rating == 0)
//                [self.aryValues2 addObject:@"n/a"];
//            else
//                [self.aryValues2 addObject:[NSString stringWithFormat:@"%ld Stars", (long)rating]];
            [self.aryValues2 addObject:[NSNumber numberWithInteger:rating]];
            
            [self.aryKeys2 addObject:@"Ease of Care"];
            rating = [[self.postDetailInfo objectForKey:@"ease_rating"] integerValue];
//            if (rating == 0)
//                [self.aryValues2 addObject:@"n/a"];
//            else
//                [self.aryValues2 addObject:[NSString stringWithFormat:@"%ld Stars", (long)rating]];
            [self.aryValues2 addObject:[NSNumber numberWithInteger:rating]];
            
            [self.aryKeys2 addObject:@"Durability"];
            rating = [[self.postDetailInfo objectForKey:@"durability_rating"] integerValue];
//            if (rating == 0)
//                [self.aryValues2 addObject:@"n/a"];
//            else
//                [self.aryValues2 addObject:[NSString stringWithFormat:@"%ld Stars", (long)rating]];
            [self.aryValues2 addObject:[NSNumber numberWithInteger:rating]];
            
            [self.aryKeys2 addObject:@"Occasion"];
            rating = [[self.postDetailInfo objectForKey:@"occasion_rating"] integerValue];
//            if (rating == 1)
//                [self.aryValues2 addObject:@"Too Casual"];
//            else if (rating == 2)
//                [self.aryValues2 addObject:@"Too Formal"];
//            else
//                [self.aryValues2 addObject:@"n/a"];
            [self.aryValues2 addObject:[NSNumber numberWithInteger:rating]];
            
            [self.tvFittingReport reloadData];
            
//            NSInteger itemCount = self.aryKeys1.count + self.aryKeys2.count;
//            NSInteger tableViewHeight = itemCount * 44;
            self.viewFitting.frame = CGRectMake(self.viewFitting.frame.origin.x, contentHeight, self.viewFitting.frame.size.width, self.tvFittingReport.contentSize.height + 45);
            contentHeight += self.viewFitting.frame.size.height;
        }
        else
        {
            self.viewReport.frame = CGRectMake(self.viewReport.frame.origin.x, contentHeight, self.viewReport.frame.size.width, 0);
            contentHeight += self.viewReport.frame.size.height;
            self.viewFitting.frame = CGRectMake(self.viewFitting.frame.origin.x, contentHeight, self.viewFitting.frame.size.width, 0);
            contentHeight += self.viewFitting.frame.size.height;
        }
        
        [self.tvReplies reloadData];
        
        NSInteger commentsCount = self.aryReplies.count;
        self.lblCommentCount.text = [NSString stringWithFormat:@"Comments: %d", (int)commentsCount];
        
        if (commentsCount > 0)
            self.viewOthers.frame = CGRectMake(self.viewOthers.frame.origin.x, contentHeight, self.viewOthers.frame.size.width, self.tvReplies.contentSize.height + 50);
        else
            self.viewOthers.frame = CGRectMake(self.viewOthers.frame.origin.x, contentHeight, self.viewOthers.frame.size.width, 0);
    
        contentHeight += self.viewOthers.frame.size.height;
        
//        self.viewReply.frame = CGRectMake(self.viewReply.frame.origin.x, contentHeight, self.viewReply.frame.size.width, self.viewReply.frame.size.height);
//        contentHeight += self.viewReply.frame.size.height;
    }
    
    self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.svMain.frame), contentHeight);
}

- (void)getPostDetails
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    NSDictionary *request = @{
                              @"post_id" : self.postID,//[self.postInfo objectForKey:@"post_id"],
                              @"user_id" : strUserID,
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"get_post_detail" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        self.postDetailInfo = [dicRet mutableCopy];
        self.aryReplies = [dicRet objectForKey:@"comments"];
        [self initViews];
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    if (self.postDetailInfo == nil || ![[self.postDetailInfo objectForKey:@"post_id"] isEqualToString:self.postID])
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(getPostDetails) userInfo:nil repeats:NO];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)keyboardWillShow:(NSNotification*)notification
//{
//    [UIView animateWithDuration:0.2 animations:^
//     {
//         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x,self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.svMain.frame.origin.x - 320);
//     } completion:^(BOOL finished) {
//         [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, self.svMain.contentSize.height - CGRectGetHeight(self.svMain.frame)) animated:NO] ;
//     }];
//}
//
//- (void)keyboardWillHide:(NSNotification*)notification
//{
//    [UIView animateWithDuration:0.2 animations:^
//     {
//         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x,self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.svMain.frame.origin.x - 114);
//     } completion:^(BOOL finished) {
//         CGFloat yOffset = self.svMain.contentSize.height - CGRectGetHeight(self.svMain.frame);
//         if (yOffset < 0) yOffset = 0;
//         
//         [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, yOffset) animated:NO] ;
//     }];
//}

- (void)keyboardWillChange:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    
    float diff = (keyboardRect.origin.y < self.view.frame.size.height) ? keyboardRect.size.height : 50;
    
    [UIView animateWithDuration:0.2 animations:^
     {
         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x,self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.viewReply.frame.size.height - self.svMain.frame.origin.y - diff);
         self.viewReply.frame = CGRectMake(self.viewReply.frame.origin.x,
                                           self.svMain.frame.origin.y + self.svMain.frame.size.height,
                                           self.viewReply.frame.size.width,
                                           self.viewReply.frame.size.height);
         
     } completion:^(BOOL finished) {
         
//         CGFloat yOffset = self.svMain.contentSize.height - CGRectGetHeight(self.svMain.frame);
//         if (yOffset < 0) yOffset = 0;
//         
//         [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, yOffset) animated:NO] ;
     }];
}

- (BOOL)postComment
{
    if (self.txtReply.text.length == 0)
        return NO;
    
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    NSString *strComment = self.txtReply.text;
    NSData *encodedData = [strComment dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    strComment = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
    
    NSDictionary *request = @{
                              @"post_id" : self.postID,
                              @"user_id" : strUserID,
                              @"comment" : strComment,
                              };
    
    NSLog(@"%@", request);
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"post_comment" request:request];
    
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
            self.postDetailInfo = [[dicRet objectForKey:@"post"] mutableCopy];
            self.aryReplies = [self.postDetailInfo objectForKey:@"comments"];
            [self initViews];
            
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

- (IBAction)onSendComment:(id)sender
{
    if (self.txtReply.text.length == 0)
        return;
    
    [self.txtReply resignFirstResponder];
    
    if (!self.tvContacts.hidden)
        [self hideContactView:0.3f];
    
    if ([self postComment])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
        
        self.txtReply.text = @"";
        [self.tvReplies reloadData];
    }
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onShare:(id)sender
{
    if (!self.tvContacts.hidden)
    {
        [self hideContactView:0.3f];
        return;
    }
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSInteger myID = [[userInfo objectForKey:@"user_id"] integerValue];
    NSInteger posterID = [[self.postDetailInfo objectForKey:@"user_id"] integerValue];
    
    if (myID == posterID)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share this post", @"Delete this post", nil];
        
        [actionSheet showInView:self.view];
    }
    else
    {
        [self sharePost];
    }
}

- (BOOL)postLike
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"post_id" : self.postID,
                              @"user_id" : strUserID,
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"post_like" request:request];
    
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
            NSMutableDictionary *postInfo = [dicRet objectForKey:@"post"];
            [self.postDetailInfo setObject:[postInfo objectForKey:@"post_liked"] forKey:@"post_liked"];
            [self.postDetailInfo setObject:[postInfo objectForKey:@"post_likes"] forKey:@"post_likes"];
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

- (BOOL)postDislike
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"post_id" : self.postID,
                              @"user_id" : strUserID,
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"post_dislike" request:request];
    
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
            NSMutableDictionary *postInfo = [dicRet objectForKey:@"post"];
            [self.postDetailInfo setObject:[postInfo objectForKey:@"post_liked"] forKey:@"post_liked"];
            [self.postDetailInfo setObject:[postInfo objectForKey:@"post_likes"] forKey:@"post_likes"];
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

- (IBAction)onLike:(id)sender
{
    if ([[self.postDetailInfo objectForKey:@"post_liked"] boolValue])
    {
        if ([self postDislike])
        {
            int likeCount = [[self.postDetailInfo objectForKey:@"post_likes"] intValue];
            self.lblLike.text = [NSString stringWithFormat:@"%d", likeCount];
        }
    }
    else
    {
        if ([self postLike])
        {
            int likeCount = [[self.postDetailInfo objectForKey:@"post_likes"] intValue];
            self.lblLike.text = [NSString stringWithFormat:@"%d", likeCount];
        }
    }
    
    [self initViews];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
}

- (BOOL)postReshare
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"post_id" : self.postID,
                              @"user_id" : strUserID,
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"post_share" request:request];
    
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
            NSMutableDictionary *postInfo = [dicRet objectForKey:@"post"];
            [self.postDetailInfo setObject:[postInfo objectForKey:@"post_shares"] forKey:@"post_shares"];
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

- (IBAction)onReshare:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to reshare this post?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    alertView.tag = 1;
    
    [alertView show];
}

#pragma mark UIAlertViewDelegate

- (void)deletePost
{
    if ([self processDeletePost])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"The post has been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alertView.tag = 3;
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            if ([self postReshare])
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
                int shareCount = [[self.postDetailInfo objectForKey:@"post_shares"] intValue];
                self.lblShare.text = [NSString stringWithFormat:@"%d", shareCount];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Thanks for spreading the love! You just re-shared this post to your followers" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alertView show];
            }
        }
    }
    else if (alertView.tag == 2 && buttonIndex == 1)
    {
        [self performSelector:@selector(deletePost) withObject:nil afterDelay:0.1f];
    }
    else if (alertView.tag == 3)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tvFittingReport)
        return 3;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tvReplies)
    {
        if (self.aryReplies == nil)
            return 0;
        
        return self.aryReplies.count;
    }
    else if (tableView == self.tvContacts)
    {
        if (self.aryDisplay == nil)
            return 0;
        
        return self.aryDisplay.count;
    }
    else if (tableView == self.tvFittingReport)
    {
        if (section == 0)
            return self.aryKeys1.count;
        else if (section == 1)
            return 1;
        else if (section == 2)
            return self.aryKeys2.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvContacts)
        return 40;
    else if (tableView == self.tvFittingReport)
    {
        if (indexPath.section == 0 || indexPath.section == 2)
            return 44;
        
        return 22;
    }
    
    if (tableView == self.tvReplies)
    {
        NSDictionary *dicComment = self.aryReplies[indexPath.row];
        if (dicComment == nil)
            return 0;
        
        return [CommentTableViewCell heightForComment:dicComment cellWidth:self.tvReplies.frame.size.width];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvReplies)
    {
        CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
        if(cell == nil)
            cell = (CommentTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.delegate = self;
        
        return cell;
    }
    else if (tableView == self.tvContacts)
    {
        ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
        if(cell == nil)
            cell = (ContactTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        return cell;
    }
    else if (tableView == self.tvFittingReport)
    {
        UITableViewCell *cell = nil;
        if (indexPath.section == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if(cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"slider"];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvReplies)
    {
        CommentTableViewCell *myCell = (CommentTableViewCell *)cell;
        [myCell setCommentInfo:self.aryReplies[indexPath.row]];
        
        myCell.accessoryType = UITableViewCellAccessoryNone;
        myCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (tableView == self.tvContacts)
    {
        ContactTableViewCell *myCell = (ContactTableViewCell *)cell;
        NSMutableDictionary *itemInfo = [self.aryDisplay objectAtIndex:indexPath.row];
        if (itemInfo != nil)
        {
            NSString *strPhotoURL = [itemInfo objectForKey:@"photo"];
            if (strPhotoURL != nil)
            {
                myCell.ivProfile.hidden = NO;
                [myCell.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL]];
            }
            else
            {
                myCell.ivProfile.hidden = YES;
                myCell.ivProfile.image = nil;
            }
            
            myCell.lblFullName.text = [itemInfo objectForKey:@"content"];
            myCell.lblUserName.text = [itemInfo objectForKey:@"details"];
        }
        
        myCell.accessoryType = UITableViewCellAccessoryNone;
        myCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (tableView == self.tvFittingReport)
    {
        if (indexPath.section == 1)
        {
            cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14.f];
            cell.textLabel.text = @"(5 indicates the most; 1 indicates the least)";
        }
        else
        {
            SliderTableViewCell *myCell = (SliderTableViewCell *)cell;
            myCell.sliderRating.userInteractionEnabled = NO;
            
            NSString *strTitle = @"";
            if (indexPath.section == 0)
                strTitle = [self.aryKeys1 objectAtIndex:indexPath.row];
            else if (indexPath.section == 2)
                strTitle = [self.aryKeys2 objectAtIndex:indexPath.row];
            
            myCell.lblTitle.text = strTitle;
            NSString *strRating1 = [[DataManager shareDataManager] getAnswerString:strTitle forAnswer:1];
            if (strRating1.length > 0 && ![strRating1 isEqualToString:@"Unknown"])
                myCell.lblReview1.text = strRating1;
            else if ([[strTitle lowercaseString] isEqualToString:@"occasion"])
                myCell.lblReview1.text = @"Casual";
            else
                myCell.lblReview1.text = @"1";
            
            myCell.lblReview2.text = @"";//[[DataManager shareDataManager] getAnswerString:strTitle forAnswer:2];
            
            NSString *strRating3 = [[DataManager shareDataManager] getAnswerString:strTitle forAnswer:3];
            if (strRating3.length > 0 && ![strRating3 isEqualToString:@"Unknown"])
                myCell.lblReview3.text = strRating3;
            else if ([[strTitle lowercaseString] isEqualToString:@"occasion"])
                myCell.lblReview3.text = @"Formal";
            else
                myCell.lblReview3.text = @"5";
//            myCell.lblReview3.text = [[DataManager shareDataManager] getAnswerString:strTitle forAnswer:3];
            
            if (indexPath.section == 0)
                [myCell setRatingValue:[[self.aryValues1 objectAtIndex:indexPath.row] integerValue]];
            else if (indexPath.section == 2)
                [myCell setRatingValue:[[self.aryValues2 objectAtIndex:indexPath.row] integerValue]];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvContacts)
    {
        [self hideContactView:0.3f];
        
        NSMutableDictionary *itemInfo = [self.aryDisplay objectAtIndex:indexPath.row];
        NSString *stringInsert = [itemInfo objectForKey:@"details"];
        
        if (_strKeyword.length > 0)
        {
            UITextRange *selRange = self.txtReply.selectedTextRange;
            UITextPosition *beginning = self.txtReply.beginningOfDocument;
            NSInteger location = [self.txtReply offsetFromPosition:beginning toPosition:selRange.start];

            if (location >= _strKeyword.length)
            {
                UITextPosition *start = [self.txtReply positionFromPosition:beginning offset:location - _strKeyword.length];
                UITextPosition *end = [self.txtReply positionFromPosition:start offset:_strKeyword.length];
                UITextRange *textRange = [self.txtReply textRangeFromPosition:start toPosition:end];
                
                [self.txtReply setSelectedTextRange:textRange];
            }
        }
        
        UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
        NSArray* lPasteBoardItems = [lPasteBoard.items copy];
        lPasteBoard.string = [NSString stringWithFormat:@"%@ ", stringInsert];
        [self.txtReply paste:self];
        lPasteBoard.items = lPasteBoardItems;
    }
    else if (tableView == self.tvReplies)
    {
        NSDictionary *commentInfo = [self.aryReplies objectAtIndex:indexPath.row];
        if (commentInfo != nil)
        {
            NSString *strUserName = [NSString stringWithFormat:@"@%@ ", [commentInfo objectForKey:@"user_name"]];
            
//            NSString *curText = self.txtReply.text;
//            if (curText.length > 0 && ![[curText substringToIndex:1] isEqualToString:@"@"])
//                strUserName = [NSString stringWithFormat:@"%@%@", strUserName, curText];
            
            [self.txtReply setText:strUserName];
            
            if (self.svMain.contentOffset.y < self.txtReply.frame.origin.y + self.txtReply.frame.size.height)
                [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, self.txtReply.frame.origin.y + self.txtReply.frame.size.height)];
            
            [self.txtReply becomeFirstResponder];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvReplies)
    {
        NSDictionary *commentInfo = [self.aryReplies objectAtIndex:indexPath.row];
        if (commentInfo != nil)
        {
            NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
            NSInteger myID = [[userInfo objectForKey:@"user_id"] integerValue];
            
            NSInteger commenterID = [[commentInfo objectForKey:@"user_id"] integerValue];
            if (commenterID == myID)
                return YES;
            
            return NO;
        }
        
        return NO;
    }
    
    return NO;
}

- (BOOL)processDeleteComment:(NSDictionary *)commentInfo
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"comment_id" : [commentInfo objectForKey:@"comment_id"],
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"delete_comment" request:request];
    
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
            self.postDetailInfo = [[dicRet objectForKey:@"post"] mutableCopy];
            self.aryReplies = [self.postDetailInfo objectForKey:@"comments"];
            [self initViews];
            
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvReplies && editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary *commentInfo = [self.aryReplies objectAtIndex:indexPath.row];
        if (commentInfo != nil)
        {
            if ([self processDeleteComment:commentInfo])
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
                [self.tvReplies reloadData];
            }
        }
    }
}

#pragma mark CommentTableViewCellDelegate

- (void)tapLink:(NSString *)strLink
{
    if ([[strLink substringToIndex:1] isEqualToString:@"@"])
    {
        strLink = [strLink substringFromIndex:1];

        for (NSMutableDictionary *userInfo in [[DataManager shareDataManager] getUsernamesArray])
        {
            NSString *strUserName = [userInfo objectForKey:@"user_name"];
            if ([strUserName isEqualToString:strLink])
            {
                NSString *strUserID = [userInfo objectForKey:@"user_id"];
                [self performSegueWithIdentifier:@"userprofile" sender:strUserID];
            }
        }
    }
    else if ([[strLink substringToIndex:1] isEqualToString:@"#"])
    {
        strLink = [strLink substringFromIndex:1];
        
        for (NSMutableDictionary *brandInfo in [[DataManager shareDataManager] getBrandsArray])
        {
            NSString *strContent = [brandInfo objectForKey:@"brand_name"];
            NSArray* words = [strContent componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* noSpaceString = [words componentsJoinedByString:@""];
            NSString *strBrandName = [noSpaceString lowercaseString];
            if ([strBrandName isEqualToString:strLink])
            {
                [self performSegueWithIdentifier:@"postlist" sender:brandInfo];
            }
        }
    }
}

- (void)tapPhoto:(NSString *)strUserID
{
    [self performSegueWithIdentifier:@"userprofile" sender:strUserID];
}

- (BOOL)commentLike:(NSMutableDictionary *)commentInfo
{
    if (commentInfo == nil)
        return NO;
    
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"comment_id" : [commentInfo objectForKey:@"comment_id"],
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"comment_like" request:request];
    
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
            return YES;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return NO;
}

- (BOOL)commentDislike:(NSMutableDictionary *)commentInfo
{
    if (commentInfo == nil)
        return NO;
    
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"comment_id" : [commentInfo objectForKey:@"comment_id"],
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"comment_dislike" request:request];
    
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
            return YES;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return NO;
}

- (void)likeComment:(UIView *)view
{
    CommentTableViewCell *cell = (CommentTableViewCell *)view;
    NSMutableDictionary *commentInfo = [[cell getCommentInfo] mutableCopy];
    if (commentInfo == nil)
        return;
    
    if ([[commentInfo objectForKey:@"comment_liked"] boolValue])
    {
        [commentInfo setObject:@"0" forKey:@"comment_liked"];
        
        if ([self commentDislike:commentInfo])
            [cell setCommentInfo:commentInfo];
    }
    else
    {
        [commentInfo setObject:@"1" forKey:@"comment_liked"];
        
        if ([self commentLike:commentInfo])
            [cell setCommentInfo:commentInfo];
    }
}

#pragma mark UIActionSheetDelegate
/*
- (void)shareLink:(NSString *)serviceType
{
    if([SLComposeViewController class])
    {
//        if ([SLComposeViewController isAvailableForServiceType:serviceType])
        {
            SLComposeViewController* vcCompose = [SLComposeViewController composeViewControllerForServiceType:serviceType];
            if (vcCompose != nil)
            {
                NSString *strPost = [NSString stringWithFormat:@"%@\n\n%@", @"Here is a linkqlo post.", [self.postDetailInfo objectForKey:@"content"]];
                [vcCompose setInitialText:strPost];
//                [vcCompose addImage:self.ivPhoto.image];
                
                SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result)
                {
                    if (result == SLComposeViewControllerResultCancelled)
                    {
                        NSLog(@"Cancelled");
                        
                    }
                    else
                    {
                        NSLog(@"Post");
                    }
                    
                    [vcCompose dismissViewControllerAnimated:YES completion:^{

                    }];
                };
                
                vcCompose.completionHandler = myBlock;
                [self presentViewController: vcCompose animated: YES completion: nil];
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to set up some social network accounts in order to share the link." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
        return;
    }
}

- (void)shareOnFacebook
{
    [self shareLink:SLServiceTypeFacebook];
}

- (void)shareOnTwitter
{
    [self shareLink:SLServiceTypeTwitter];
}

- (void)shareOnEmail
{
    if (![MFMailComposeViewController canSendMail])
        return;
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString* strSubject = @"Here is a linkqlo post.";
    [picker setSubject:strSubject];
    
    [picker setMessageBody:[self.postDetailInfo objectForKey:@"content"] isHTML:NO];
    
//    NSData *imageData = UIImageJPEGRepresentation(self.ivPhoto.image, 0.5);
//    [picker addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"Photo.jpg"];
    
    picker.navigationBar.barStyle = UIBarStyleDefault;
    
    [self presentViewController:picker animated:YES completion:nil];
}
*/
- (void)sharePost
{
    NSString *strPost = @"";
    NSString *strContent = [self.postDetailInfo objectForKey:@"content"];
    if (strContent == nil || strContent.length == 0)
        strPost = @"Here is a linkqlo post.";
    else
        strPost = [NSString stringWithFormat:@"%@\n\n%@", @"Here is a linkqlo post.", strContent];
    
    NSURL *urlCoverPhoto = [NSURL URLWithString:[self.postDetailInfo objectForKey:@"photo_url"]];
    
    NSArray *objectsToShare = @[strPost, urlCoverPhoto];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (BOOL)processDeletePost
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"post_id" : self.postID,
                              };
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"delete_post" request:request];
    
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
            return YES;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
/*
    if (buttonIndex == 0) // Facebook
    {
        [self shareOnFacebook];
    }
    else if (buttonIndex == 1) // Twitter
    {
        [self shareOnTwitter];
    }
    else if (buttonIndex == 2) // E-mail
    {
        [self shareOnEmail];
    }
*/
    if (buttonIndex == 0)
    {
        [self sharePost];
    }
    else if (buttonIndex == 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this post?" delegate:self cancelButtonTitle:@"Don't Delete" otherButtonTitles:@"Delete", nil];
        alertView.tag = 2;
        
        [alertView show];
    }
}

- (IBAction)onChangingReply:(id)sender
{
    
}

- (IBAction)onChangedReply:(id)sender
{
    return;
/*
    UITextRange *selRange = self.txtReply.selectedTextRange;
    UITextRange *markedRage = self.txtReply.markedTextRange;
    NSDictionary *markedStyle = self.txtReply.markedTextStyle;
    NSString *strText = self.txtReply.text;
    NSString *strMarkedText = nil;
    if (markedRage != nil)
        strMarkedText = [self.txtReply textInRange:markedRage];
    
    NSAttributedString *strContent = [[DataManager shareDataManager] convertString:strText font:self.txtReply.font];
    self.txtReply.attributedText = strContent;
    
    if (markedRage != nil && strMarkedText != nil && strMarkedText.length > 0)
        [self.txtReply setMarkedText:strMarkedText selectedRange:NSMakeRange(0, 0)];
    
    if (markedStyle != nil)
        [self.txtReply setMarkedTextStyle:markedStyle];
    
    if (selRange != nil)
        [self.txtReply setSelectedTextRange:selRange];
*/
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

#pragma mark UITextFieldDelegate

- (void) showContactView:(float)duration
{
    [self.view bringSubviewToFront:self.tvContacts];
    
//    self.aryDisplay = nil;
    self.aryDisplay = [self.aryContacts mutableCopy];
    [self.tvContacts reloadData];
    
    self.tvContacts.hidden = NO;
    
    [UIView animateWithDuration:duration animations:^{
        
        CGFloat offset = self.viewReply.frame.origin.y - self.svMain.frame.origin.y;
        self.tvContacts.frame = CGRectMake(self.svMain.frame.origin.x,
                                           self.svMain.frame.origin.y,
                                           self.svMain.frame.size.width,
                                           offset);
        
    } completion:^(BOOL finished) {
        self.navigationItem.leftBarButtonItem.image = nil;
        self.navigationItem.rightBarButtonItem.image = nil;
        self.navigationItem.rightBarButtonItem.title = @"Cancel";
    }];
}

- (void) hideContactView:(float)duration
{
    [UIView animateWithDuration:duration animations:^{
        
        self.tvContacts.frame = CGRectMake(self.svMain.frame.origin.x,
                                           self.svMain.frame.origin.y - self.tvContacts.frame.size.height,
                                           self.svMain.frame.size.width,
                                           self.tvContacts.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        self.tvContacts.hidden = YES;
        
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"common_btn_back"];
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"whatsnew_icon_etc"];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"@"] || [string isEqualToString:@"#"])
    {
        [self.aryContacts removeAllObjects];
        
        if ([string isEqualToString:@"@"])
        {
            for (NSMutableDictionary *userInfo in [[DataManager shareDataManager] getUsernamesArray])
            {
                NSString *strPhotoURL = [userInfo objectForKey:@"photo_url"];
                
                NSString *strContent = [userInfo objectForKey:@"first_name"];
                NSString *strDetails = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
                
                NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 strPhotoURL, @"photo",
                                                 strContent, @"content",
                                                 strDetails, @"details",
                                                 nil];
                
                [self.aryContacts addObject:itemInfo];
            }
        }
        else if ([string isEqualToString:@"#"])
        {
            for (NSMutableDictionary *brandInfo in [[DataManager shareDataManager] getBrandsArray])
            {
                NSString *strContent = [brandInfo objectForKey:@"brand_name"];
                
                NSArray* words = [strContent componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* noSpaceString = [words componentsJoinedByString:@""];
                NSString *strDetails = [noSpaceString lowercaseString];
                
                NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 strContent, @"content",
                                                 strDetails, @"details",
                                                 nil];
                
                [self.aryContacts addObject:itemInfo];
            }
        }
        
        [self showContactView:0.3f];
        _strKeyword = @"";
    }
    else if ([string isEqualToString:@" "])
    {
        if (!self.tvContacts.hidden)
            [self hideContactView:0.3f];
    }
    else if (!self.tvContacts.hidden)
    {
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        if (isBackSpace == -8)
        {
            if (_strKeyword.length > 0)
            {
                NSRange range = NSMakeRange(0, _strKeyword.length - 1);
                if (range.location != NSNotFound)
                    _strKeyword = [_strKeyword substringWithRange:range];
            }
            else
            {
                _strKeyword = @"";
                [self hideContactView:0.3f];
            }
        }
        else
            _strKeyword = [NSString stringWithFormat:@"%@%@", _strKeyword, string];
        
        [self.aryDisplay removeAllObjects];
        
        if (_strKeyword.length == 0)
        {
            self.aryDisplay = [self.aryContacts mutableCopy];
        }
        else
        {
            for (NSMutableDictionary *itemInfo in self.aryContacts)
            {
                NSString *strContent = [itemInfo objectForKey:@"content"];
                NSString *strDetails = [itemInfo objectForKey:@"details"];
                if ([strContent rangeOfString:_strKeyword].location != NSNotFound ||
                    [strDetails rangeOfString:_strKeyword].location != NSNotFound)
                {
                    [self.aryDisplay addObject:itemInfo];
                }
            }
        }
        
        [self.tvContacts reloadData];
    }
    
    return YES;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tvContacts)
    {
        if (self.tvContacts.hidden)
            return;
        
        CGFloat offset = self.viewReply.frame.origin.y - self.svMain.frame.origin.y;
        if (offset > 0)
            self.tvContacts.frame = CGRectMake(self.svMain.frame.origin.x,
                                               self.svMain.frame.origin.y,
                                               self.svMain.frame.size.width,
                                               offset);
    }
    else if (scrollView == self.svImages)
    {
        CGRect curRect = scrollView.frame;
        int curPage = scrollView.contentOffset.x / curRect.size.width;
        self.pgImages.currentPage = curPage;
    }
    else if (scrollView == self.svMain)
    {
        [self.txtReply resignFirstResponder];
        
        if (self.tvContacts.hidden)
            [self hideContactView:0.3f];
    }
}

@end
