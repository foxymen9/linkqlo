//
//  RegisterViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 12/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController

@property (nonatomic, assign) BOOL showLogoutButton;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;

@end
