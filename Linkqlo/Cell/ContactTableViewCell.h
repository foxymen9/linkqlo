//
//  ContactTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 10/23/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *ivBack;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UILabel *lblFullName;
@property (nonatomic, assign) IBOutlet UILabel *lblUserName;

@end
