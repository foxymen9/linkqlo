//
//  SignInViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;

@end
