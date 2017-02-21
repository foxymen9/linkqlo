//
//  ProfileTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 12/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "ProfileTableViewCell.h"

@interface ProfileTableViewCell () <UITextFieldDelegate>

@end

@implementation ProfileTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!self.isEditable)
        return NO;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate != nil)
        [self.delegate textFieldDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.delegate != nil)
    {
        [self.delegate updateText:textField.text forCell:self];
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate != nil)
        [self.delegate textFieldShouldReturn:textField cell:self];
    
    return YES;
}

@end
