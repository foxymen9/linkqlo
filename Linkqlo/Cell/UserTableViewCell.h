//
//  UserTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserTableViewCellDelegate <NSObject>

- (void) followWithView:(UIView *)view;

- (void) tapProfilePhoto:(UIView *)view;

@end

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, assign) id<UserTableViewCellDelegate> delegate;

@property (nonatomic, assign) IBOutlet UIButton *btnFollow;

- (void)setUserInfo:(NSMutableDictionary *)userInfo;
//- (NSMutableDictionary *)getUserInfo;

@end
