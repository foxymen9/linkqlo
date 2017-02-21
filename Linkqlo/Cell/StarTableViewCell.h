//
//  StarTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 12/4/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarTableViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *lblText;

- (void)setStars:(int)numberOfStars;

@end
