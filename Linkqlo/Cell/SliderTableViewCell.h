//
//  SliderTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 1/5/15.
//  Copyright (c) 2015 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SliderTableViewCellDelegate <NSObject>

- (void)onValueChanged:(NSInteger)newRating forCell:(UITableViewCell *)cell;

@end

@interface SliderTableViewCell : UITableViewCell

@property (nonatomic, assign) id<SliderTableViewCellDelegate> delegate;

@property (nonatomic, assign) IBOutlet UILabel *lblTitle;
@property (nonatomic, assign) IBOutlet UILabel *lblReview1;
@property (nonatomic, assign) IBOutlet UILabel *lblReview2;
@property (nonatomic, assign) IBOutlet UILabel *lblReview3;
@property (nonatomic, assign) IBOutlet UISlider *sliderRating;

- (void)setRatingValue:(NSInteger)value;

@end
