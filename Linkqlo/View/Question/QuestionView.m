//
//  QuestionView.m
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "QuestionView.h"

#import "DataManager.h"

@implementation QuestionView

- (void)setAnswer:(NSInteger)answer
{
    if (answer < 1 || answer > 3)
        return;
    
    if (curAnswer == answer)
    {
        [self onRemove:nil];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        if(answer == 1)
            viewLabel.center = btnOption1.center;
        else if(answer == 2)
            viewLabel.center = btnOption2.center;
        else if(answer == 3)
            viewLabel.center = btnOption3.center;
        
    } completion:^(BOOL finished) {
        
        curAnswer = answer;
        
    }];
}

- (void)initView:(NSInteger)oldAnswer forKey:(NSString *)forKey
{
    if (forKey != nil && forKey.length > 0)
    {
        curKey = forKey;
        lblTitle.text = curKey;
    }
    
    if ([forKey isEqualToString:@"Occasion"])
    {
        [btnOption1 setTitle:@"Too Casual" forState:UIControlStateNormal];
        [btnOption2 setTitle:@"Too Formal" forState:UIControlStateNormal];
        btnOption3.hidden = YES;
    }
    else
    {
        [btnOption1 setTitle:[[DataManager shareDataManager] getAnswerString:forKey forAnswer:1] forState:UIControlStateNormal];
        [btnOption2 setTitle:[[DataManager shareDataManager] getAnswerString:forKey forAnswer:2] forState:UIControlStateNormal];
        [btnOption3 setTitle:[[DataManager shareDataManager] getAnswerString:forKey forAnswer:3] forState:UIControlStateNormal];
    }
    
    [btnOption1 sizeToFit];
    [btnOption2 sizeToFit];
    [btnOption3 sizeToFit];
    
    NSInteger maxWidth = 0;
    if (btnOption1.frame.size.width > maxWidth)
        maxWidth = btnOption1.frame.size.width;
    
    if (btnOption2.frame.size.width > maxWidth)
        maxWidth = btnOption2.frame.size.width;
    
    if (btnOption3.frame.size.width > maxWidth)
        maxWidth = btnOption3.frame.size.width;
    
    viewLabel.frame = CGRectMake(0, 0, maxWidth + 60, btnOption1.frame.size.height + 20);
    
    CGRect rectScreen = [UIScreen mainScreen].bounds;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(rectScreen), CGRectGetHeight(rectScreen));
    ivBack.frame = CGRectMake(0, 0, CGRectGetWidth(rectScreen), CGRectGetHeight(rectScreen));
    
    viewLabel.clipsToBounds = YES;
    viewLabel.layer.cornerRadius = viewLabel.frame.size.height / 2;
    
    if ([forKey isEqualToString:@"Occasion"])
    {
        btnOption1.center = CGPointMake(ivBack.center.x, ivBack.center.y - 30);
        viewLabel.center = btnOption1.center;
        btnOption2.center = CGPointMake(ivBack.center.x, ivBack.center.y + 30);
    }
    else
    {
        btnOption2.center = ivBack.center;
        viewLabel.center = ivBack.center;
        btnOption1.center = CGPointMake(btnOption2.center.x, btnOption2.center.y - 60);
        btnOption3.center = CGPointMake(btnOption2.center.x, btnOption2.center.y + 60);
    }
    
    [self setAnswer:oldAnswer];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRemove:)];
    [ivBack addGestureRecognizer:tapGesture];
}

-(void)onRemove:(UITapGestureRecognizer*)gesture
{
    [self.delegate setAnswer:curAnswer forKey:curKey];
    
    [self removeFromSuperview];
}

- (IBAction)onOption1:(id)sender
{
    [self setAnswer:1];
}

- (IBAction)onOption2:(id)sender
{
    [self setAnswer:2];
}

- (IBAction)onOption3:(id)sender
{
    [self setAnswer:3];
}

@end
