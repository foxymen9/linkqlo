//
//  BrandsViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BrandsViewControllerDelegate <NSObject>

//- (void) selectBrand:(NSInteger)brandID;
- (void)selectBrand:(NSString *)strBrand;

@end

@interface BrandsViewController : UIViewController

@property (nonatomic, assign) id<BrandsViewControllerDelegate> delegate;

//@property(nonatomic, assign) NSInteger selectedBrandID;
@property(nonatomic, retain) NSString *selectedBrand;

@end
