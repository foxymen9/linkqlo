//
//  PostListViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostListViewController : UIViewController

//@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain) NSString *strAPIName;
@property (nonatomic, retain) NSDictionary *dicRequest;
@property (nonatomic, assign) BOOL isFollowing;

@end
