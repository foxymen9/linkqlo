//
//  GenderTableViewCell.m
//  Linkqlo
//
//  Created by RiSongIl on 1/7/15.
//  Copyright (c) 2015 Linkqlo. All rights reserved.
//

#import "GenderTableViewCell.h"

@implementation GenderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onChangedGender:(id)sender
{
    if (sender == self.sgGender)
    {
        NSString *strGender = @"";
        if (self.sgGender.selectedSegmentIndex == 0)
            strGender = @"male";
        else if (self.sgGender.selectedSegmentIndex == 1)
            strGender = @"female";
        
        if (self.delegate != nil)
            [self.delegate updateGender:strGender];
    }
}

@end
