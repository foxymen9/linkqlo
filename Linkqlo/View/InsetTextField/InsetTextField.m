//
//  InsetTextField.m
//  Linkqlo
//
//  Created by hanjinghe on 12/17/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "InsetTextField.h"

@interface InsetTextField ()
{
    NSInteger _insetToText;
}

@end

@implementation InsetTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setInset:(NSInteger)newInset
{
    _insetToText = newInset;
}

- (void)awakeFromNib
{
    _insetToText = 5;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect clearButtonRect = [self clearButtonRectForBounds:bounds];
    return CGRectMake(_insetToText, bounds.origin.y, clearButtonRect.origin.x - _insetToText, bounds.size.height);
//    return CGRectInset(bounds, _insetToText, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect clearButtonRect = [self clearButtonRectForBounds:bounds];
    return CGRectMake(_insetToText, bounds.origin.y, clearButtonRect.origin.x - _insetToText, bounds.size.height);
//    return CGRectInset(bounds, _insetToText, 0);
}

@end
