//
//  PostCollectionViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "PostCollectionViewCell.h"

#import "UIImageView+WebCache.h"

#import "DataManager.h"

@interface PostCollectionViewCell ()
{
    NSMutableDictionary *_postInfo;
}

@end

@implementation PostCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    _postInfo = nil;
    
    self.lblContent.automaticLinkDetectionEnabled = YES;
    self.lblContent.linkDetectionTypes = KILinkDetectionTypeUserHandle | KILinkDetectionTypeHashtag;
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

+ (CGSize)sizeForPostInfo:(NSMutableDictionary *)postInfo cellWidth:(NSInteger)cellWidth
{
    int contentHeight = 0;
    
//    NSInteger shareID = [[postInfo objectForKey:@"last_sharer_id"] integerValue];
    NSInteger shareID = [[postInfo objectForKey:@"sharer_id"] integerValue];
    if (shareID != 0)
        contentHeight += 25;
    
    contentHeight += 49;
    
    // Photo frame
    NSInteger photoWidth = [[postInfo objectForKey:@"photo_width"] integerValue];
    NSInteger photoHeight = [[postInfo objectForKey:@"photo_height"] integerValue];
    if (photoWidth != 0 && photoHeight != 0)
    {
        contentHeight += cellWidth * photoHeight / photoWidth + 8;
    }
    else
    {
        NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [postInfo objectForKey:@"photo_url"]];
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:strPhotoURL]];
        CGImageRef ref = [imageView.image CGImage];
        photoWidth = CGImageGetWidth(ref); photoHeight = CGImageGetHeight(ref);
        contentHeight += cellWidth * photoHeight / photoWidth + 8;
        imageView = nil;
    }
    
    // Post content
    NSString *strContent = [NSString stringWithFormat:@"%@", [postInfo objectForKey:@"content"]];
    if (strContent.length > 0)
    {
        KILabel *label = [[KILabel alloc] init];
        label.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];
        label.text = strContent;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        label.adjustsFontSizeToFitWidth = NO;
        CGSize contentSize = [label sizeThatFits:CGSizeMake((cellWidth - 16), 99999.0f)];
        int minHeight = MIN(contentSize.height, 150);
        contentHeight += minHeight + 8;
        label = nil;
    }
    else
    {
        contentHeight += 8;
    }
    
    // Other view.
    if ([[postInfo objectForKey:@"clothing_id"] integerValue] > 0 ||
        [[postInfo objectForKey:@"has_fitting_report"] boolValue])
        contentHeight += 45;
    else
        contentHeight += 25;
    
    return CGSizeMake(cellWidth, contentHeight);
}

- (void)repositionSubviews
{
    CGImageRef ref = [self.ivPhoto.image CGImage];
    size_t imageWidth = CGImageGetWidth(ref); size_t imageHeight = CGImageGetHeight(ref);
    self.ivPhoto.frame = CGRectMake(self.ivPhoto.frame.origin.x, self.ivPhoto.frame.origin.y, self.ivPhoto.frame.size.width, self.ivPhoto.frame.size.width * imageHeight / imageWidth);
    
    CGRect curFrame = self.lblContent.frame;
    if (self.lblContent.hidden == NO)
    {
        CGSize contentSize = [self.lblContent sizeThatFits:CGSizeMake(self.frame.size.width - 16, 99999.0f)];
        int minHeight = MIN(contentSize.height, 150);
        self.lblContent.frame = CGRectMake(curFrame.origin.x, self.ivPhoto.frame.origin.y + self.ivPhoto.frame.size.height + 8, self.frame.size.width - 16, minHeight);
    }
    else
    {
        self.lblContent.frame = CGRectMake(curFrame.origin.x, self.ivPhoto.frame.origin.y + self.ivPhoto.frame.size.height + 8, self.frame.size.width - 16, 0);
    }
    
    if (self.viewRating.hidden == NO)
        self.viewRating.frame = CGRectMake(self.frame.size.width - 87, self.lblContent.frame.origin.y, 79, 19);
    else
        self.viewRating.frame = CGRectMake(self.frame.size.width - 87, self.lblContent.frame.origin.y, 79, 0);
    
    curFrame = self.viewContent.frame;
    if (self.lblClothing.hidden == YES && self.viewRating.hidden == YES)
        self.viewContent.frame = CGRectMake(curFrame.origin.x, self.lblContent.frame.origin.y + self.lblContent.frame.size.height + 8, curFrame.size.width, 25);
    else
        self.viewContent.frame = CGRectMake(curFrame.origin.x, self.lblContent.frame.origin.y + self.lblContent.frame.size.height + 8, curFrame.size.width, 45);
}

