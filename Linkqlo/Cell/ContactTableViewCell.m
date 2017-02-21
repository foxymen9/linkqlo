//
//  ContactTableViewCell.m
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.ivProfile.clipsToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
