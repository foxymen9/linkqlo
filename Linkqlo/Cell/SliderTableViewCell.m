//
//  SliderTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 1/5/15.
//  Copyright (c) 2015 Linkqlo. All rights reserved.
//

#import "SliderTableViewCell.h"

@implementation SliderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRatingValue:(NSInteger)value
{
    if ((float)value < self.sliderRating.minimumValue)
        [self.sliderRating setValue:self.sliderRating.minimumValue animated:NO];
    else if ((float)value > self.sliderRating.maximumValue)
        [self.sliderRating setValue:self.sliderRating.maximumValue animated:NO];
    else
        [self.sliderRating setValue:(float)value animated:NO];
}

- (IBAction)onValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSUInteger index = (NSUInteger)(slider.value + 0.5);
    [slider setValue:index animated:NO];
    
    if (self.delegate != nil)
        [self.delegate onValueChanged:index forCell:self];
}

@end
