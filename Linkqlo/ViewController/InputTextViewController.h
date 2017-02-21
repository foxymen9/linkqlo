//
//  InputTextViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/15/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputTextViewControllerDelegate <NSObject>

- (void) acceptText:(NSString *)text forIndex:(int)index;

@end

@interface InputTextViewController : UIViewController

@property (nonatomic, assign) id<InputTextViewControllerDelegate> delegate;

@property (nonatomic, assign) int index;

@property (nonatomic, assign) BOOL isAsciiInput;

@property (nonatomic, retain) NSString *strValue;

@end
