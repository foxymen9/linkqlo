//
//  SizeInputViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SizeInputViewControllerDelegate <NSObject>

- (void) selectSizeParams:(NSDictionary *)dicSizeParams;

@end

@interface SizeInputViewController : UIViewController

@property (nonatomic, assign) id<SizeInputViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger clothingID;

@property (nonatomic, retain) NSString *strSizeTier;
@property (nonatomic, retain) NSString *strSizeNumber;
@property (nonatomic, retain) NSString *strCutting;
@property (nonatomic, retain) NSString *strSizeSuit;

@property (nonatomic, assign) NSString *strNeck;
@property (nonatomic, assign) NSString *strSleeve;
@property (nonatomic, assign) NSString *strWaist;
@property (nonatomic, assign) NSString *strInseam;

@property (nonatomic, retain) NSString *strSizeShoe;

@end
