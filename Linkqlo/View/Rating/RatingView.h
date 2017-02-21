//
//  RatingView.h
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RatingViewDelegate <NSObject>

- (void) setRating:(NSInteger)newRating;

@end

@interface RatingView : UIView
{
    float m_offset;

    NSInteger rateStars;
    IBOutlet UILabel* lblTitle;
    IBOutlet UILabel* lblText;
    IBOutlet UIImageView* ivBack;
    IBOutlet UIImageView* ivFore;
}

@property (nonatomic, assign) id<RatingViewDelegate> delegate;

-(void)initView:(NSInteger)curRating title:(NSString *)strTitle;

@end
