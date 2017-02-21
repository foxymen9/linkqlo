//
//  DataManager.h
//  HelpioMatch
//
//  Created by hanjinghe on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TEST_MODE

#define LQ_COLOR_RED 74
#define LQ_COLOR_GREEN 193
#define LQ_COLOR_BLUE 192

@interface DataManager : NSObject

@property (nonatomic, retain) NSString *strDeviceToken;

@property (nonatomic, retain) NSMutableArray *aryUsernames;
@property (nonatomic, retain) NSMutableArray *aryBSISpecs;
@property (nonatomic, retain) NSMutableArray *aryBrands;
@property (nonatomic, retain) NSMutableArray *aryClothingTypes;
@property (nonatomic, retain) NSMutableDictionary *currentUserInfo;

+ (DataManager *)shareDataManager;
+ (void)releaseDataManager;

//- (UIColor *)getBackgroundColor;

- (BOOL)hasDatas;

- (void)setDeviceToken:(NSString *)strDeviceToken;
- (NSString *) getDeviceToken;

- (void)setUsernamesArray:(NSMutableArray *)aryUsernames;
- (NSMutableArray *)getUsernamesArray;
- (NSString *) getUserName:(NSInteger)userID;

//- (void)setBSISpecsArray:(NSMutableArray *)aryBSISpecs;
//- (NSMutableArray *)getBSISpecsArray;
//- (NSString *) getBSISpecName:(NSInteger)specID;

- (void)setBrandsArray:(NSMutableArray *)aryBrands;
- (NSMutableArray *)getBrandsArray;
- (NSString *) getBrandName:(NSInteger)brandID;

- (void)setClothingTypesArray:(NSMutableArray *)aryClothingTypes;
- (NSMutableArray *)getClothingTypesArray;
- (NSString *) getClothingTypeName:(NSInteger)clothingTypeID;

- (void)setUserInfo:(NSMutableDictionary *)userInfo;
- (NSMutableDictionary *) getUserInfo;

- (NSAttributedString *)convertString:(NSString *)strContent font:(UIFont *)font;

- (float)calcSimilarity:(NSMutableDictionary *)otherBSIInfo bsiType:(NSInteger *)bsiType;
- (float)calcSimilarity:(NSMutableDictionary *)otherBSIInfo clothingID:(NSInteger)clothingID bsiType:(NSInteger *)bsiType;
- (float)calcSimpleSimilarity:(NSMutableDictionary *)otherBSIInfo;
- (float)calcUpperSimilarity:(NSMutableDictionary *)otherBSIInfo;
- (float)calcLowerSimilarity:(NSMutableDictionary *)otherBSIInfo;
- (float)calcFullSimilarity:(NSMutableDictionary *)otherBSIInfo;

- (NSString *)getAnswerString:(NSString *)strTitle forAnswer:(NSInteger)answer;

@end
