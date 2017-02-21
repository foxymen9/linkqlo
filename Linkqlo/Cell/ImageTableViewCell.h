//
//  ImageTableViewCell.h
//  Linkqlo
//
//  Created by hanjinghe on 12/4/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *ivImage;
@property (nonatomic, assign) IBOutlet UILabel *lblText;
@property (nonatomic, assign) IBOutlet UILabel *lblDetailText;
@property (nonatomic, assign) IBOutlet UIImageView *ivDetail;

@end
