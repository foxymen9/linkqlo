//
//  SwitchTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 11/4/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onSwitch:(id)sender
{
    if (self.delegate != nil)
        [self.delegate onSwitch:self.swSwitch];
}

@end
