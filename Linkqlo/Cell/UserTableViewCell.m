//
//  UserTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "UserTableViewCell.h"

#import "UIImageView+WebCache.h"

#import "DataManager.h"

@interface UserTableViewCell ()

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UILabel *lblUsername;
@property (nonatomic, assign) IBOutlet UILabel *lblPercent;
@property (nonatomic, assign) IBOutlet UILabel *lblAddress;

//@property (nonatomic, retain) NSMutableDictionary *userInfo;

@end

@implementation UserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.ivProfile.layer.masksToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    
    self.ivProfile.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.ivProfile.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.btnFollow.layer.masksToBounds = YES;
    self.btnFollow.layer.cornerRadius = self.btnFollow.frame.size.height / 2;

    self.btnFollow.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.btnFollow.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.btnFollow.center = CGPointMake(self.contentView.frame.origin.x + self.contentView.frame.size.width - self.btnFollow.frame.size.width / 2 - 10, self.contentView.center.y);

    UITapGestureRecognizer *tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoView)];
    [self.ivProfile addGestureRecognizer:tapGestur];
    tapGestur = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onFollow:(id)sender
{
    [self.delegate followWithView:self];
}

- (void)setUserInfo:(NSMutableDictionary *)userInfo
{
    if (userInfo == nil)
        return;
    
    [self.ivProfile setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"photo_url"]] placeholderImage:[UIImage imageNamed:@"avatar"]];

    NSString *strUserName = [userInfo objectForKey:@"first_name"];
    if (strUserName.length == 0)
        strUserName = [NSString stringWithFormat:@"@%@", [userInfo objectForKey:@"user_name"]];
    
    self.lblUsername.text = strUserName;
    
    NSString *myGender = [[[DataManager shareDataManager] getUserInfo] objectForKey:@"gender"];
    NSString *userGender = [userInfo objectForKey:@"gender"];
    if ([myGender isEqualToString:userGender])
    {
        NSString *strPercent = nil;
        if ([[userInfo objectForKey:@"bsi_type"] isEqualToString:@"simple"])
            strPercent = [NSString stringWithFormat:@"%ld%% Simple Match", (long)[[userInfo objectForKey:@"similar_percent"] integerValue]];
        else if ([[userInfo objectForKey:@"bsi_type"] isEqualToString:@"upper"])
            strPercent = [NSString stringWithFormat:@"%ld%% Upper Body Match", (long)[[userInfo objectForKey:@"similar_percent"] integerValue]];
        else if ([[userInfo objectForKey:@"bsi_type"] isEqualToString:@"lower"])
            strPercent = [NSString stringWithFormat:@"%ld%% Lower Body Match", (long)[[userInfo objectForKey:@"similar_percent"] integerValue]];
        else if ([[userInfo objectForKey:@"bsi_type"] isEqualToString:@"full"])
            strPercent = [NSString stringWithFormat:@"%ld%% Full Body Match", (long)[[userInfo objectForKey:@"similar_percent"] integerValue]];
        else
        {
            NSInteger bsiType;
            float similarity = [[DataManager shareDataManager] calcSimilarity:userInfo bsiType:&bsiType];
            
            NSString *strBSIType = nil;
            if (bsiType == 0) strBSIType = @"Simple Match";
            else if (bsiType == 1) strBSIType = @"Full Body Match";
            else if (bsiType == 2) strBSIType = @"Upper Body Match";
            else if (bsiType == 3) strBSIType = @"Lower Body Match";
            
            strPercent = [NSString stringWithFormat:@"%ld%% %@", (long)(similarity * 100), strBSIType];
        }
        
        self.lblPercent.text = strPercent;
    }
    else
    {
        self.lblPercent.text = @"";
    }
    
    
    self.lblAddress.text = [userInfo objectForKey:@"location"];
    
    if ([[userInfo objectForKey:@"is_following"] boolValue])
    {
        [self.btnFollow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnFollow setTitle:@"Following" forState:UIControlStateNormal];
        [self.btnFollow setBackgroundColor:[UIColor blackColor]];
    }
    else
    {
        [self.btnFollow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
        [self.btnFollow setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)tapPhotoView
{
    if (self.delegate != nil)
        [self.delegate tapProfilePhoto:self];
}

@end
