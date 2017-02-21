//
//  PostCollectionViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KILabel.h"

@interface PostCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) IBOutlet UIView *viewReshare;
@property (nonatomic, assign) IBOutlet UILabel *lblReshareName;

@property (nonatomic, assign) IBOutlet UIView *viewInfo;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UILabel *lblName;
@property (nonatomic, assign) IBOutlet UILabel *lblPercent;
@property (nonatomic, assign) IBOutlet UILabel *lblUpdate;

@property (nonatomic, assign) IBOutlet UIImageView *ivPhoto;

@property (nonatomic, assign) IBOutlet UIView *viewContent;

//@property (nonatomic, assign) IBOutlet UILabel *lblContent;
@property (nonatomic, assign) IBOutlet KILabel *lblContent;
@property (nonatomic, assign) IBOutlet UILabel *lblLike;
@property (nonatomic, assign) IBOutlet UILabel *lblReply;
@property (nonatomic, assign) IBOutlet UILabel *lblReshare;

@property (nonatomic, assign) IBOutlet UILabel *lblClothing;

@property (nonatomic, assign) IBOutlet UIView *viewRating;

//@property (nonatomic, assign) IBOutlet UIImageView *ivClothing;

+ (CGSize)sizeForPostInfo:(NSMutableDictionary *)postInfo cellWidth:(NSInteger)cellWidth;

- (void)setPostInfo:(NSMutableDictionary *)postInfo layOut:(UICollectionViewLayout *)layOut;

@end
