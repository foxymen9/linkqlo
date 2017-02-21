//
//  StarTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 12/4/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "StarTableViewCell.h"

@interface StarTableViewCell ()

@property (nonatomic, assign) IBOutlet UIImageView *ivStar1;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar2;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar3;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar4;
@property (nonatomic, assign) IBOutlet UIImageView *ivStar5;

@end

@implementation StarTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initView];
}

- (void)initView
{
    [self.ivStar1 setImage:[UIImage imageNamed:@"post_icon_star"]];
    [self.ivStar2 setImage:[UIImage imageNamed:@"post_icon_star"]];
    [self.ivStar3 setImage:[UIImage imageNamed:@"post_icon_star"]];
    [self.ivStar4 setImage:[UIImage imageNamed:@"post_icon_star"]];
    [self.ivStar5 setImage:[UIImage imageNamed:@"post_icon_star"]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStars:(int)numberOfStars
{
    [self initView];

    if (numberOfStars <= 0 || numberOfStars > 5)
        return;
    
    if (numberOfStars >= 1) [self.ivStar5 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
    if (numberOfStars >= 2) [self.ivStar4 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
    if (numberOfStars >= 3) [self.ivStar3 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
    if (numberOfStars >= 4) [self.ivStar2 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
    if (numberOfStars >= 5) [self.ivStar1 setImage:[UIImage imageNamed:@"post_icon_star_act"]];
}

@end