- (void)setPostInfo:(NSMutableDictionary *)postInfo layOut:(UICollectionViewLayout *)layOut
{
    if (postInfo == nil || postInfo == _postInfo)
        return;
    
    _postInfo = postInfo;
    
//    NSInteger lastSharerID = [[_postInfo objectForKey:@"last_sharer_id"] integerValue];
    NSInteger sharerID = [[_postInfo objectForKey:@"sharer_id"] integerValue];
    if (sharerID/*lastSharerID*/ != 0)
    {
        NSString *strFullName = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"sharer_first_name"]];
        NSString *strUserName = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"sharer_name"]];
        if (strFullName == nil || ![strFullName isKindOfClass:[NSString class]] || [strFullName isEqualToString:@"<null>"]) strFullName = @"";
        if (strUserName == nil || ![strUserName isKindOfClass:[NSString class]] || [strUserName isEqualToString:@"<null>"]) strUserName = @"";
        if (strFullName.length > 0 || strUserName.length > 0)
        {
            if (strFullName.length == 0)
                self.lblReshareName.text = [NSString stringWithFormat:@"Re-shared by @%@", strUserName];
            else
                self.lblReshareName.text = [NSString stringWithFormat:@"Re-shared by %@", strFullName];
            
            self.viewReshare.hidden = NO;
        }
        else
        {
            self.viewReshare.hidden = YES;
        }
    }
    else
    {
        self.viewReshare.hidden = YES;
    }
    
    self.ivProfile.layer.masksToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    
    self.ivProfile.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.ivProfile.layer.borderColor = [[UIColor blackColor] CGColor];
    
    NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"user_photo_url"]];
    [self.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL]];
    
    NSString *strUserName = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"first_name"]];
    if (strUserName.length == 0)
        strUserName = [NSString stringWithFormat:@"@%@", [_postInfo objectForKey:@"user_name"]];
    
    self.lblName.text = strUserName;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSInteger myID = [[userInfo objectForKey:@"user_id"] integerValue];
    NSInteger posterID = [[_postInfo objectForKey:@"user_id"] integerValue];

    self.lblPercent.text = @"";
    
    if (myID == posterID)
        self.lblPercent.hidden = YES;
    else
    {
        self.lblPercent.hidden = NO;

        NSInteger bsiType;
        NSInteger clothingID = [[_postInfo objectForKey:@"clothing_id"] integerValue];
        
        NSString *myGender = [NSString stringWithFormat:@"%@", [[[DataManager shareDataManager] getUserInfo] objectForKey:@"gender"]];
        NSString *userGender = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"gender"]];
        if ([myGender isEqualToString:userGender])
        {
            float similarity = [[DataManager shareDataManager] calcSimilarity:_postInfo clothingID:clothingID bsiType:&bsiType];
            
            if (similarity == 0)
            {
                bsiType = 0;
                similarity = [[DataManager shareDataManager] calcSimpleSimilarity:_postInfo];
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
            self.lblPercent.text = @"";
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strUpdatedTime = [_postInfo objectForKey:@"updated"];
    if (strUpdatedTime == nil)
        strUpdatedTime = [_postInfo objectForKey:@"updated"];
    
    NSDate *lastUpdateTime = [formatter dateFromString:[NSString stringWithFormat:@"%@", strUpdatedTime]];
    NSString *strUpdate = [self getTimeIntervalString:lastUpdateTime];
    self.lblUpdate.text = strUpdate;

    NSString *strContent = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"content"]];
    self.lblContent.text = strContent;
    
    if (strContent.length == 0)
        self.lblContent.hidden = YES;
    else
        self.lblContent.hidden = NO;
    
    self.lblLike.text = [NSString stringWithFormat:@"%d", [[_postInfo objectForKey:@"post_likes"] intValue]];
    self.lblReply.text = [NSString stringWithFormat:@"%d", [[_postInfo objectForKey:@"post_comments"] intValue]];
    self.lblReshare.text = [NSString stringWithFormat:@"%d", [[_postInfo objectForKey:@"post_shares"] intValue]];
    
    NSInteger clothingID = [[_postInfo objectForKey:@"clothing_id"] integerValue];
    if (clothingID > 0)
    {
        self.lblClothing.hidden = NO;
        
        self.lblClothing.textColor = [UIColor blackColor];
        self.lblClothing.text = [[DataManager shareDataManager] getClothingTypeName:clothingID];
        
//        [self.lblClothing sizeToFit];
        CGRect newFrame = CGRectMake(self.lblClothing.frame.origin.x,
                                     self.lblClothing.frame.origin.y,
                                     (self.frame.size.width - 20) / 2,
                                     self.lblClothing.frame.size.height);
        self.lblClothing.frame = newFrame;
        
        self.lblClothing.layer.borderColor = [[UIColor blackColor] CGColor];
        self.lblClothing.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        self.lblClothing.layer.cornerRadius = self.lblClothing.frame.size.height / 2;
    }
    else
    {
        self.lblClothing.hidden = YES;
    }
    
    BOOL hasFittingReport = [[postInfo objectForKey:@"has_fitting_report"] boolValue];
    if (hasFittingReport)
    {
        self.viewRating.hidden = NO;
        self.viewRating.layer.borderColor = [[UIColor blackColor] CGColor];
        self.viewRating.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        self.viewRating.layer.cornerRadius = self.viewRating.frame.size.height / 2;
        
        NSInteger overallRating = [[postInfo objectForKey:@"overall_rating"] integerValue];
        UIImageView *ivStar1 = (UIImageView *)[self.viewRating viewWithTag:1];
        UIImageView *ivStar2 = (UIImageView *)[self.viewRating viewWithTag:2];
        UIImageView *ivStar3 = (UIImageView *)[self.viewRating viewWithTag:3];
        UIImageView *ivStar4 = (UIImageView *)[self.viewRating viewWithTag:4];
        UIImageView *ivStar5 = (UIImageView *)[self.viewRating viewWithTag:5];
        if (overallRating >= 1)
            [ivStar1 setImage:[UIImage imageNamed:@"rating_icon_star_act"]];
        else
            [ivStar1 setImage:[UIImage imageNamed:@"rating_icon_star_dis"]];
        
        if (overallRating >= 2)
            [ivStar2 setImage:[UIImage imageNamed:@"rating_icon_star_act"]];
        else
            [ivStar2 setImage:[UIImage imageNamed:@"rating_icon_star_dis"]];
        
        if (overallRating >= 3)
            [ivStar3 setImage:[UIImage imageNamed:@"rating_icon_star_act"]];
        else
            [ivStar3 setImage:[UIImage imageNamed:@"rating_icon_star_dis"]];
        
        if (overallRating >= 4)
            [ivStar4 setImage:[UIImage imageNamed:@"rating_icon_star_act"]];
        else
            [ivStar4 setImage:[UIImage imageNamed:@"rating_icon_star_dis"]];
        
        if (overallRating >= 5)
            [ivStar5 setImage:[UIImage imageNamed:@"rating_icon_star_act"]];
        else
            [ivStar5 setImage:[UIImage imageNamed:@"rating_icon_star_dis"]];
    }
    else
        self.viewRating.hidden = YES;
    
    BOOL hasLiked = [[_postInfo objectForKey:@"post_liked"] boolValue];
    UIImageView *imageView = (UIImageView *)[self viewWithTag:99];
    if (imageView != nil)
    {
        if (hasLiked)
            [imageView setImage:[UIImage imageNamed:@"whatsnew_icon_love_act@3x.png"]];
        else
            [imageView setImage:[UIImage imageNamed:@"whatsnew_icon_love@3x.png"]];
    }
    
    if (!self.viewReshare.hidden)
    {
        self.viewInfo.frame = CGRectMake(self.viewInfo.frame.origin.x,
                                         self.viewReshare.frame.origin.y + self.viewReshare.frame.size.height,
                                         self.viewInfo.frame.size.width,
                                         self.viewInfo.frame.size.height);
    }
    else
    {
        self.viewInfo.frame = CGRectMake(self.viewInfo.frame.origin.x,
                                         0,
                                         self.viewInfo.frame.size.width,
                                         self.viewInfo.frame.size.height);
    }
