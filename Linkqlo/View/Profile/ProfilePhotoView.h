//
//  ProfilePhotoView.h
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePhotoView : UIView
{
    IBOutlet UIImageView* ivBack;
    IBOutlet UIImageView* ivPhoto;
}

-(void)initView:(NSString *)strPhotoURL;

@end
