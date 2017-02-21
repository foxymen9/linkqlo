//
//  CustomPageControl.m
//  Linkqlo
//
//  Created by hanjinghe on 12/1/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    activeImage = [UIImage imageNamed:@"page_active.png"];
    inactiveImage = [UIImage imageNamed:@"page_inactive.png"];
    
    return self;
}

-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView* dotView = [self.subviews objectAtIndex:i];
        UIImageView* dot = nil;
        
        for (UIView* subview in dotView.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView*)subview;
                break;
            }
        }
        
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotView.frame.size.width, dotView.frame.size.height)];
            [dotView addSubview:dot];
        }
        
        if (i == self.currentPage)
        {
            if(activeImage)
                dot.image = activeImage;
        }
        else
        {
            if (inactiveImage)
                dot.image = inactiveImage;
        }
    }}

-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

@end