/*
    self.ivPhoto.frame = CGRectMake(self.ivPhoto.frame.origin.x,
                                    self.viewInfo.frame.origin.y + self.viewInfo.frame.size.height,
                                    self.ivPhoto.frame.size.width,
                                    self.ivPhoto.frame.size.height);
    
    if (self.lblContent.hidden == YES)
    {
        self.lblContent.frame = CGRectMake(self.lblContent.frame.origin.x,
                                           self.ivPhoto.frame.origin.y + self.ivPhoto.frame.size.height + 8,
                                           self.lblContent.frame.size.width,
                                           0);
    }
    else
    {
        self.lblContent.frame = CGRectMake(self.lblContent.frame.origin.x,
                                           self.ivPhoto.frame.origin.y + self.ivPhoto.frame.size.height + 8,
                                           self.lblContent.frame.size.width,
                                           self.lblContent.frame.size.height);
    }
    
    self.viewContent.frame = CGRectMake(self.viewContent.frame.origin.x,
                                        self.lblContent.frame.origin.y + self.lblContent.frame.size.height + 8,
                                        self.viewContent.frame.size.width,
                                        self.viewContent.frame.size.height);
*/
    NSInteger photoWidth = [[postInfo objectForKey:@"photo_width"] integerValue];
    NSInteger photoHeight = [[postInfo objectForKey:@"photo_height"] integerValue];
    if (photoWidth != 0 && photoHeight != 0)
    {
        NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"photo_url"]];
        [self.ivPhoto setImageWithURL:[NSURL URLWithString:strPhotoURL]];
                                       
        self.ivPhoto.frame = CGRectMake(self.ivPhoto.frame.origin.x,
                                        self.viewInfo.frame.origin.y + self.viewInfo.frame.size.height,
                                        self.ivPhoto.frame.size.width,
                                        self.ivPhoto.frame.size.width * photoHeight / photoWidth);
        
        CGRect curFrame = self.lblContent.frame;
        
        if (self.lblContent.hidden == NO)
        {
            CGSize contentSize = [self.lblContent sizeThatFits:CGSizeMake(self.frame.size.width - 16, 99999.0f)];
            int minHeight = MIN(contentSize.height, 150);
            self.lblContent.frame = CGRectMake(curFrame.origin.x, self.ivPhoto.frame.origin.y + self.ivPhoto.frame.size.height + 8, self.frame.size.width - 16, minHeight);
        }
        else
        {
            self.lblContent.frame = CGRectMake(curFrame.origin.x, self.ivPhoto.frame.origin.y + self.ivPhoto.frame.size.height + 8, self.frame.size.width - 16, 0);
        }
        
        self.viewRating.frame = CGRectMake(self.lblClothing.frame.origin.x * 2 + self.lblClothing.frame.size.width,
                                           self.viewRating.frame.origin.y,
                                           (self.frame.size.width - 20) / 2,
                                           self.viewRating.frame.size.height);
        
        float starPadding = 3;
        float starInterval = 1;
        
        float starWidth = (self.viewRating.frame.size.width - starPadding * 2 - starInterval * 4) / 5;
        
        for (int tag = 1; tag < 6; tag++)
        {
            UIView *starView = [self.viewRating viewWithTag:tag];
            starView.frame = CGRectMake(starPadding + (starInterval + starWidth) * (tag - 1),(self.viewRating.frame.size.height - starWidth) / 2, starWidth, starWidth);
        }
        
        curFrame = self.viewContent.frame;
        if (self.lblClothing.hidden == YES && self.viewRating.hidden == YES)
            self.viewContent.frame = CGRectMake(curFrame.origin.x, self.lblContent.frame.origin.y + self.lblContent.frame.size.height + 8, curFrame.size.width, 25);
        else
            self.viewContent.frame = CGRectMake(curFrame.origin.x, self.lblContent.frame.origin.y + self.lblContent.frame.size.height + 8, curFrame.size.width, 45);
    }
    else
    {
        NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [_postInfo objectForKey:@"photo_url"]];
        [self.ivPhoto setImageWithURL:[NSURL URLWithString:strPhotoURL] success:^(UIImage *image) {
            
            [self repositionSubviews];
            [layOut invalidateLayout];
            
        } failure:^(NSError *error) {
        }];
    }
}

@end
