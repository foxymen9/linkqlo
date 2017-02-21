//
//  UIPlaceHolderTextView.h
//  Yoga
//
//  Created by hanjinghe on 9/1/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
