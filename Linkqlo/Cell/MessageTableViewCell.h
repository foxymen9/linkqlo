//
//  MessageTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageTableViewCellDelegate <NSObject>

- (void) tapProfilePhoto:(UIView *)view;

@end

@interface MessageTableViewCell : UITableViewCell

@property (nonatomic, assign) id<MessageTableViewCellDelegate> delegate;

//@property (nonatomic, assign) IBOutlet UILabel *lblUpdate;

@property (nonatomic, assign) IBOutlet UILabel *lblClothing;

//@property (nonatomic, assign) IBOutlet UILabel *lblTitle;
@property (nonatomic, assign) IBOutlet UILabel *lblContent;

@property (nonatomic, assign) IBOutlet UIImageView *ivPost;

+ (CGFloat)heightForMessage:(NSDictionary *)messageInfo cellWidth:(NSInteger)cellWidth;

- (NSMutableDictionary *)getMessageInfo;
- (void)setMessageInfo:(NSMutableDictionary *)messageInfo;

@end
