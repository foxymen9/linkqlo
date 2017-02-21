//
//  DataManager.m
//  HelpioMatch
//
//  Created by hanjinghe on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

static DataManager *_shareDataManager;

+ (DataManager *)shareDataManager
{
    @synchronized(self) {
        
        if(_shareDataManager == nil)
        {
            _shareDataManager = [[DataManager alloc] init];
        }
    }
    
    return _shareDataManager;
}

+ (void)releaseDataManager
{
    if(_shareDataManager != nil)
    {
        _shareDataManager = nil;
    }
}

- (id) init
{
	if ( (self = [super init]) )
	{
        self.strDeviceToken = nil;
        
        self.aryBrands = nil;
        self.aryClothingTypes = nil;
        self.currentUserInfo = nil;
	}
	
	return self;
}
/*
- (UIColor *)getBackgroundColor
{
    return [UIColor colorWithRed:LQ_COLOR_RED / 255.f green:LQ_COLOR_GREEN / 255.f blue:LQ_COLOR_BLUE / 255.f alpha:1.0f];
}
*/
- (BOOL)hasDatas
{
    if (self.aryUsernames != nil && self.aryBrands != nil && self.aryClothingTypes != nil)
        return YES;
    
    return NO;
}

- (void)setDeviceToken:(NSString *)strDeviceToken
{
    self.strDeviceToken = strDeviceToken;
}

- (NSString *) getDeviceToken
{
    return self.strDeviceToken;
}

- (void)setUsernamesArray:(NSMutableArray *)aryUsernames
{
    self.aryUsernames = aryUsernames;
}

- (NSMutableArray *)getUsernamesArray
{
    return self.aryUsernames;
}

- (NSString *) getUserName:(NSInteger)userID
{
    if (self.aryUsernames == nil)
        return nil;
    
    for (NSMutableDictionary *userInfo in self.aryUsernames)
    {
        if (userInfo == nil)
            continue;
        
        if ([[userInfo objectForKey:@"user_id"] integerValue] == userID)
        {
            NSString *strUserName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
            return strUserName;
        }
    }
    
    return nil;
}
/*
- (void)setBSISpecsArray:(NSMutableArray *)aryBSISpecs
{
    self.aryBSISpecs = aryBSISpecs;
}

- (NSMutableArray *)getBSISpecsArray
{
    return self.aryBSISpecs;
}

- (NSString *) getBSISpecName:(NSInteger)specID
{
    if (self.aryBSISpecs == nil)
        return nil;
    
    for (NSMutableDictionary *specInfo in self.aryBSISpecs)
    {
        if (specInfo == nil)
            continue;
        
        if ([[specInfo objectForKey:@"spec_id"] integerValue] == specID)
        {
            NSString *strSpecName = [specInfo objectForKey:@"spec_name"];
            return strSpecName;
        }
    }
    
    return nil;
}
*/
- (void)setBrandsArray:(NSMutableArray *)aryBrands
{
    self.aryBrands = aryBrands;
}

- (NSMutableArray *)getBrandsArray
{
    return self.aryBrands;
}

- (NSString *) getBrandName:(NSInteger)brandID
{
    if (self.aryBrands == nil)
        return nil;
    
    for (NSMutableDictionary *brand in self.aryBrands)
    {
        if (brand == nil)
            continue;
        
        if ([[brand objectForKey:@"brand_id"] integerValue] == brandID)
        {
            NSString *strBrandName = [NSString stringWithFormat:@"%@", [brand objectForKey:@"brand_name"]];
            return strBrandName;
        }
    }
    
    return nil;
}

- (void)setClothingTypesArray:(NSMutableArray *)aryClothingTypes
{
    self.aryClothingTypes = aryClothingTypes;
}

- (NSMutableArray *)getClothingTypesArray
{
    return self.aryClothingTypes;
}

- (NSString *) getClothingTypeName:(NSInteger)clothingTypeID
{
    if (self.aryClothingTypes == nil)
        return nil;
    
    for (NSMutableDictionary *clothingType in self.aryClothingTypes)
    {
        if (clothingType == nil)
            continue;
        
        if ([[clothingType objectForKey:@"clothing_id"] integerValue] == clothingTypeID)
        {
            NSString *strClothingTypeName = [NSString stringWithFormat:@"%@", [clothingType objectForKey:@"clothing_type"]];
            return strClothingTypeName;
        }
    }
    
    return nil;
}

