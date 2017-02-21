//
//  ProfilePhotoView.m
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "ProfilePhotoView.h"
#import "UIImageView+WebCache.h"

@implementation ProfilePhotoView

- (void)initView:(NSString *)strPhotoURL
{
    ivPhoto.layer.masksToBounds = YES;
    ivPhoto.layer.cornerRadius = ivPhoto.frame.size.width / 2;
    
    [ivPhoto setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    UITapGestureRecognizer* tapBackGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRemove:)];
    [ivBack addGestureRecognizer:tapBackGesture];

    UITapGestureRecognizer* tapForeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRemove:)];
    [ivPhoto addGestureRecognizer:tapForeGesture];

    CGRect rectScreen = [UIScreen mainScreen].bounds;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(rectScreen), CGRectGetHeight(rectScreen));
    ivBack.frame = CGRectMake(0, 0, CGRectGetWidth(rectScreen), CGRectGetHeight(rectScreen));
    ivPhoto.center = ivBack.center;
}

-(void)onRemove:(UITapGestureRecognizer*)gesture
{
    [self removeFromSuperview];
}

@end
