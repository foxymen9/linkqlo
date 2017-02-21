//
//  MessageTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "MessageTableViewCell.h"

#import "DataManager.h"
#import "UIImageView+WebCache.h"

@interface MessageTableViewCell ()
{
    NSMutableDictionary *_messageInfo;
}

@property (nonatomic, assign) IBOutlet UIImageView *ivImage;

@property (nonatomic, assign) IBOutlet UILabel *lblSimilarity;

@end

@implementation MessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.ivImage.clipsToBounds = YES;
    self.ivImage.layer.cornerRadius = self.ivImage.frame.size.width / 2;
    
    UITapGestureRecognizer *tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoView)];
    [self.ivImage addGestureRecognizer:tapGestur];
    tapGestur = nil;
    
    [self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (UIFont *)boldFontFromFont:(UIFont *)font
{
    NSString *familyName = [font familyName];
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    for (NSString *fontName in fontNames)
    {
        if ([fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            UIFont *boldFont = [UIFont fontWithName:fontName size:font.pointSize];
            return boldFont;
        }
    }
    return nil;
}

+ (NSString *)getTimeIntervalString:(NSDate *)date
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

+ (NSAttributedString *)getContentString:(NSDictionary *)messageInfo font:(UIFont *)font
{
    if (messageInfo == nil || font == nil)
        return nil;
    
    NSMutableAttributedString *strContent = [[NSMutableAttributedString alloc] init];
    
    // Name string - Bold.
    NSString *strFullName = [messageInfo objectForKey:@"first_name"];
    if (strFullName == nil || strFullName.length == 0)
        strFullName = [NSString stringWithFormat:@"@%@", [messageInfo objectForKey:@"user_name"]];

    UIFont *boldFont = [self boldFontFromFont:font];
    if (boldFont == nil)
        return nil;
    
    NSMutableAttributedString *strName = [[NSMutableAttributedString alloc] initWithString:strFullName];
    [strName addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, strName.length)];
    [strContent appendAttributedString:strName];
    
    // Action
    NSString *strAction = @"";
    NSString *strType = [NSString stringWithFormat:@"%@", [messageInfo objectForKey:@"type"]];
    if ([strType isEqualToString:@"like"])
        strAction = @" liked your post.";
    else if ([strType isEqualToString:@"dislike"])
        strAction = @" disliked your post.";
    else if ([strType isEqualToString:@"reshare"])
        strAction = @" re-shared your post.";
    else if ([strType isEqualToString:@"comment"])
        strAction = @" commented on your post";
    else if ([strType isEqualToString:@"mention"])
        strAction = @" mentioned your post";
    else if ([strType isEqualToString:@"comment_like"])
        strAction = @" liked your comment.";
    else if ([strType isEqualToString:@"comment_dislike"])
        strAction = @" disliked your comment.";
    
    if ([strType isEqualToString:@"comment"] || [strType isEqualToString:@"mention"])
    {
        NSData *encodedData = [[messageInfo objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
        strAction = [NSString stringWithFormat:@"%@: %@", strAction, [[NSString alloc] initWithData:encodedData encoding:NSNonLossyASCIIStringEncoding]];
    }
    
    [strContent appendAttributedString:[[DataManager shareDataManager] convertString:strAction font:font]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *lastUpdateTime = [formatter dateFromString:[NSString stringWithFormat:@"%@", [messageInfo objectForKey:@"created"]]];
    NSString *strUpdate = [NSString stringWithFormat:@" %@", [self getTimeIntervalString:lastUpdateTime]];
    
    NSMutableAttributedString *strUpdateAttr = [[NSMutableAttributedString alloc] initWithString:strUpdate];
    [strUpdateAttr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, strUpdateAttr.length)];
    [strContent appendAttributedString:strUpdateAttr];
    
    return strContent;
}

+ (CGFloat)heightForMessage:(NSDictionary *)messageInfo cellWidth:(NSInteger)cellWidth;
{
    CGFloat contentHeight = 0;
    
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
    NSAttributedString *strContent = [MessageTableViewCell getContentString:messageInfo font:font];
    if (strContent.length > 0)
    {
        UILabel *label = [[UILabel alloc] init];
        label.font = font;
        label.attributedText = strContent;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        label.adjustsFontSizeToFitWidth = NO;
        CGSize contentSize = [label sizeThatFits:CGSizeMake((cellWidth - 146), 99999.0f)];
        contentHeight = contentSize.height + 16;
        
        NSString *strClothing = [NSString stringWithFormat:@"%@", [messageInfo objectForKey:@"clothing_id"]];
        if (strClothing != nil && [strClothing isKindOfClass:[NSString class]] && strClothing.length > 0)
            contentHeight += 42;
        
        label = nil;
    }
    
    return MAX(contentHeight, 80);
}

- (NSMutableDictionary *)getMessageInfo
{
    return _messageInfo;
}

- (void)setMessageInfo:(NSMutableDictionary *)messageInfo
{
    _messageInfo = messageInfo;
    
    NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [_messageInfo objectForKey:@"photo_url"]];
    [self.ivImage setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
    self.lblContent.attributedText = [MessageTableViewCell getContentString:_messageInfo font:font];
    
    self.lblContent.frame = CGRectMake(self.lblContent.frame.origin.x,
                                       self.lblContent.frame.origin.y,
                                       self.frame.size.width - 146,
                                       self.lblContent.frame.size.height);
    [self.lblContent sizeToFit];
    
    NSString *strClothing = [NSString stringWithFormat:@"%@", [_messageInfo objectForKey:@"clothing_id"]];
    if (strClothing != nil && [strClothing isKindOfClass:[NSString class]])
    {
        NSInteger bsiType;
        NSInteger clothingID = [strClothing integerValue];

        // Check for same gender.
        NSString *myGender = [NSString stringWithFormat:@"%@", [[[DataManager shareDataManager] getUserInfo] objectForKey:@"gender"]];
        NSString *userGender = [NSString stringWithFormat:@"%@", [_messageInfo objectForKey:@"gender"]];
        if ([myGender isEqualToString:userGender])
        {
            float similarity = [[DataManager shareDataManager] calcSimilarity:_messageInfo clothingID:clothingID bsiType:&bsiType];
            if (similarity == 0)
            {
                bsiType = 0;
                similarity = [[DataManager shareDataManager] calcSimpleSimilarity:_messageInfo];
            }
            
            NSString *strBSIType = nil;
            if (bsiType == 0) strBSIType = @"Simple Match";
            else if (bsiType == 1) strBSIType = @"Full Body Match";
            else if (bsiType == 2) strBSIType = @"Upper Body Match";
            else if (bsiType == 3) strBSIType = @"Lower Body Match";
            else if (bsiType == 4) strBSIType = @"Simple Match";
            
            NSMutableAttributedString *strSimilarity = [[NSMutableAttributedString alloc] init];
            NSString *strPercent = [NSString stringWithFormat:@"%ld%% ", (long)(similarity * 100)];
            [strSimilarity appendAttributedString:[[NSMutableAttributedString alloc] initWithString:strPercent]];
            NSMutableAttributedString *strAttrBSIType = [[NSMutableAttributedString alloc] initWithString:strBSIType];
            [strAttrBSIType addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, strAttrBSIType.length)];
            [strSimilarity appendAttributedString:strAttrBSIType];
            self.lblSimilarity.attributedText = strSimilarity;
        }
        else
        {
            self.lblSimilarity.text = @"";
        }
        
        self.lblSimilarity.frame = CGRectMake(self.lblSimilarity.frame.origin.x,
                                              self.lblContent.frame.origin.y + self.lblContent.frame.size.height,
                                              self.frame.size.width - 146,
                                              self.lblSimilarity.frame.size.height);

        self.lblClothing.frame = CGRectMake(self.lblClothing.frame.origin.x,
                                            self.lblSimilarity.frame.origin.y + self.lblSimilarity.frame.size.height,
                                            self.lblClothing.frame.size.width,
                                            self.lblClothing.frame.size.height);
        
        if (clothingID != 0)
            self.lblClothing.hidden = NO;
        else
            self.lblClothing.hidden = YES;
        
        self.lblClothing.backgroundColor = [UIColor whiteColor];
        self.lblClothing.layer.cornerRadius = CGRectGetHeight(self.lblClothing.frame) / 2;
        self.lblClothing.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        self.lblClothing.layer.borderColor = self.lblClothing.textColor.CGColor;
        
        self.lblClothing.text = [[DataManager shareDataManager] getClothingTypeName:clothingID];
    }
    
    NSString *strPostPhoto = [NSString stringWithFormat:@"%@", [_messageInfo objectForKey:@"cover_photo"]];
    if (strPostPhoto != nil && [strPostPhoto isKindOfClass:[NSString class]] && strPostPhoto.length > 0)
        [self.ivPost setImageWithURL:[NSURL URLWithString:strPostPhoto]];
    
    self.ivPost.center = CGPointMake(self.frame.size.width - 8 - self.ivPost.frame.size.width / 2, self.ivPost.center.y);
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tapPhotoView
{
    if (self.delegate != nil)
        [self.delegate tapProfilePhoto:self];
}

@end