- (void)setUserInfo:(NSMutableDictionary *)userInfo
{
    self.currentUserInfo = userInfo;
}

- (NSMutableDictionary *) getUserInfo
{
    return self.currentUserInfo;
}

- (UIFont *)boldFontFromFont:(UIFont *)font
{
    NSString *familyName = [font familyName];
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    for (NSString *fontName in fontNames)
    {
        if ([fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            UIFont *boldFont = [UIFont fontWithName:fontName size:font.pointSize];
            return boldFont;
        }
    }
    return nil;
}

- (NSAttributedString *)convertString:(NSString *)strContent font:(UIFont *)font
{
    if (strContent == nil || font == nil)
        return nil;
    
    UIFont *boldFont = [self boldFontFromFont:font];
    if (boldFont == nil)
        return nil;
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:strContent];
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrString.length)];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:strContent options:0 range:NSMakeRange(0, strContent.length)];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange wordRange = match.range;
        [attrString addAttribute:NSFontAttributeName value:boldFont range:wordRange];
    }
    
    error = nil;
    regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    matches = [regex matchesInString:strContent options:0 range:NSMakeRange(0, strContent.length)];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange wordRange = match.range;
        [attrString addAttribute:NSFontAttributeName value:boldFont range:wordRange];
    }
    
    return (NSAttributedString *)attrString;
}

- (float)calcHeight:(float)height1 height2:(float)height2 isMale:(BOOL)isMale
{
    if (height1 == 0 || height2 == 0)
        return 0;
    
    float baseData = powf((height1 - height2), 2.0);
    baseData = 1 / log10(baseData + 10);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0.377) / (1 - 0.377);
    
    baseData = baseData * 0.2;
    return baseData;
}

- (float)calcWeight:(float)weight1 weight2:(float)weight2 isMale:(BOOL)isMale
{
    if (weight1 == 0 || weight2 == 0)
        return 0;
    
    float baseData = powf((weight1 - weight2), 2.0);
    baseData = 1 / log10(baseData + 10);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0.256) / (1 - 0.256);
    
    baseData = baseData * 0.15;
    return baseData;
}

- (float)calcChestFull:(float)chest1 chest2:(float)chest2 isMale:(BOOL)isMale
{
    if (chest1 == 0 || chest2 == 0)
        return 0;
    
    float baseData = powf((chest1 - chest2), 2.0);
    baseData = 1 / log10(baseData + 10);
    if (isMale)
        baseData = (baseData - 0.355) / (1 - 0.355);
    else
        baseData = (baseData - 0.357) / (1 - 0.357);
    
    baseData = baseData * 0.25;
    return baseData;
}

- (float)calcChestUpper:(float)chest1 chest2:(float)chest2 isMale:(BOOL)isMale
{
    if (chest1 == 0 || chest2 == 0)
        return 0;
    
    float baseData = powf((chest1 - chest2), 2.0);
    baseData = 1 / log10(baseData + 10);
    if (isMale)
        baseData = (baseData - 0.355) / (1 - 0.355);
    else
        baseData = (baseData - 0.357) / (1 - 0.357);
    
    baseData = baseData * 0.2;
    return baseData;
}

- (float)calcWaistFull:(float)waist1 waist2:(float)waist2 isMale:(BOOL)isMale
{
    if (waist1 == 0 || waist2 == 0)
        return 0;
    
    float baseData = powf((waist1 - waist2), 2.0);
    baseData = 1 / log10(baseData + 10);
    if (isMale)
        baseData = (baseData - 0.369) / (1 - 0.369);
    else
        baseData = (baseData - 0.353) / (1 - 0.353);
    
    baseData = baseData * 0.25;
    return baseData;
}

