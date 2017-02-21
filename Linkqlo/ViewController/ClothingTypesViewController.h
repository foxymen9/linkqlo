//
//  ClothingTypesViewController.h
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClothingTypesViewControllerDelegate <NSObject>

- (void) selectClothingType:(NSInteger)clothingTypeID;

@end

@interface ClothingTypesViewController : UIViewController

@property (nonatomic, assign) id<ClothingTypesViewControllerDelegate> delegate;

@property(nonatomic, assign) NSInteger selectedClothingTypeID;

@end
