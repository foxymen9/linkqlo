//
//  CommentTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "CommentTableViewCell.h"

#import "KILabel.h"
#import "UIImageView+WebCache.h"

#import "DataManager.h"

@interface CommentTableViewCell ()
{
    NSMutableDictionary *_commentInfo;
}

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UILabel *lblUsername;
@property (nonatomic, assign) IBOutlet KILabel *lblComment;
@property (nonatomic, assign) IBOutlet UILabel *lblUpdate;
@property (nonatomic, assign) IBOutlet UIButton *btnLike;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _commentInfo = nil;
    
    self.lblComment.automaticLinkDetectionEnabled = YES;
    self.lblComment.linkDetectionTypes = KILinkDetectionTypeUserHandle | KILinkDetectionTypeHashtag;
    self.lblComment.linkTapHandler = ^(KILinkType linkType, NSString *string, NSRange range) {
        if (linkType == KILinkTypeUserHandle || linkType == KILinkTypeHashtag)
        {
            if (self.delegate != nil)
                [self.delegate tapLink:string];
        }
    };
    
    self.ivProfile.clipsToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    self.ivProfile.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.ivProfile.layer.borderColor = [[UIColor blackColor] CGColor];

    UITapGestureRecognizer *tapGestur = nil;
    tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto)];
    [self.ivProfile addGestureRecognizer:tapGestur];
    tapGestur = nil;

    tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto)];
    [self.lblUsername addGestureRecognizer:tapGestur];
    tapGestur = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForComment:(NSDictionary *)comment cellWidth:(NSInteger)cellWidth
{
    CGFloat contentHeight = 0;
    
    // Post content
    NSString *strContent = [NSString stringWithFormat:@"%@", [comment objectForKey:@"comment"]];
    NSData *encodedData = [strContent dataUsingEncoding:NSUTF8StringEncoding];
    strContent = [[NSString alloc] initWithData:encodedData encoding:NSNonLossyASCIIStringEncoding];
    if (strContent.length > 0)
    {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
        label.text = strContent;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        label.adjustsFontSizeToFitWidth = NO;
        CGSize contentSize = [label sizeThatFits:CGSizeMake((cellWidth - 104), 99999.0f)];
        contentHeight = contentSize.height + 30;
        label = nil;
    }
    
    return MAX(66, contentHeight);
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

- (NSMutableDictionary *)getCommentInfo
{
    return _commentInfo;
}

- (void)setCommentInfo:(NSMutableDictionary *)commentInfo
{
    _commentInfo = commentInfo;
    
    self.lblUpdate.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.lblUpdate.frame) / 2 - 10, self.lblUpdate.center.y);
    self.btnLike.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.btnLike.frame) / 2 - 10, self.btnLike.center.y);
    self.lblComment.frame = CGRectMake(self.lblComment.frame.origin.x,
                                       self.lblComment.frame.origin.y,
                                       self.frame.size.width - 104,//self.lblComment.frame.origin.x - CGRectGetWidth(self.btnLike.frame) - 20,
                                       self.frame.size.height - 30);
    
    if (_commentInfo == nil)
    {
        self.ivProfile.image = nil;
        
        self.lblUsername.text = @"";
        self.lblComment.text = @"";
        self.lblUpdate.text = @"";
    }
    else
    {
        NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [_commentInfo objectForKey:@"photo_url"]];
        [self.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
        
        NSString *strUserName = [NSString stringWithFormat:@"%@", [_commentInfo objectForKey:@"first_name"]];
        if (strUserName.length == 0)
            strUserName = [NSString stringWithFormat:@"@%@", [_commentInfo objectForKey:@"user_name"]];
        self.lblUsername.text = strUserName;
        
        NSString *strComment = [NSString stringWithFormat:@"%@", [_commentInfo objectForKey:@"comment"]];
        NSData *encodedData = [strComment dataUsingEncoding:NSUTF8StringEncoding];
        strComment = [[NSString alloc] initWithData:encodedData encoding:NSNonLossyASCIIStringEncoding];
//        NSAttributedString *strContent = [[DataManager shareDataManager] convertString:strComment fontSize:self.lblComment.font.pointSize];
//        self.lblComment.attributedText = strContent;
        if (strComment != nil)
            [self.lblComment setText:strComment];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *lastUpdateTime = [formatter dateFromString:[NSString stringWithFormat:@"%@", [_commentInfo objectForKey:@"created"]]];
        NSString *strUdate = [NSString stringWithFormat:@"%@", [self getTimeIntervalString:lastUpdateTime]];
        self.lblUpdate.text = strUdate;
        
        if ([[_commentInfo objectForKey:@"comment_liked"] boolValue])
            [self.btnLike setImage:[UIImage imageNamed:@"whatsnew_icon_love_act@3x.png"] forState:UIControlStateNormal];
        else
            [self.btnLike setImage:[UIImage imageNamed:@"whatsnew_icon_love@3x.png"] forState:UIControlStateNormal];
    }
}

- (void)tapPhoto
{
    if (self.delegate != nil)
    {
        NSString *strUserID = [NSString stringWithFormat:@"%@", [_commentInfo objectForKey:@"user_id"]];
        [self.delegate tapPhoto:strUserID];
    }
}

- (IBAction)onLike:(id)sender
{
    if (self.delegate != nil)
        [self.delegate likeComment:self];
}

@end