- (float)calcWaistUpper:(float)waist1 waist2:(float)waist2 isMale:(BOOL)isMale
{
    if (waist1 == 0 || waist2 == 0)
        return 0;
    
    float baseData = powf((waist1 - waist2), 2.0);
    baseData = 1 / log10(baseData + 10);
    if (isMale)
        baseData = (baseData - 0.369) / (1 - 0.369);
    else
        baseData = (baseData - 0.353) / (1 - 0.353);
    
    baseData = baseData * 0.2;
    return baseData;
}

- (float)calcWaistLower:(float)waist1 waist2:(float)waist2 isMale:(BOOL)isMale
{
    if (waist1 == 0 || waist2 == 0)
        return 0;
    
    float baseData = powf((waist1 - waist2), 2.0);
    baseData = 1 / log10(baseData + 10);
    if (isMale)
        baseData = (baseData - 0.369) / (1 - 0.369);
    else
        baseData = (baseData - 0.353) / (1 - 0.353);
    
    baseData = baseData * 0.3;
    return baseData;
}

- (float)calcHipFull:(float)hip1 hip2:(float)hip2 isMale:(BOOL)isMale
{
    if (hip1 == 0 || hip2 == 0)
        return 0;
    
    float baseData = powf((hip1 - hip2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0.177) / (1 - 0.177);
    
    baseData = baseData * 0.15;
    return baseData;
}

- (float)calcHipLower:(float)hip1 hip2:(float)hip2 isMale:(BOOL)isMale
{
    if (hip1 == 0 || hip2 == 0)
        return 0;
    
    float baseData = powf((hip1 - hip2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0.177) / (1 - 0.177);
    
    baseData = baseData * 0.3;
    return baseData;
}

- (float)calcNeck:(float)neck1 neck2:(float)neck2 isMale:(BOOL)isMale
{
    if (neck1 == 0 || neck2 == 0)
        return 0;
    
    float baseData = powf((neck1 - neck2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0.263) / (1 - 0.263);
    else
        baseData = (baseData - 0) / (1 - 0);
    
    baseData = baseData * 0.05;
    return baseData;
}

- (float)calcShoulder:(float)shoulder1 shoulder2:(float)shoulder2 isMale:(BOOL)isMale
{
    if (shoulder1 == 0 || shoulder2 == 0)
        return 0;
    
    float baseData = powf((shoulder1 - shoulder2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0.319) / (1 - 0.319);
    else
        baseData = (baseData - 0.525) / (1 - 0.525);
    
    baseData = baseData * 0.2;
    return baseData;
}

- (float)calcArmLength:(float)length1 length2:(float)length2 isMale:(BOOL)isMale
{
    if (length1 == 0 || length2 == 0)
        return 0;
    
    float baseData = powf((length1 - length2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0.223) / (1 - 0.223);
    else
        baseData = (baseData - 0.223) / (1 - 0.223);
    
    baseData = baseData * 0.1;
    return baseData;
}

- (float)calcTorsoLength:(float)length1 length2:(float)length2 isMale:(BOOL)isMale
{
    if (length1 == 0 || length2 == 0)
        return 0;
    
    float baseData = powf((length1 - length2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0.226) / (1 - 0.226);
    else
        baseData = (baseData - 0) / (1 - 0);
    
    baseData = baseData * 0.1;
    return baseData;
}

- (float)calcUpperArmSize:(float)size1 size2:(float)size2 isMale:(BOOL)isMale
{
    if (size1 == 0 || size2 == 0)
        return 0;
    
    float baseData = powf((size1 - size2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0) / (1 - 0);
    
    baseData = baseData * 0.1;
    return baseData;
}

- (float)calcBelly:(float)belly1 belly2:(float)belly2 isMale:(BOOL)isMale
{
    if (belly1 == 0 || belly2 == 0)
        return 0;
    
    float baseData = powf((belly1 - belly2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0) / (1 - 0);
    
    baseData = baseData * 0.05;
    return baseData;
}

- (float)calcLegLength:(float)length1 length2:(float)length2 isMale:(BOOL)isMale
{
    if (length1 == 0 || length2 == 0)
        return 0;
    
    float baseData = powf((length1 - length2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0.301) / (1 - 0.301);
    else
        baseData = (baseData - 0) / (1 - 0);
    
    baseData = baseData * 0.2;
    return baseData;
}

- (float)calcThigh:(float)thigh1 thigh2:(float)thigh2 isMale:(BOOL)isMale
{
    if (thigh1 == 0 || thigh2 == 0)
        return 0;
    
    float baseData = powf((thigh1 - thigh2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0.206) / (1 - 0.206);
    
    baseData = baseData * 0.15;
    return baseData;
}

- (float)calcCalf:(float)calf1 calf2:(float)calf2 isMale:(BOOL)isMale
{
    if (calf1 == 0 || calf2 == 0)
        return 0;
    
    float baseData = powf((calf1 - calf2), 2.0);
    baseData = 1 / log(baseData + 2.71828);
    if (isMale)
        baseData = (baseData - 0) / (1 - 0);
    else
        baseData = (baseData - 0) / (1 - 0);
    
    baseData = baseData * 0.05;
    return baseData;
}

- (float)calcSimilarity:(NSMutableDictionary *)clothingInfo bsiInfo:(NSMutableDictionary *)bsiInfo bsiType:(NSInteger*)bsiType
{
    *bsiType = -1;
    
    if (clothingInfo == nil || clothingInfo.count == 0 || bsiInfo == nil || bsiInfo.count == 0)
        return 0;
    
    NSString *strSpecID = [NSString stringWithFormat:@"%@", [bsiInfo objectForKey:@"spec_id"]];
    if (strSpecID == nil || ![strSpecID isKindOfClass:[NSString class]] || strSpecID.length == 0)
        return 0;
    
    float similarity = 0;
    
    NSString *clothingType = [NSString stringWithFormat:@"%@", [clothingInfo objectForKey:@"clothing_type"]];
    NSMutableDictionary *mySpec = [self.currentUserInfo objectForKey:@"spec"];
    if (mySpec == nil || mySpec.count == 0)
        return 0;
    
//    if ([clothingType isEqualToString:@"Dresses"] ||
//        [clothingType isEqualToString:@"Trenches"]) // Full-Body
    if ([clothingType isEqualToString:@"Dresses"]) // Full-Body
    {
        similarity = [self calcFullSimilarity:bsiInfo];
        
        *bsiType = 1;
    }
    else if ([clothingType isEqualToString:@"Coats"] ||
             [clothingType isEqualToString:@"Sweaters"] ||
             [clothingType isEqualToString:@"T-Shirts"] ||
             [clothingType isEqualToString:@"Tops"] ||
             [clothingType isEqualToString:@"Suits"] ||
             [clothingType isEqualToString:@"Dress Shirts"] ||
             [clothingType isEqualToString:@"Casual Shirts"] ||
             [clothingType isEqualToString:@"Jackets"]) // Upper-Body
    {
        similarity = [self calcUpperSimilarity:bsiInfo];
        
        *bsiType = 2;
    }
    else if ([clothingType isEqualToString:@"Jeans"] ||
             [clothingType isEqualToString:@"Shorts"] ||
             [clothingType isEqualToString:@"Pants"] ||
             [clothingType isEqualToString:@"Tights"] ||
             [clothingType isEqualToString:@"Skirts"]) // Lower-Body
    {
        similarity = [self calcLowerSimilarity:bsiInfo];
        
        *bsiType = 3;
    }
    else if ([clothingType isEqualToString:@"Shoes"])
    {
        *bsiType = 4;
    }
    
    return similarity;
}

- (float)calcSimpleSimilarity:(NSMutableDictionary *)otherBSIInfo
{
    if (otherBSIInfo == nil || otherBSIInfo.count == 0)
        return 0;
    
    NSString *strSpecID = [NSString stringWithFormat:@"%@", [otherBSIInfo objectForKey:@"spec_id"]];
    if (strSpecID == nil || ![strSpecID isKindOfClass:[NSString class]] || strSpecID.length == 0)
        return 0;
    
    float similarity = 0;
    
    NSMutableDictionary *mySpec = [self.currentUserInfo objectForKey:@"spec"];
    if (mySpec == nil || mySpec.count == 0)
        return 0;
    
    NSString *strGender = [NSString stringWithFormat:@"%@", [self.currentUserInfo objectForKey:@"gender"]];
    BOOL isMale = [strGender isEqualToString:@"male"];
    
    // Height
    float height1 = [[mySpec objectForKey:@"height"] floatValue] * 0.3937;
    float height2 = [[otherBSIInfo objectForKey:@"height"] floatValue] * 0.3937;
    similarity += [self calcHeight:height1 height2:height2 isMale:isMale] * 0.65 / 0.2;
    
    // Weight
    float weight1 = [[mySpec objectForKey:@"weight"] floatValue] * 2.20462;
    float weight2 = [[otherBSIInfo objectForKey:@"weight"] floatValue] * 2.20462;
    similarity += [self calcWeight:weight1 weight2:weight2 isMale:isMale] * 0.35 / 0.15;
    
    return similarity;
}

- (float)calcUpperSimilarity:(NSMutableDictionary *)otherBSIInfo
{
    if (otherBSIInfo == nil || otherBSIInfo.count == 0)
        return 0;
    
    NSString *strSpecID = [NSString stringWithFormat:@"%@", [otherBSIInfo objectForKey:@"spec_id"]];
    if (strSpecID == nil || ![strSpecID isKindOfClass:[NSString class]] || strSpecID.length == 0)
        return 0;
    
    float similarity = 0;
    
    NSMutableDictionary *mySpec = [self.currentUserInfo objectForKey:@"spec"];
    if (mySpec == nil || mySpec.count == 0)
        return 0;
    
    NSString *strGender = [NSString stringWithFormat:@"%@", [self.currentUserInfo objectForKey:@"gender"]];
    BOOL isMale = [strGender isEqualToString:@"male"];
    
    // Chest
    float chest1 = [[mySpec objectForKey:@"chest"] floatValue] * 0.3937;
    float chest2 = [[otherBSIInfo objectForKey:@"chest"] floatValue] * 0.3937;
    similarity += [self calcChestUpper:chest1 chest2:chest2 isMale:isMale];
    
    // Waist
    float waist1 = [[mySpec objectForKey:@"waist"] floatValue] * 0.3937;
    float waist2 = [[otherBSIInfo objectForKey:@"waist"] floatValue] * 0.3937;
    similarity += [self calcWaistUpper:waist1 waist2:waist2 isMale:isMale];
    
    // Neck
    float neck1 = [[mySpec objectForKey:@"neck"] floatValue] * 0.3937;
    float neck2 = [[otherBSIInfo objectForKey:@"neck"] floatValue] * 0.3937;
    similarity += [self calcNeck:neck1 neck2:neck2 isMale:isMale];
    
    // Shoulder
    float shoulder1 = [[mySpec objectForKey:@"shoulder"] floatValue] * 0.3937;
    float shoulder2 = [[otherBSIInfo objectForKey:@"shoulder"] floatValue] * 0.3937;
    similarity += [self calcShoulder:shoulder1 shoulder2:shoulder2 isMale:isMale];
    
    // Arm Length
    float armLength1 = [[mySpec objectForKey:@"arm_length"] floatValue] * 0.3937;
    float armLength2 = [[otherBSIInfo objectForKey:@"arm_length"] floatValue] * 0.3937;
    similarity += [self calcArmLength:armLength1 length2:armLength2 isMale:isMale];
    
    // Torso Length
    float torsoLength1 = [[mySpec objectForKey:@"torso_height"] floatValue] * 0.3937;
    float torsoLength2 = [[otherBSIInfo objectForKey:@"torso_height"] floatValue] * 0.3937;
    similarity += [self calcTorsoLength:torsoLength1 length2:torsoLength2 isMale:isMale];
    
    // Upper Arm Size
    float upperArmSize1 = [[mySpec objectForKey:@"upper_arm_size"] floatValue] * 0.3937;
    float upperArmSize2 = [[otherBSIInfo objectForKey:@"upper_arm_size"] floatValue] * 0.3937;
    similarity += [self calcUpperArmSize:upperArmSize1 size2:upperArmSize2 isMale:isMale];
    
    // Belly
    float belly1 = [[mySpec objectForKey:@"belly"] floatValue] * 0.3937;
    float belly2 = [[otherBSIInfo objectForKey:@"belly"] floatValue] * 0.3937;
    similarity += [self calcBelly:belly1 belly2:belly2 isMale:isMale];
    
    return similarity;
}

- (float)calcLowerSimilarity:(NSMutableDictionary *)otherBSIInfo
{
    if (otherBSIInfo == nil || otherBSIInfo.count == 0)
        return 0;
    
    NSString *strSpecID = [NSString stringWithFormat:@"%@", [otherBSIInfo objectForKey:@"spec_id"]];
    if (strSpecID == nil || ![strSpecID isKindOfClass:[NSString class]] || strSpecID.length == 0)
        return 0;
    
    float similarity = 0;
    
    NSMutableDictionary *mySpec = [self.currentUserInfo objectForKey:@"spec"];
    if (mySpec == nil || mySpec.count == 0)
        return 0;
    
    NSString *strGender = [NSString stringWithFormat:@"%@", [self.currentUserInfo objectForKey:@"gender"]];
    BOOL isMale = [strGender isEqualToString:@"male"];
    
    // Waist
    float waist1 = [[mySpec objectForKey:@"waist"] floatValue] * 0.3937;
    float waist2 = [[otherBSIInfo objectForKey:@"waist"] floatValue] * 0.3937;
    similarity += [self calcWaistLower:waist1 waist2:waist2 isMale:isMale];
    
    // Hip
    float hip1 = [[mySpec objectForKey:@"hip"] floatValue] * 0.3937;
    float hip2 = [[otherBSIInfo objectForKey:@"hip"] floatValue] * 0.3937;
    similarity += [self calcHipLower:hip1 hip2:hip2 isMale:isMale];
    
    // Leg Length
    float legLength1 = [[mySpec objectForKey:@"leg_length"] floatValue] * 0.3937;
    float legLength2 = [[otherBSIInfo objectForKey:@"leg_length"] floatValue] * 0.3937;
    similarity += [self calcLegLength:legLength1 length2:legLength2 isMale:isMale];
    
    // Thigh
    float thigh1 = [[mySpec objectForKey:@"thigh"] floatValue] * 0.3937;
    float thigh2 = [[otherBSIInfo objectForKey:@"thigh"] floatValue] * 0.3937;
    similarity += [self calcThigh:thigh1 thigh2:thigh2 isMale:isMale];
    
    // Calf
    float calf1 = [[mySpec objectForKey:@"calf"] floatValue] * 0.3937;
    float calf2 = [[otherBSIInfo objectForKey:@"calf"] floatValue] * 0.3937;
    similarity += [self calcCalf:calf1 calf2:calf2 isMale:isMale];
    
    return similarity;
}

- (float)calcFullSimilarity:(NSMutableDictionary *)otherBSIInfo
{
    if (otherBSIInfo == nil || otherBSIInfo.count == 0)
        return 0;
    
    NSString *strSpecID = [NSString stringWithFormat:@"%@", [otherBSIInfo objectForKey:@"spec_id"]];
    if (strSpecID == nil || ![strSpecID isKindOfClass:[NSString class]] || strSpecID.length == 0)
        return 0;
    
    float similarity = 0;
    
    NSMutableDictionary *mySpec = [self.currentUserInfo objectForKey:@"spec"];
    if (mySpec == nil || mySpec.count == 0)
        return 0;
    
    NSString *strGender = [NSString stringWithFormat:@"%@", [self.currentUserInfo objectForKey:@"gender"]];
    BOOL isMale = [strGender isEqualToString:@"male"];
    
    // Height
    float height1 = [[mySpec objectForKey:@"height"] floatValue] * 0.3937;
    float height2 = [[otherBSIInfo objectForKey:@"height"] floatValue] * 0.3937;
    similarity += [self calcHeight:height1 height2:height2 isMale:isMale];
    
    // Weight
    float weight1 = [[mySpec objectForKey:@"weight"] floatValue] * 2.20462;
    float weight2 = [[otherBSIInfo objectForKey:@"weight"] floatValue] * 2.20462;
    similarity += [self calcWeight:weight1 weight2:weight2 isMale:isMale];
    
    // Chest
    float chest1 = [[mySpec objectForKey:@"chest"] floatValue] * 0.3937;
    float chest2 = [[otherBSIInfo objectForKey:@"chest"] floatValue] * 0.3937;
    similarity += [self calcChestFull:chest1 chest2:chest2 isMale:isMale];
    
    // Waist
    float waist1 = [[mySpec objectForKey:@"waist"] floatValue] * 0.3937;
    float waist2 = [[otherBSIInfo objectForKey:@"waist"] floatValue] * 0.3937;
    similarity += [self calcWaistFull:waist1 waist2:waist2 isMale:isMale];
    
    // Hip
    float hip1 = [[mySpec objectForKey:@"hip"] floatValue] * 0.3937;
    float hip2 = [[otherBSIInfo objectForKey:@"hip"] floatValue] * 0.3937;
    similarity += [self calcHipFull:hip1 hip2:hip2 isMale:isMale];
    
    return similarity;
}

- (float)calcSimilarity:(NSMutableDictionary *)otherBSIInfo bsiType:(NSInteger *)bsiType
{
    if (otherBSIInfo == nil || otherBSIInfo.count == 0)
        return 0;
    
    *bsiType = 0;
    float highest = [self calcSimpleSimilarity:otherBSIInfo];
    
    for (NSMutableDictionary *clothingInfo in self.aryClothingTypes)
    {
        NSInteger bsiTemp;
        float similarity = [self calcSimilarity:clothingInfo bsiInfo:otherBSIInfo bsiType:&bsiTemp];
        if (similarity > highest)
        {
            *bsiType = bsiTemp;
            highest = similarity;
        }
    }
    
    return highest;
}

- (float)calcSimilarity:(NSMutableDictionary *)otherBSIInfo clothingID:(NSInteger)clothingID bsiType:(NSInteger*)bsiType
{
    *bsiType = -1;
    
    if (otherBSIInfo == nil || otherBSIInfo.count == 0)
        return 0;
    
    if (clothingID == 0)
        return [self calcSimilarity:otherBSIInfo bsiType:bsiType];
    
    for (NSMutableDictionary *clothingInfo in self.aryClothingTypes)
    {
        if ([[clothingInfo objectForKey:@"clothing_id"] integerValue] == clothingID)
            return [self calcSimilarity:clothingInfo bsiInfo:otherBSIInfo bsiType:bsiType];
    }
    
    return 0;
}

- (NSString *)getAnswerString:(NSString *)strTitle forAnswer:(NSInteger)answer
{
    if ([strTitle isEqualToString:@"Waist"] ||
        [strTitle isEqualToString:@"Rear"] ||
        [strTitle isEqualToString:@"Thigh"] ||
        [strTitle isEqualToString:@"Calf"] ||
        [strTitle isEqualToString:@"Collar"] ||
        [strTitle isEqualToString:@"Arm"] ||
        [strTitle isEqualToString:@"Bust"] ||
        [strTitle isEqualToString:@"Chest"] ||
        [strTitle isEqualToString:@"Hip"] ||
        [strTitle isEqualToString:@"Back"] ||
        [strTitle isEqualToString:@"Toe"] ||
        [strTitle isEqualToString:@"Heel"])
    {
        if (answer == 1)
            return @"Tight";
        else if (answer == 2)
            return @"Just Nice";
        else if (answer == 3)
            return @"Loose";
    }
    else if ([strTitle isEqualToString:@"Rise"])
    {
        if (answer == 1)
            return @"Low";
        else if (answer == 2)
            return @"Just Nice";
        else if (answer == 3)
            return @"High";
    }
    else if ([strTitle isEqualToString:@"Shoulder"] ||
             [strTitle isEqualToString:@"Width"])
    {
        if (answer == 1)
            return @"Narrow";
        else if (answer == 2)
            return @"Just Nice";
        else if (answer == 3)
            return @"Broad";
    }
    else if ([strTitle isEqualToString:@"Length"] ||
             [strTitle isEqualToString:@"Sleeves"])
    {
        if (answer == 1)
            return @"Short";
        else if (answer == 2)
            return @"Just Nice";
        else if (answer == 3)
            return @"Long";
    }
    
    return @"Unknown";
}

@end
