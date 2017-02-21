//
//  RatingView.m
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "RatingView.h"

@implementation RatingView

- (void)setRating:(NSInteger)index
{
    if (index < 0 || index > 5)
        return;
    
    rateStars = index;
    
    if (index == 0)
        lblText.text = @"";
    else if (index == 1)
        lblText.text = [NSString stringWithFormat:@"%ld Star", (long)index];
    else
        lblText.text = [NSString stringWithFormat:@"%ld Stars", (long)index];
    
    NSString *strImageName = [NSString stringWithFormat:@"rate%ld", (long)index];
    [ivFore setImage:[UIImage imageNamed:strImageName]];
}

- (void)initView:(NSInteger)curRating title:(NSString *)strTitle
{
    if (strTitle != nil && strTitle.length > 0)
        lblTitle.text = strTitle;
    
    CGRect rectScreen = [UIScreen mainScreen].bounds;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(rectScreen), CGRectGetHeight(rectScreen));
    ivBack.frame = CGRectMake(0, 0, CGRectGetWidth(rectScreen), CGRectGetHeight(rectScreen));
    ivFore.center = ivBack.center;
    lblText.frame = CGRectMake(ivFore.frame.origin.x, ivFore.frame.origin.y - 48, ivFore.frame.size.width, ivFore.frame.size.height);
    
    [self setRating:curRating];
    
    UIPanGestureRecognizer* gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMove:)];
    [ivFore addGestureRecognizer:gesture];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRemove:)];
    [ivBack addGestureRecognizer:tapGesture];
}

- (void)onMove:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        m_offset = [recognizer locationInView:ivFore].x;
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled ||
             recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateFailed)
    {
        return;
    }
    
    m_offset = [recognizer locationInView:ivFore].x;
    
    if (m_offset < 30)//25)
        [self setRating:0];
    if (m_offset < 81)//67)
        [self setRating:1];
    else if (m_offset < 148)//123)
        [self setRating:2];
    else if (m_offset < 214)//178)
        [self setRating:3];
    else if (m_offset < 281)//234)
        [self setRating:4];
    else
        [self setRating:5];
}

-(void)onRemove:(UITapGestureRecognizer*)gesture
{
    [self.delegate setRating:rateStars];
    
    [self removeFromSuperview];
}
@end
