//
//  InputValueViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputValueViewControllerDelegate <NSObject>

- (void) acceptValue:(float)value forIndex:(int)index forUnit:(BOOL)fUSUnit;

@end

@interface InputValueViewController : UIViewController

@property (nonatomic, assign) id<InputValueViewControllerDelegate> delegate;

//@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, assign) float initial;
@property (nonatomic, assign) BOOL isLength;
@property (nonatomic, assign) BOOL isUSUnit;
@property (nonatomic, assign) int keyIndex;

@end
