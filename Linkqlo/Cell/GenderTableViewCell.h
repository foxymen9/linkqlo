//
//  GenderTableViewCell.h
//  Linkqlo
//
//  Created by RiSongIl on 1/7/15.
//  Copyright (c) 2015 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GenderTableViewCellDelegate <NSObject>

- (void)updateGender:(NSString *)newGender;

@end

@interface GenderTableViewCell : UITableViewCell

@property (nonatomic, assign) id<GenderTableViewCellDelegate> delegate;

@property (nonatomic, assign) IBOutlet UIImageView *ivImage;
@property (nonatomic, assign) IBOutlet UILabel *lblText;
@property (nonatomic, assign) IBOutlet UISegmentedControl *sgGender;

@end
