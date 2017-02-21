//
//  CommentTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentTableViewCellDelegate <NSObject>

- (void) tapPhoto:(NSString *)strUserID;
- (void) tapLink:(NSString *)strLink;
- (void) likeComment:(UIView *)view;

@end

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, assign) id<CommentTableViewCellDelegate> delegate;

+ (CGFloat)heightForComment:(NSDictionary *)comment cellWidth:(NSInteger)cellWidth;

- (NSMutableDictionary *)getCommentInfo;
- (void)setCommentInfo:(NSMutableDictionary *)commentInfo;

@end
