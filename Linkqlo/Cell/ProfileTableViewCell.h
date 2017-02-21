//
//  ProfileTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 12/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileTableViewCellDelegate <NSObject>

- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)textFieldShouldReturn:(UITextField *)textField cell:(UITableViewCell *)cell;

- (void)updateText:(NSString *)newText forCell:(UITableViewCell *)cell;

@end

@interface ProfileTableViewCell : UITableViewCell

@property (nonatomic, assign) id<ProfileTableViewCellDelegate> delegate;

@property (nonatomic, assign) BOOL isEditable;
@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic, assign) IBOutlet UIImageView *ivImage;
@property (nonatomic, assign) IBOutlet UILabel *lblText;
@property (nonatomic, assign) IBOutlet UITextField *txtDetail;

@end
