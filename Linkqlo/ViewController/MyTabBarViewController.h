//
//  MyTabBarViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTabBarViewController : UITabBarController

- (BOOL) isShowTabBar;

- (void) hideTabBar;
- (void) showTabBar;

- (void) updateBadge;

@end
