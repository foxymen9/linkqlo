//
//  SwitchTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 11/4/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchTableViewCellDelegate <NSObject>
- (void) onSwitch:(UIView *)view;
@end

@interface SwitchTableViewCell : UITableViewCell

@property (nonatomic, assign) id<SwitchTableViewCellDelegate> delegate;

@property (nonatomic, assign) IBOutlet UIImageView *ivImage;
@property (nonatomic, assign) IBOutlet UILabel *lblText;
@property (nonatomic, assign) IBOutlet UILabel *lblDetailText;
@property (nonatomic, assign) IBOutlet UISwitch *swSwitch;

@end
