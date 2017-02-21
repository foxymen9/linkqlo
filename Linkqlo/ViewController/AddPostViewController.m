//
//  AddPostViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "AddPostViewController.h"

#import "SelectItemViewController.h"
#import "BrandsViewController.h"
#import "ClothingTypesViewController.h"
#import "InputTextViewController.h"
#import "SizeInputViewController.h"

#import "RatingView.h"
#import "QuestionView.h"
#import "AppDelegate.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import "UIPlaceHolderTextView.h"

#import "StarTableViewCell.h"
#import "ImageTableViewCell.h"
#import "SwitchTableViewCell.h"
#import "ReportTableViewCell.h"
#import "SliderTableViewCell.h"

#import "ContactTableViewCell.h"

#import "UIImageView+WebCache.h"

#import "SVProgressHUD.h"

// AWS
#define BUCKET_NAME @"linkqlo"

#import <AWSiOSSDKv2/S3.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AddPostViewController () <RatingViewDelegate, QuestionViewDelegate, BrandsViewControllerDelegate, ClothingTypesViewControllerDelegate, InputTextViewControllerDelegate, SizeInputViewControllerDelegate, SwitchTableViewCellDelegate, SliderTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    NSMutableArray *_aryImages;
    
    NSInteger _clothingID;
    
    BOOL _hasFittingReport;
    
//    NSInteger _brandID;
    NSString *_strBrand;
    NSString *_strModel;
    
    // Sizing
    NSString *_strWaist;
    NSString *_strInseam;
    NSString *_strNeck;
    NSString *_strSleeve;
    
    NSString *_strSizeTier;
    NSString *_strSizeNumber;
    NSString *_strCutting;
    NSString *_strSizeSuit;

    NSString *_strSizeShoe;
    
    BOOL _isRecommend;
    
    // Ratings
    NSInteger _overAll;
    
    NSInteger _ratingComfort;
    NSInteger _ratingQuality;
    NSInteger _ratingStyle;
    NSInteger _ratingEase;
    NSInteger _ratingDurability;
    NSInteger _ratingOccasion;
    
    NSIndexPath *_currentIndex;
    
    CGRect frameKeyboard;
    BOOL _isAutoAniatmioning;

    NSString *_strKeyword;
    NSMutableDictionary *_dicFittingReport;
    
    // AWS
    NSInteger _uploadSize;
    NSInteger _uploadCount;
    NSInteger _uploadCompleted;
    NSMutableArray *_aryFileURLs;
    NSMutableArray *_aryUploadRequests;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UIScrollView *svImages;
@property (nonatomic, assign) IBOutlet UIView *viewTool;
@property (nonatomic, assign) IBOutlet UILabel *lblPages;
@property (nonatomic, assign) IBOutlet UIButton *btnAddPhoto;
@property (nonatomic, assign) IBOutlet UIButton *btnDelPhoto;

@property (nonatomic, assign) IBOutlet UITableView *tvClothingType;

@property (nonatomic, assign) IBOutlet UIPlaceHolderTextView *txtComment;

@property (nonatomic, assign) IBOutlet UITableView *tvFittingReport;

@property (nonatomic, assign) IBOutlet UITableView *tvContacts;

@property (nonatomic, retain) UIButton *doneButton;

@property (nonatomic, retain) NSMutableArray *aryData;
@property (nonatomic, retain) NSMutableArray *aryDisplay;

@end

@implementation AddPostViewController

- (void)hideKeyboard
{
    [self.txtComment resignFirstResponder];
}

- (void)tapView
{
    [self hideKeyboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _aryImages = [[NSMutableArray alloc] init];
    [_aryImages addObject:self.selectedPhoto];
    
    _hasFittingReport = NO;
    
    self.btnDelPhoto.hidden = YES;
   
    _clothingID = 0;
//    _brandID = 0;
    _strBrand = nil;
    _strModel = nil;
    
    // Sizing
    _strWaist = nil;
    _strInseam = nil;
    _strNeck = nil;
    _strSleeve = nil;
    
    _strSizeTier = nil;
    _strSizeNumber = nil;
    _strCutting = nil;
    _strSizeSuit = nil;
    
    _strSizeShoe = nil;
    
    _isRecommend = YES;
    
    _isAutoAniatmioning = NO;
    
    // Ratings
    _overAll = 3;
    
    _ratingComfort = 3;
    _ratingQuality = 3;
    _ratingStyle = 3;
    _ratingEase = 3;
    _ratingDurability = 3;
    _ratingOccasion = 3;
    
    _currentIndex = nil;
    
    self.txtComment.placeholder = @"Add a comment here. Type @ to tag people or # to tag brands ...";
    
    CGFloat contentSize = 0;
    if (self.selectedPhoto != nil)
    {
//        NSInteger imageWidth = CGImageGetWidth([self.selectedPhoto CGImage]);
//        NSInteger imageHeight = CGImageGetHeight([self.selectedPhoto CGImage]);
//        self.svImages.frame = CGRectMake(self.svImages.frame.origin.x, self.svImages.frame.origin.y, self.svImages.frame.size.width, self.svImages.frame.size.width * imageHeight / imageWidth);
        self.svImages.frame = CGRectMake(self.svImages.frame.origin.x, self.svImages.frame.origin.y, self.svImages.frame.size.width, self.svImages.frame.size.width * 9 / 16);
    }
    else
    {
        self.svImages.frame = CGRectMake(self.svImages.frame.origin.x, self.svImages.frame.origin.y, self.svImages.frame.size.width, self.svImages.frame.size.width / 4 * 3);
    }
    contentSize += self.svImages.frame.origin.y + self.svImages.frame.size.height;
    
    self.viewTool.frame = CGRectMake(self.viewTool.frame.origin.x, contentSize - 40, self.viewTool.frame.size.width, 40);
    
    self.tvClothingType.frame = CGRectMake(self.tvClothingType.frame.origin.x, contentSize, self.tvClothingType.frame.size.width, self.tvClothingType.frame.size.height);
    contentSize += self.tvClothingType.frame.size.height;
    
    self.txtComment.frame = CGRectMake(self.txtComment.frame.origin.x, contentSize, self.txtComment.frame.size.width, self.txtComment.frame.size.height);
    contentSize += self.txtComment.frame.size.height;
    
    [self.tvFittingReport reloadData];
    self.tvFittingReport.frame = CGRectMake(self.tvFittingReport.frame.origin.x, contentSize, self.tvFittingReport.frame.size.width, self.tvFittingReport.contentSize.height);
    contentSize += self.tvFittingReport.contentSize.height;

    self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.svMain.frame), contentSize);

    self.aryData = [[NSMutableArray alloc] init];
    
    _strKeyword = nil;
    _dicFittingReport = nil;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UIBarButtonItem *flexibleButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(hideKeyboard)];
    [doneButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                              forState:UIControlStateNormal];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:flexibleButton, doneButton, nil];
    [toolbar setItems:itemsArray];
    
    [self.txtComment setInputAccessoryView:toolbar];
    
    [self.tvClothingType registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"image"];
    [self.tvFittingReport registerNib:[UINib nibWithNibName:@"StarTableViewCell" bundle:nil] forCellReuseIdentifier:@"star"];
    [self.tvFittingReport registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"image"];
    [self.tvFittingReport registerNib:[UINib nibWithNibName:@"SwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"switch"];
    [self.tvFittingReport registerNib:[UINib nibWithNibName:@"ReportTableViewCell" bundle:nil] forCellReuseIdentifier:@"report"];
    [self.tvFittingReport registerNib:[UINib nibWithNibName:@"SliderTableViewCell" bundle:nil] forCellReuseIdentifier:@"slider"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"selectitem"])
    {
        SelectItemViewController *vcSelectItem = segue.destinationViewController;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        if (indexPath.row == 0) // Clothing Types
        {
            vcSelectItem.title = @"Clothing Types";
//            vcSelectItem.aryItems = [[DataManager shareDataManager] getClothingTypesArray];
        }
    }
    else if ([segue.identifier isEqualToString:@"clothingtypes"])
    {
        ClothingTypesViewController *vcClothingTypes = segue.destinationViewController;
        vcClothingTypes.delegate = self;
        vcClothingTypes.selectedClothingTypeID = _clothingID;
    }
    else if ([segue.identifier isEqualToString:@"brands"])
    {
        BrandsViewController *vcBrands = segue.destinationViewController;
        vcBrands.delegate = self;
//        vcBrands.selectedBrandID = _brandID;
        vcBrands.selectedBrand = _strBrand;
    }
    else if ([segue.identifier isEqualToString:@"inputvalue"])
    {
        InputTextViewController *vcInputText = segue.destinationViewController;
        vcInputText.isAsciiInput = NO;
        vcInputText.delegate = self;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        vcInputText.index = (int)indexPath.row;
        vcInputText.title = @"Model";
        vcInputText.strValue = _strModel;
    }
    else if ([segue.identifier isEqualToString:@"sizeinput"])
    {
        SizeInputViewController *vcSizeInput = segue.destinationViewController;
        vcSizeInput.delegate = self;
        vcSizeInput.clothingID = _clothingID;
        
        vcSizeInput.strWaist = _strWaist;
        vcSizeInput.strInseam = _strInseam;
        vcSizeInput.strNeck = _strNeck;
        vcSizeInput.strSleeve = _strSleeve;
        
        vcSizeInput.strSizeTier = _strSizeTier;
        vcSizeInput.strSizeNumber = _strSizeNumber;
        vcSizeInput.strCutting = _strCutting;
        vcSizeInput.strSizeSuit = _strSizeSuit;
        
        vcSizeInput.strSizeShoe = _strSizeShoe;
    }
}

- (void)createImageViews
{
    for (UIView *subView in self.svImages.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
            [subView removeFromSuperview];
    }

    NSInteger viewWidth = 0;
    CGRect curRect = self.svImages.frame;
    for (NSInteger imageIndex = 0; imageIndex < _aryImages.count; imageIndex++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[_aryImages objectAtIndex:imageIndex]];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.svImages addSubview:imageView];
        
        viewWidth += curRect.size.width;
        imageView.frame = CGRectMake(imageIndex * curRect.size.width, 0, curRect.size.width, curRect.size.height);
    }
    
    self.svImages.contentSize = CGSizeMake(viewWidth, curRect.size.height);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self createImageViews];
    [self updatePageLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self hideContactView:0.0f];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    frameKeyboard = keyboardRect;
    
    float diff = (keyboardRect.origin.y < self.view.frame.size.height) ? keyboardRect.size.height : 0;
    
    [UIView animateWithDuration:0.2 animations:^
     {
         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x, self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.svMain.frame.origin.y - diff);
         
         if (diff <= 0)
         {
             if (!self.tvContacts.hidden)
                 self.tvContacts.hidden = YES;
         }
         
     } completion:^(BOOL finished) {
         
         if (diff > 0)
         {
             CGFloat yOffset = self.txtComment.frame.origin.y;
             [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, yOffset) animated:NO];
         }
     }];
}

- (IBAction)onBack:(id)sender
{
    [self hideKeyboard];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to cancel?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = 2;
    
    [alertView show];
}

- (IBAction)onAddPhoto:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Camera Roll", nil];
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
}

- (IBAction)onDelPhoto:(id)sender
{
    NSInteger curPage = self.svImages.contentOffset.x / self.svImages.frame.size.width;
    if (curPage == 0 || curPage >= _aryImages.count)
        return;
    
    BOOL isLast = curPage == _aryImages.count - 1;
    
    [_aryImages removeObjectAtIndex:curPage];
    [self createImageViews];
    
    if (isLast)
        self.svImages.contentOffset = CGPointMake((curPage - 1) * self.svImages.frame.size.width, 0);
    else
        self.svImages.contentOffset = CGPointMake(curPage * self.svImages.frame.size.width, 0);
    
    [self updatePageLabel];
    
    if (_aryImages.count == 1)
        self.btnDelPhoto.hidden = YES;
}

- (void)onChangeFittingReport:(id)sender
{
    BOOL isShow = ((UISwitch *)sender).on;
    
    if (isShow)
    {
        if (_clothingID == 0)
        {
            ((UISwitch *)sender).on = NO;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select a clothing type first." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }

    _hasFittingReport = isShow;
    [self.tvFittingReport reloadData];
    
    CGRect curFrame = self.tvFittingReport.frame;
    self.tvFittingReport.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y, curFrame.size.width, self.tvFittingReport.contentSize.height);
    self.svMain.contentSize = CGSizeMake(curFrame.size.width, self.tvFittingReport.frame.origin.y + self.tvFittingReport.frame.size.height);
}

- (NSString *)convertDicionary2String:(NSDictionary *)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData)
        return @"";
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)combineStrings:(NSString *)strOption1 strOption2:(NSString *)strOption2
{
    NSString *strReturn = @"";
    if (strOption1 != nil && strOption1.length > 0)
        strReturn = strOption1;
    
    if (strOption2 != nil && strOption2.length > 0)
    {
        if (strReturn.length > 0)
            strReturn = [NSString stringWithFormat:@"%@/%@", strReturn, strOption2];
        else
            strReturn = strOption2;
    }
    
    return strReturn;
}

- (NSString *)getSizingString
{
    NSString *strSizing = nil;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strGender = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"gender"]];
    if (_clothingID == 1) // Jeans
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = [self combineStrings:_strWaist strOption2:_strInseam];
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 2) // Pants
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = [self combineStrings:_strWaist strOption2:_strInseam];
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 3) // Dress Shirts
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = [self combineStrings:_strNeck strOption2:_strSleeve];
    }
    else if (_clothingID == 4) // Shorts
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = _strWaist;
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 5) // Coats
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = _strSizeTier;
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 6) // Dresses
    {
        if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 7) // Tights
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = [self combineStrings:_strWaist strOption2:_strInseam];
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 8) // T-Shirts
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strCutting];
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    //    else if (_clothingID == 9) // Trenches
    //    {
    //        if ([strGender isEqualToString:@"male"])
    //            strSizing = _strSizeTier;
    //        else if ([strGender isEqualToString:@"female"])
    //            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    //    }
    else if (_clothingID == 10) // Jackets
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = _strSizeTier;
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 11) // Sweaters
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strCutting];
        else if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 12) // Tops
    {
        if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 13) // Suits
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = _strSizeSuit;
    }
    else if (_clothingID == 14) // Cacual Shirts
    {
        if ([strGender isEqualToString:@"male"])
            strSizing = _strSizeTier;
    }
    else if (_clothingID == 15) // Skirts
    {
        if ([strGender isEqualToString:@"female"])
            strSizing = [self combineStrings:_strSizeTier strOption2:_strSizeNumber];
    }
    else if (_clothingID == 16) // Shoes
        strSizing = _strSizeShoe;
    
    return strSizing;
}

- (BOOL)addPost
{
    [JSWaiter ShowWaiter:self title:@"Posting..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return NO;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || strUserID.length == 0)
        return NO;
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    
    [request setObject:strUserID forKey:@"user_id"];
    
    size_t imageWidth = CGImageGetWidth([self.selectedPhoto CGImage]);
    size_t imageHeight = CGImageGetHeight([self.selectedPhoto CGImage]);
    [request setObject:[NSString stringWithFormat:@"%ld", imageWidth] forKey:@"photo_width"];
    [request setObject:[NSString stringWithFormat:@"%ld", imageHeight] forKey:@"photo_height"];
    
    [request setObject:self.txtComment.text forKey:@"content"];
    [request setObject:[NSString stringWithFormat:@"%ld", (long)_clothingID] forKey:@"clothing_id"];
    
    [request setObject:_hasFittingReport ? @"1" : @"0" forKey:@"has_fitting_report"];
    
//    [request setObject:[NSString stringWithFormat:@"%ld", (long)_brandID] forKey:@"brand_id"];
    if (_strBrand == nil) _strBrand = @"";
    [request setObject:_strBrand forKey:@"brand_name"];

    if (_strModel == nil) _strModel = @"";
    [request setObject:_strModel forKey:@"cloth_model"];

    NSString *strSizing = [self getSizingString];
    if (strSizing != nil && strSizing.length > 0)
        [request setObject:strSizing forKey:@"sizing"];
    else
        [request setObject:@"" forKey:@"sizing"];

    [request setObject:[NSString stringWithFormat:@"%ld", (long)_overAll] forKey:@"overall_rating"];
    [request setObject:_isRecommend ? @"1" : @"0" forKey:@"is_recommended"];

//    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingFit] forKey:@"fit_rating"];
//    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingLength] forKey:@"length_rating"];
//    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingWaist] forKey:@"waist_rating"];
//    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingRear] forKey:@"rear_rating"];
//    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingRise] forKey:@"rise_rating"];
//    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingLeg] forKey:@"leg_rating"];
    if (_dicFittingReport != nil)
    {
        NSString *strFittingReport = [self convertDicionary2String:_dicFittingReport];
        [request setObject:strFittingReport forKey:@"fitting_report"];
    }
    
    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingComfort] forKey:@"comfort_rating"];
    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingQuality] forKey:@"quality_rating"];
    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingStyle] forKey:@"style_rating"];
    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingEase] forKey:@"ease_rating"];
    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingDurability] forKey:@"durability_rating"];
    [request setObject:[NSString stringWithFormat:@"%ld", (long)_ratingOccasion] forKey:@"occasion_rating"];

    NSString *strFileURLs = @"";
    for (NSString *strFileURL in _aryFileURLs)
    {
        if (strFileURLs.length == 0)
            strFileURLs = strFileURL;
        else
            strFileURLs = [NSString stringWithFormat:@"%@,%@", strFileURLs, strFileURL];
    }

    [request setObject:strFileURLs forKey:@"photo_urls"];
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"add_post" request:(NSMutableDictionary *)request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return NO;
        }
        else // Success
        {
            return YES;
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return NO;
}

- (unsigned long long)getFileSize:(NSString *)filePath
{
    NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if (fileAttr == nil)
        return (unsigned long long)0;
    
    return fileAttr.fileSize;
}

- (void)cancelUpload
{
    _aryUploadRequests = nil;
    
    [SVProgressHUD dismiss];
}

- (void)completeUpload
{
    _aryUploadRequests = nil;
    
    [SVProgressHUD dismiss];
    
    if ([self addPost])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Posted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alertView.tag = 1;
        [alertView show];
    }
}

- (void)updateProgress
{
    CGFloat progress = (CGFloat)_uploadCompleted / (CGFloat)_uploadSize;
    [SVProgressHUD showProgress:progress status:@"Uploading" maskType:SVProgressHUDMaskTypeBlack];
}

- (void)uploadToAWS
{
    [SVProgressHUD showProgress:0.0f status:@"Uploading" maskType:SVProgressHUDMaskTypeBlack];
    
    _uploadSize = 0;
    _uploadCount = 0;
    _uploadCompleted = 0;
    
    // Upload to AWS first.
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate* currentDate = [NSDate date];
    NSTimeZone* currentTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* nowTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:currentDate];
    NSInteger nowGMTOffset = [nowTimeZone secondsFromGMTForDate:currentDate];
    
    NSTimeInterval interval = nowGMTOffset - currentGMTOffset;
    NSDate* nowDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
    
    NSString *strFolder = [formatter stringFromDate:nowDate];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    _aryFileURLs = nil;
    _aryFileURLs = [[NSMutableArray alloc] init];
    
    _aryUploadRequests = nil;
    _aryUploadRequests = [[NSMutableArray alloc] init];
    
    for (NSInteger index = 0; index < _aryImages.count; index++)
    {
        UIImage *image = _aryImages[index];
        
        // Save image
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8f);
        NSString *fileName = @"";
        if (index == 0)
            fileName = @"cover.jpg";
        else
            fileName = [NSString stringWithFormat:@"post%02ld.jpg", (long)index];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; //On le mets au debut
        
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        [imageData writeToFile:filePath atomically:NO];
        
        _uploadCount ++;
        _uploadSize += [self getFileSize:filePath];
        
        __weak typeof(self) weakSelf = self;
        
        AWSS3TransferManagerUploadRequest *request = [AWSS3TransferManagerUploadRequest new];
        request.bucket = BUCKET_NAME;
        
        if (index == 0)
            request.key = [NSString stringWithFormat:@"%@/%@/cover.jpg", strUserID, strFolder];
        else
            request.key = [NSString stringWithFormat:@"%@/%@/photo%02ld.jpg", strUserID, strFolder, (long)index];
        
        [_aryFileURLs addObject:request.key];
        
        request.body = [NSURL fileURLWithPath:filePath];
        request.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                _uploadCompleted += bytesSent;
                [weakSelf updateProgress];
            });
        };
        
        [_aryUploadRequests addObject:request];
    }
    
    __block int uploadCount = 0;
    for (NSInteger index = 0; index < _aryUploadRequests.count; index++)
    {
        __block AWSS3TransferManagerUploadRequest *request = _aryUploadRequests[index];
        [[transferManager upload:request] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (task.error != nil) {
                if (task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused)
                {
                    [self cancelUpload];
                }
            } else {
                NSString *uploadedURL = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@", BUCKET_NAME, request.key];
                
                [_aryFileURLs replaceObjectAtIndex:[_aryFileURLs indexOfObject:request.key] withObject:uploadedURL];
                request = nil;
                
                uploadCount ++;
                if(_uploadCount == uploadCount)
                {
                    [self completeUpload];
                }
            }
            return nil;
        }];
    }
}

- (BOOL)isSizeSet
{
    BOOL isSizeSet = NO;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strGender = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"gender"]];
    if (_clothingID == 1) // Jeans
    {
        if ([strGender isEqualToString:@"male"])
        {
            if ((_strWaist != nil && _strWaist.length > 0) || (_strInseam != nil && _strInseam.length > 0))
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 2) // Pants
    {
        if ([strGender isEqualToString:@"male"])
        {
            if ((_strWaist != nil && _strWaist.length > 0) || (_strInseam != nil && _strInseam.length > 0))
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 3) // Dress Shirts
    {
        if ([strGender isEqualToString:@"male"])
        {
            if ((_strNeck != nil && _strNeck.length > 0) || (_strSleeve != nil && _strSleeve.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 4) // Shorts
    {
        if ([strGender isEqualToString:@"male"])
        {
            if (_strWaist != nil && _strWaist.length > 0)
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 5) // Coats
    {
        if ([strGender isEqualToString:@"male"])
        {
            if (_strSizeTier != nil && _strSizeTier.length > 0)
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 6) // Dresses
    {
        if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 7) // Tights
    {
        if ([strGender isEqualToString:@"male"])
        {
            if ((_strWaist != nil && _strWaist.length > 0) || (_strInseam != nil && _strInseam.length > 0))
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 8) // T-Shirts
    {
        if ([strGender isEqualToString:@"male"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strCutting != nil && _strCutting.length > 0))
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
//    else if (_clothingID == 9) // Trenches
//    {
//        if ([strGender isEqualToString:@"male"])
//        {
//            if (_strSizeTier != nil && _strSizeTier.length > 0)
//                isSizeSet = YES;
//        }
//        else if ([strGender isEqualToString:@"female"])
//        {
//            if (_strSizeTier != nil && _strSizeTier.length > 0 && _strSizeNumber != nil && _strSizeNumber.length > 0)
//                isSizeSet = YES;
//        }
//    }
    else if (_clothingID == 10) // Jackets
    {
        if ([strGender isEqualToString:@"male"])
        {
            if (_strSizeTier != nil && _strSizeTier.length > 0)
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 11) // Sweaters
    {
        if ([strGender isEqualToString:@"male"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strCutting != nil && _strCutting.length > 0))
                isSizeSet = YES;
        }
        else if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 12) // Tops
    {
        if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 13) // Suits
    {
        if ([strGender isEqualToString:@"male"])
        {
            if (_strSizeSuit != nil && _strSizeSuit.length > 0)
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 14) // Cacual Shirts
    {
        if ([strGender isEqualToString:@"male"])
        {
            if (_strSizeTier != nil && _strSizeTier.length > 0)
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 15) // Skirts
    {
        if ([strGender isEqualToString:@"female"])
        {
            if ((_strSizeTier != nil && _strSizeTier.length > 0) || (_strSizeNumber != nil && _strSizeNumber.length > 0))
                isSizeSet = YES;
        }
    }
    else if (_clothingID == 16) // Shoes
    {
        if (_strSizeShoe != nil && _strSizeShoe.length > 0)
            isSizeSet = YES;
    }
    
    return isSizeSet;
}

- (IBAction)onPost:(id)sender
{
    if (!self.tvContacts.hidden)
    {
        [self hideContactView:0.3f];
        return;
    }
    
    [self hideKeyboard];
    
    NSString *strMessage = nil;
    do {
        if (self.selectedPhoto == nil)
        {
            strMessage = @"Please select an image for this post.";
            break;
        }
        
        if (_clothingID == 0)
        {
            strMessage = @"Please select a clothing type.";
            break;
        }
        
        // Make this field as an optional.
//        if (self.txtComment.text.length == 0)
//        {
//            strMessage = @"Please input a comment for this post.";
//            break;
//        }
        
        if (_hasFittingReport)
        {
            if (_strBrand == nil || _strBrand.length == 0)
            {
                strMessage = @"Please input a brand name.";
                break;
            }

            // Make this field as an optional.
//            if (_strModel == nil || _strModel.length == 0)
//            {
//                strMessage = @"Please input a model name.";
//                break;
//            }
/*
            BOOL isSizeSet = [self isSizeSet];
            if (!isSizeSet)
            {
                strMessage = @"Please input a report for sizing.";
                break;
            }
            
            if (_overAll == 0)
            {
                strMessage = @"Please select overall rating.";
                break;
            }
*/
        }
    } while (FALSE);
    
    if (strMessage != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
//    if ([self addPost])
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Posted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        alertView.tag = 1;
//        [alertView show];
//    }
    [self uploadToAWS];
}

- (void) showContactView:(CGFloat)top duration:(float)duration
{
    self.tvContacts.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 150);
    [self.view bringSubviewToFront:self.tvContacts];
    
    self.aryDisplay = [self.aryData mutableCopy];
    [self.tvContacts reloadData];

    self.tvContacts.hidden = NO;
    
    [UIView animateWithDuration:duration animations:^{

        CGFloat height = frameKeyboard.origin.y - top;
        self.tvContacts.frame = CGRectMake(self.tvContacts.frame.origin.x,
                                           top,
                                           CGRectGetWidth(self.tvContacts.frame),
                                           height);

    } completion:^(BOOL finished) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.title = @"";
        self.navigationItem.rightBarButtonItem.title = @"Cancel";
    }];
}

- (void) hideContactView:(float)duration
{
    [UIView animateWithDuration:duration animations:^{
        
        self.tvContacts.frame = CGRectMake(self.tvContacts.frame.origin.x,
                                           CGRectGetHeight(self.view.frame),
                                           CGRectGetWidth(self.tvContacts.frame),
                                           CGRectGetHeight(self.tvContacts.frame));
        
    } completion:^(BOOL finished) {
        
        self.tvContacts.hidden = YES;
        
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.title = @"Cancel";
        self.navigationItem.rightBarButtonItem.title = @"Post";
    }];
}

#pragma mark UIScrollViewDelegate

- (void)updatePageLabel
{
    NSInteger pageCount = _aryImages.count;
    NSInteger curPage = self.svImages.contentOffset.x / self.svImages.frame.size.width;
    self.lblPages.text = [NSString stringWithFormat:@"%ld/%ld", (long)(curPage + 1), (long)pageCount];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (scrollView == self.svMain && !_isAutoAniatmioning)
//    {
//        [self hideKeyboard];
//        
//        [self hideContactView:0.3f];
//    }
    
    if (scrollView == self.svImages)
    {
        if (scrollView.contentOffset.x == 0)
            self.btnDelPhoto.hidden = YES;
        else
            self.btnDelPhoto.hidden = NO;
        
        [self updatePageLabel];
    }
}

#pragma mark UITextViewDelegate
/*
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _isAutoAniatmioning = YES;
    
    [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, self.txtComment.frame.origin.y - 75) animated:YES];
    
    [self performSelector:@selector(stopAnimationSetContentOffset) withObject:nil afterDelay:0.5f];
    
    return YES;
}

- (void) stopAnimationSetContentOffset
{
    _isAutoAniatmioning = NO;
}
*/
- (void)textViewDidChange:(UITextView *)textView
{
    return;
/*
    UITextRange *selRange = textView.selectedTextRange;
    NSString *strText = textView.text;
    UIFont *normalFont = [UIFont fontWithName:@"ProximaNova-Regular" size:textView.font.pointSize];
    NSAttributedString *strContent = [[DataManager shareDataManager] convertString:strText font:normalFont];
    textView.attributedText = strContent;
    
    [textView setSelectedTextRange:selRange];
*/
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"@"] || [text isEqualToString:@"#"])
    {
        CGRect _rect = [textView caretRectForPosition:textView.selectedTextRange.end];
        CGFloat yOffset = self.svMain.frame.origin.y;
        yOffset += self.txtComment.frame.origin.y + _rect.origin.y + _rect.size.height;
        yOffset -= self.svMain.contentOffset.y;
        
        [self.aryData removeAllObjects];
        
        if ([text isEqualToString:@"@"])
        {
            for (NSMutableDictionary *userInfo in [[DataManager shareDataManager] getUsernamesArray])
            {
                NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"photo_url"]];
                
                NSString *strContent = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"first_name"]];
                NSString *strDetails = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
                
                NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 strPhotoURL, @"photo",
                                                 strContent, @"content",
                                                 strDetails, @"details",
                                                 nil];
                
                [self.aryData addObject:itemInfo];
            }
        }
        else if ([text isEqualToString:@"#"])
        {
        
            for (NSMutableDictionary *brandInfo in [[DataManager shareDataManager] getBrandsArray])
            {
                NSString *strContent = [NSString stringWithFormat:@"%@", [brandInfo objectForKey:@"brand_name"]];
                
                NSArray* words = [strContent componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* noSpaceString = [words componentsJoinedByString:@""];
                NSString *strDetails = [noSpaceString lowercaseString];
                
                NSMutableDictionary *itemInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 strContent, @"content",
                                                 strDetails, @"details",
                                                 nil];
                
                [self.aryData addObject:itemInfo];
            }
        }
        
        [self showContactView:yOffset duration:0.3f];
        _strKeyword = @"";
    }
    else if ([text isEqualToString:@" "])
    {
        if (!self.tvContacts.hidden)
            [self hideContactView:0.3f];
    }
    else if (!self.tvContacts.hidden)
    {
        const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        if (isBackSpace == -8)
        {
            if (_strKeyword.length > 0)
            {
                NSRange range = NSMakeRange(0, _strKeyword.length - 1);
                if (range.location != NSNotFound)
                    _strKeyword = [_strKeyword substringWithRange:range];
            }
            else
            {
                _strKeyword = @"";
                [self hideContactView:0.3f];
            }
        }
        else
            _strKeyword = [NSString stringWithFormat:@"%@%@", _strKeyword, text];
        
        [self.aryDisplay removeAllObjects];
        
        if (_strKeyword.length == 0)
        {
            self.aryDisplay = [self.aryData mutableCopy];
        }
        else
        {
            for (NSMutableDictionary *itemInfo in self.aryData)
            {
                NSString *strContent = [NSString stringWithFormat:@"%@", [itemInfo objectForKey:@"content"]];
                NSString *strDetails = [NSString stringWithFormat:@"%@", [itemInfo objectForKey:@"details"]];
                if ([strContent rangeOfString:_strKeyword].location != NSNotFound ||
                    [strDetails rangeOfString:_strKeyword].location != NSNotFound)
                {
                    [self.aryDisplay addObject:itemInfo];
                }
            }
        }
        
        [self.tvContacts reloadData];
    }
    
    return YES;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (alertView.tag == 2 && buttonIndex == 1)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tvFittingReport)
    {
        if (!_hasFittingReport)
            return 1;
        
        return 3;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tvClothingType)
    {
        return 1;
    }
    else if(tableView == self.tvFittingReport)
    {
        if (!_hasFittingReport)
        {
            if (section == 0)
                return 1;
            
            return 0;
        }
        else
        {
            if (section == 0)
                return 5;
            else if(section == 1)
            {
                if (_dicFittingReport == nil)
                    return 0;
                
                return _dicFittingReport.allKeys.count;
            }
            else if(section == 2)
                return 7;
        }
    }
    else if (tableView == self.tvContacts)
    {
        if (self.aryDisplay == nil)
            return 0;
        
        return self.aryDisplay.count;
    }
    
    return 0;
}

- (void) onChangeRecommend:(id)sender
{
    UISwitch* switchControl = sender;
    _isRecommend = switchControl.on;
    [self.tvFittingReport reloadData];
}

- (NSString *)getRatingText:(NSInteger)rating
{
    if (rating == 0)
        return @"";
    
    NSString *strRating = [NSString stringWithFormat:@"%ld Stars", (long)rating];
    return strRating;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == self.tvClothingType)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"image"];
    }
    else if (tableView == self.tvFittingReport)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"image"];
            }
            else if (indexPath.row == 0 || indexPath.row == 4)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"switch"];
                SwitchTableViewCell *myCell = (SwitchTableViewCell *)cell;
                
                if (indexPath.row == 0)
                    [myCell.swSwitch addTarget:self action:@selector(onChangeFittingReport:) forControlEvents:UIControlEventValueChanged];
                else if (indexPath.row == 4)
                    [myCell.swSwitch addTarget:self action:@selector(onChangeRecommend:) forControlEvents:UIControlEventValueChanged];
            }
        }
//        else if (indexPath.section == 1)
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"report"];
//        }
//        else if (indexPath.section == 2)
//        {
//            if (indexPath.row == 6)
//                cell = [tableView dequeueReusableCellWithIdentifier:@"report"];
//            else
//                cell = [tableView dequeueReusableCellWithIdentifier:@"star"];
//        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"slider"];
            SliderTableViewCell *myCell = (SliderTableViewCell *)cell;
            myCell.delegate = self;
        }
    }
    else if (tableView == self.tvContacts)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        ContactTableViewCell *myCell = (ContactTableViewCell *)cell;
        
        myCell.ivBack.hidden = !(indexPath.row == 0);
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvClothingType)
    {
        ImageTableViewCell *myCell = (ImageTableViewCell *)cell;
        myCell.ivImage.image = [UIImage imageNamed:@"post_icon_clothingtype"];
        myCell.lblText.text = @"Clothing Type";
        
        if (_clothingID == 0)
            myCell.lblDetailText.text = @"";
        else
            myCell.lblDetailText.text = [[DataManager shareDataManager]getClothingTypeName:_clothingID];
        
        myCell.ivDetail.image = [UIImage imageNamed:@"post_icon_detail"];
    }
    else if (tableView == self.tvFittingReport)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                SwitchTableViewCell *myCell = (SwitchTableViewCell *)cell;
                myCell.ivImage.image = [UIImage imageNamed:@"post_icon_report"];
                myCell.lblText.text = @"Fitting Report";
                myCell.lblDetailText.text = _hasFittingReport ? @"Yes" : @"No";
                myCell.swSwitch.on = _hasFittingReport;
            }
            else if (indexPath.row == 1)
            {
                ImageTableViewCell *myCell = (ImageTableViewCell *)cell;
                myCell.ivImage.image = [UIImage imageNamed:@"post_icon_brand"];
                myCell.lblText.text = @"Brand";
                
//                if (_brandID == 0)
                if (_strBrand == nil)
                    myCell.lblDetailText.text = @"";
                else
                    myCell.lblDetailText.text = _strBrand;//[[DataManager shareDataManager] getBrandName:_brandID];
                
                myCell.ivDetail.image = [UIImage imageNamed:@"post_icon_detail"];
            }
            else if (indexPath.row == 2)
            {
                ImageTableViewCell *myCell = (ImageTableViewCell *)cell;
                myCell.ivImage.image = [UIImage imageNamed:@"post_icon_model"];
                myCell.lblText.text = @"Model";
                
                if (_strModel == nil)
                    myCell.lblDetailText.text = @"";
                else
                    myCell.lblDetailText.text = _strModel;
                
                myCell.ivDetail.image = [UIImage imageNamed:@"post_icon_detail"];
            }
            else if (indexPath.row == 3)
            {
                ImageTableViewCell *myCell = (ImageTableViewCell *)cell;
                myCell.ivImage.image = [UIImage imageNamed:@"post_icon_sizing"];
                myCell.lblText.text = @"Sizing";
                
                BOOL isSizeSet = [self isSizeSet];
                if (!isSizeSet)
                    myCell.lblDetailText.text = @"";
                else
                    myCell.lblDetailText.text = [self getSizingString];
                
                myCell.ivDetail.image = [UIImage imageNamed:@"post_icon_detail"];
            }
            else if (indexPath.row == 4)
            {
                SwitchTableViewCell *myCell = (SwitchTableViewCell *)cell;
                myCell.ivImage.image = [UIImage imageNamed:@"post_icon_recommend"];
                myCell.lblText.text = @"Recommend? (Optional)";
                myCell.lblDetailText.text = _isRecommend ? @"Yes" : @"No";
                myCell.swSwitch.on = _isRecommend;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if(indexPath.section == 1)
        {
//            ReportTableViewCell *myCell = (ReportTableViewCell *)cell;
//            NSString *strTitle = [_dicFittingReport.allKeys objectAtIndex:indexPath.row];
//            myCell.lblText.text = [NSString stringWithFormat:@"%@(Optional)", strTitle];
//            
//            NSInteger curAnswer = [[_dicFittingReport.allValues objectAtIndex:indexPath.row] integerValue];
//            if (curAnswer == 0)
//                myCell.lblDetailText.text = @"";
//            else
//                myCell.lblDetailText.text = [[DataManager shareDataManager] getAnswerString:strTitle forAnswer:curAnswer];
//            
//            myCell.ivDetail.image = [UIImage imageNamed:@"post_icon_detail"];
//            
//            cell.accessoryType = UITableViewCellAccessoryNone;
            SliderTableViewCell *myCell = (SliderTableViewCell *)cell;
            NSString *strTitle = [_dicFittingReport.allKeys objectAtIndex:indexPath.row];
            myCell.lblTitle.text = strTitle;
            myCell.lblReview1.text = [[DataManager shareDataManager] getAnswerString:strTitle forAnswer:1];
            myCell.lblReview2.text = @"";//[[DataManager shareDataManager] getAnswerString:strTitle forAnswer:2];
            myCell.lblReview3.text = [[DataManager shareDataManager] getAnswerString:strTitle forAnswer:3];
            
            NSInteger curAnswer = [[_dicFittingReport.allValues objectAtIndex:indexPath.row] integerValue];
            [myCell setRatingValue:curAnswer];
        }
        else if(indexPath.section == 2)
        {
/*
            if (indexPath.row == 6)
            {
                ReportTableViewCell *myCell = (ReportTableViewCell *)cell;
                
                myCell.lblText.text = @"Occasion (Optional)";
                if (_ratingOccasion == 1)
                    myCell.lblDetailText.text = @"Too Casual";
                else if (_ratingOccasion == 2)
                    myCell.lblDetailText.text = @"Too Formal";
                else
                    myCell.lblDetailText.text = @"";
                
                myCell.ivDetail.image = [UIImage imageNamed:@"post_icon_detail"];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                StarTableViewCell *myCell = (StarTableViewCell *)cell;
                switch (indexPath.row)
                {
                    case 0:
                        myCell.lblText.text = @"Overall Rating";
                        [myCell setStars:(int)_overAll];
                        break;
                        
                    case 1:
                        myCell.lblText.text = @"Comfort (Optional)";
                        [myCell setStars:(int)_ratingComfort];
                        break;
                        
                    case 2:
                        myCell.lblText.text = @"Quality (Optional)";
                        [myCell setStars:(int)_ratingQuality];
                        break;
                        
                    case 3:
                        myCell.lblText.text = @"Style (Optional)";
                        [myCell setStars:(int)_ratingStyle];
                        break;
                        
                    case 4:
                        myCell.lblText.text = @"Ease of Care (Optional)";
                        [myCell setStars:(int)_ratingEase];
                        break;
                        
                    case 5:
                        myCell.lblText.text = @"Durability (Optional)";
                        [myCell setStars:(int)_ratingDurability];
                        break;
                }
            }
*/
            SliderTableViewCell *myCell = (SliderTableViewCell *)cell;
            switch (indexPath.row)
            {
                case 0:
                    myCell.lblTitle.text = @"Overall Rating";
                    myCell.lblReview1.text = @"1";
                    myCell.lblReview2.text = @"";
                    myCell.lblReview3.text = @"5";
                    
                    [myCell setRatingValue:_overAll];
                    break;
                    
                case 1:
                    myCell.lblTitle.text = @"Comfort";
                    myCell.lblReview1.text = @"1";
                    myCell.lblReview2.text = @"";
                    myCell.lblReview3.text = @"5";
                    
                    [myCell setRatingValue:_ratingComfort];
                    break;
                    
                case 2:
                    myCell.lblTitle.text = @"Quality";
                    myCell.lblReview1.text = @"1";
                    myCell.lblReview2.text = @"";
                    myCell.lblReview3.text = @"5";
                    
                    [myCell setRatingValue:_ratingQuality];
                    break;
                    
                case 3:
                    myCell.lblTitle.text = @"Style";
                    myCell.lblReview1.text = @"1";
                    myCell.lblReview2.text = @"";
                    myCell.lblReview3.text = @"5";
                    
                    [myCell setRatingValue:_ratingStyle];
                    break;
                    
                case 4:
                    myCell.lblTitle.text = @"Ease of Care";
                    myCell.lblReview1.text = @"1";
                    myCell.lblReview2.text = @"";
                    myCell.lblReview3.text = @"5";
                    
                    [myCell setRatingValue:_ratingEase];
                    break;
                    
                case 5:
                    myCell.lblTitle.text = @"Durability";
                    myCell.lblReview1.text = @"1";
                    myCell.lblReview2.text = @"";
                    myCell.lblReview3.text = @"5";
                    
                    [myCell setRatingValue:_ratingDurability];
                    break;
                    
                case 6:
                    myCell.lblTitle.text = @"Occasion";
                    myCell.lblReview1.text = @"Casual";
                    myCell.lblReview2.text = @"";
                    myCell.lblReview3.text = @"Formal";
                    
                    [myCell setRatingValue:_ratingOccasion];
                    break;
                default:
                    break;
            }
        }
    }
    else if (tableView == self.tvContacts)
    {
        NSMutableDictionary *itemInfo = [self.aryDisplay objectAtIndex:indexPath.row];
        if (itemInfo != nil)
        {
            ContactTableViewCell *myCell = (ContactTableViewCell *)cell;
            NSString *strPhotoURL = [itemInfo objectForKey:@"photo"];
            if (strPhotoURL != nil)
            {
                myCell.ivProfile.hidden = NO;
                [myCell.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL]];
            }
            else
            {
                myCell.ivProfile.hidden = YES;
                myCell.ivProfile.image = nil;
            }
            
            myCell.lblFullName.text = [NSString stringWithFormat:@"%@", [itemInfo objectForKey:@"content"]];
            myCell.lblUserName.text = [NSString stringWithFormat:@"%@", [itemInfo objectForKey:@"details"]];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvClothingType)
    {
        [self hideKeyboard];
        [self performSegueWithIdentifier:@"clothingtypes" sender:nil];
    }
    else if(tableView == self.tvFittingReport)
    {
        if(indexPath.section == 0)
        {
            if (indexPath.row == 1)
            {
                [self hideKeyboard];
                [self performSegueWithIdentifier:@"brands" sender:nil];
            }
            else if (indexPath.row == 2)
            {
                [self hideKeyboard];
                [self performSegueWithIdentifier:@"inputvalue" sender:indexPath];
            }
            else if (indexPath.row == 3)
            {
                [self hideKeyboard];
                [self performSegueWithIdentifier:@"sizeinput" sender:nil];
            }
        }
        else if(indexPath.section == 1)
        {
/*
            NSString *strTitle = [_dicFittingReport.allKeys objectAtIndex:indexPath.row];
            NSInteger curAnswer = [[_dicFittingReport objectForKey:strTitle] integerValue];
            
            _currentIndex = indexPath;
            
            NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"QuestionView" owner:self options:nil];
            QuestionView* viewQuestion = [nib objectAtIndex:0];
            viewQuestion.delegate = self;
            [viewQuestion initView:curAnswer forKey:strTitle];
            AppDelegate* app = [[UIApplication sharedApplication] delegate];
            [app.window addSubview:viewQuestion];
*/
        }
        else if (indexPath.section == 2)
        {
/*
            if (indexPath.row < 6)
            {
                NSInteger curRating = 0;
                NSString *strTitle = @"";
                
                if (indexPath.row == 0)
                {
                    curRating = _overAll;
                    strTitle = @"Overall Rating";
                }
                else if (indexPath.row == 1)
                {
                    curRating = _ratingComfort;
                    strTitle = @"Comfort Rating";
                }
                else if (indexPath.row == 2)
                {
                    curRating = _ratingQuality;
                    strTitle = @"Quality Rating";
                }
                else if (indexPath.row == 3)
                {
                    curRating = _ratingStyle;
                    strTitle = @"Style Rating";
                }
                else if (indexPath.row == 4)
                {
                    curRating = _ratingEase;
                    strTitle = @"Ease of Care Rating";
                }
                else if (indexPath.row == 5)
                {
                    curRating = _ratingDurability;
                    strTitle = @"Durability Rating";
                }
                
                _currentIndex = indexPath;
                
                NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"RatingView" owner:self options:nil];
                RatingView* viewRate = [nib objectAtIndex:0];
                viewRate.delegate = self;
                [viewRate initView:curRating title:strTitle];
                AppDelegate* app = [[UIApplication sharedApplication] delegate];
                [app.window addSubview:viewRate];
            }
            else if (indexPath.row == 6)
            {
                NSString *strTitle = @"Occasion";
                NSInteger curAnswer = _ratingOccasion;
                
                _currentIndex = indexPath;
                
                NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"QuestionView" owner:self options:nil];
                QuestionView* viewQuestion = [nib objectAtIndex:0];
                viewQuestion.delegate = self;
                [viewQuestion initView:curAnswer forKey:strTitle];
                AppDelegate* app = [[UIApplication sharedApplication] delegate];
                [app.window addSubview:viewQuestion];
            }
*/
        }
    }
    else if(tableView == self.tvContacts)
    {
        [self hideContactView:0.3f];

        NSMutableDictionary *itemInfo = [self.aryDisplay objectAtIndex:indexPath.row];
        NSString *stringInsert = [NSString stringWithFormat:@"%@", [itemInfo objectForKey:@"details"]];
        
        if (_strKeyword.length > 0)
        {
            UITextRange *selRange = self.txtComment.selectedTextRange;
            UITextPosition *beginning = self.txtComment.beginningOfDocument;
            NSInteger location = [self.txtComment offsetFromPosition:beginning toPosition:selRange.start];
            
            if (location >= _strKeyword.length)
            {
                UITextPosition *start = [self.txtComment positionFromPosition:beginning offset:location - _strKeyword.length];
                UITextPosition *end = [self.txtComment positionFromPosition:start offset:_strKeyword.length];
                UITextRange *textRange = [self.txtComment textRangeFromPosition:start toPosition:end];
                
                [self.txtComment setSelectedTextRange:textRange];
            }
        }
        
//        UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
//        [lPasteBoard containsPasteboardTypes:UIPasteboardTypeListString];
//        NSArray* lPasteBoardItems = [lPasteBoard.items copy];
//        lPasteBoard.string = stringInsert;
        [self.txtComment insertText:[NSString stringWithFormat:@"%@ ", stringInsert]];
//        lPasteBoard.items = lPasteBoardItems;
        
        _strKeyword = @"";
    }
}

#pragma mark RatingViewDelegate

- (void) setRating:(NSInteger)newRating
{
    if (_currentIndex == nil)
        return;
    
    if (_currentIndex.section == 2)
    {
        if (_currentIndex.row == 0)
            _overAll = newRating;
        else if (_currentIndex.row == 1)
            _ratingComfort = newRating;
        else if (_currentIndex.row == 2)
            _ratingQuality = newRating;
        else if (_currentIndex.row == 3)
            _ratingStyle = newRating;
        else if (_currentIndex.row == 4)
            _ratingEase = newRating;
        else if (_currentIndex.row == 5)
            _ratingDurability = newRating;
        else if (_currentIndex.row == 6)
            _ratingOccasion = newRating;
    }
    
    [self.tvFittingReport reloadData];
}

#pragma mark QuestionViewDelegate

- (void)setAnswer:(NSInteger)newAnswer forKey:(NSString *)strKey
{
    if ([strKey isEqualToString:@"Occasion"])
        _ratingOccasion = newAnswer;
    else
        [_dicFittingReport setObject:[NSString stringWithFormat:@"%d", (int)newAnswer] forKey:strKey];
    
    [self.tvFittingReport reloadData];
}

#pragma mark ClothingTypesViewControllerDelegate

- (void)selectClothingType:(NSInteger)clothingTypeID
{
    _clothingID = clothingTypeID;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strGender = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"gender"]];
    BOOL isMale = [strGender isEqualToString:@"male"];
    switch (_clothingID)
    {
        case 0:
            _dicFittingReport = nil;
            break;

        case 1: // Jeans
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Waist",
            @"3", @"Rear",
            @"3", @"Rise",
            @"3", @"Thigh",
            @"3", @"Calf",
            nil];
            break;
            
        case 2: // Pants
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Length",
                                 @"3", @"Waist",
                                 @"3", @"Rear",
                                 @"3", @"Rise",
                                 @"3", @"Thigh",
                                 @"3", @"Calf",
                                 nil];
            break;
            
        case 3: // Dress Shirts(male only)
            _dicFittingReport = nil;
            if (isMale)
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Collar",
                                     @"3", @"Sleeves",
                                     @"3", @"Shoulder",
                                     @"3", @"Length",
                                     @"3", @"Waist",
                                     nil];
            break;
            
        case 4: // Shorts
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Waist",
                                 @"3", @"Rear",
                                 @"3", @"Thigh",
                                 nil];
            break;
            
        case 5: // Coats
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                 @"3", @"Sleeves",
                                 @"3", @"Arm",
                                 @"3", @"Length",
                                 nil];
            break;
            
        case 6: // Dresses(female only)
            _dicFittingReport = nil;
            if (!isMale)
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Bust",
                                     @"3", @"Length",
                                     @"3", @"Hip",
                                     @"3", @"Waist",
                                     nil];
            break;
            
        case 7: // Tights
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Length",
                                 @"3", @"Rear",
                                 nil];
            break;
            
        case 8: // T-Shirts
            _dicFittingReport = nil;
            if (isMale)
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                     @"3", @"Length",
                                     @"3", @"Chest",
                                     nil];
            else
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                     @"3", @"Length",
                                     @"3", @"Bust",
                                     nil];
            break;
            
        case 10: // Jackets
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                 @"3", @"Length",
                                 @"3", @"Sleeves",
                                 @"3", @"Arm",
                                 @"3", @"Waist",
                                 nil];
            break;
            
        case 11: // Sweaters
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                 @"3", @"Length",
                                 @"3", @"Sleeves",
                                 nil];
            break;
            
        case 12: // Tops(female only)
            _dicFittingReport = nil;
            if (!isMale)
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                     @"3", @"Length",
                                     @"3", @"Sleeves",
                                     @"3", @"Bust",
                                     @"3", @"Waist",
                                     nil];
            break;
            
        case 13: // Suits(male only)
            _dicFittingReport = nil;
            if (isMale)
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                     @"3", @"Length",
                                     @"3", @"Sleeves",
                                     @"3", @"Chest",
                                     @"3", @"Arm",
                                     @"3", @"Back",
                                     @"3", @"Waist",
                                     nil];
            break;
            
        case 14: // Casual Shirts(male only)
            _dicFittingReport = nil;
            if (isMale)
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Shoulder",
                                     @"3", @"Sleeves",
                                     @"3", @"Waist",
                                     @"3", @"Length",
                                     @"3", @"Arm",
                                     nil];
            break;
            
        case 15: // Skirts(female only)
            _dicFittingReport = nil;
            if (!isMale)
                _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Waist",
                                     @"3", @"Rear",
                                     @"3", @"Length",
                                     nil];
            break;
            
        case 16: // Shoes
            _dicFittingReport = nil;
            _dicFittingReport = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"3", @"Length",
                                 @"3", @"Width",
                                 @"3", @"Toe",
                                 @"3", @"Heel",
                                 nil];
            break;
            
        default:
            break;
    }
    
    [self.tvClothingType reloadData];
    
    if (self.tvFittingReport.hidden == NO)
    {
        [self.tvFittingReport reloadData];
        CGRect curFrame = self.tvFittingReport.frame;
        self.tvFittingReport.frame = CGRectMake(curFrame.origin.x, curFrame.origin.y, curFrame.size.width, self.tvFittingReport.contentSize.height);
        self.svMain.contentSize = CGSizeMake(curFrame.size.width, self.tvFittingReport.frame.origin.y + self.tvFittingReport.frame.size.height);
    }
}

#pragma mark BrandsViewControllerDelegate

//- (void)selectBrand:(NSInteger)brandID
- (void)selectBrand:(NSString *)strBrand
{
//    _brandID = brandID;
    _strBrand = strBrand;
    [self.tvFittingReport reloadData];
}

#pragma mark InputTextViewControllerDelegate

- (void) acceptText:(NSString *)text forIndex:(int)index
{
    if (index == 2)
        _strModel = text;
    
    [self.tvFittingReport reloadData];
}

#pragma mark SizeInputViewControllerDelegate

- (void) selectSizeParams:(NSDictionary *)dicSizeParams
{
    NSString *strSizeTier = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"size_tier"]];
    if ([strSizeTier isEqualToString:@"N.A."])
        strSizeTier = @"";
    _strSizeTier = strSizeTier;
    
    NSString *strSizeNumber = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"size_number"]];
    if ([strSizeNumber isEqualToString:@"N.A."])
        strSizeNumber = @"";
    _strSizeNumber = strSizeNumber;
    
    NSString *strCutting = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"cutting"]];
    if ([strCutting isEqualToString:@"N.A."])
        strCutting = @"";
    _strCutting = strCutting;
    
    _strSizeSuit = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"size_suit"]];
    
    _strNeck = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"neck"]];
    _strSleeve = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"sleeve"]];
    _strWaist = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"waist"]];
    _strInseam = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"inseam"]];

    _strSizeShoe = [NSString stringWithFormat:@"%@", [dicSizeParams objectForKey:@"size_shoe"]];
    
    [self.tvFittingReport reloadData];
}

#pragma mark WebManagerDelegate

-(void)requestFinished:(id)response
{
    
}

-(void)DownloadSuccess
{
    
}

-(void)uploadCompleted:(id)response
{
    
}

-(void)WebManagerFailed:(NSError*)error
{
    
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength
{
    
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    
}

#pragma mark SwitchTableViewCellDelegate

- (void)onSwitch:(UIView *)view
{
    UISwitch *switchControl = (UISwitch *)view;
    _isRecommend = switchControl.on;
    [self.tvFittingReport reloadData];
}

#pragma mark SliderTableViewCellDelegate

- (void)onValueChanged:(NSInteger)newRating forCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tvFittingReport indexPathForCell:cell];
    if (indexPath.section == 1)
    {
        NSString *strKey = [_dicFittingReport.allKeys objectAtIndex:indexPath.row];
        [_dicFittingReport setObject:[NSString stringWithFormat:@"%d", (int)newRating] forKey:strKey];
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
            _overAll = newRating;
        else if (indexPath.row == 1)
            _ratingComfort = newRating;
        else if (indexPath.row == 2)
            _ratingQuality = newRating;
        else if (indexPath.row == 3)
            _ratingStyle = newRating;
        else if (indexPath.row == 4)
            _ratingEase = newRating;
        else if (indexPath.row == 5)
            _ratingDurability = newRating;
        else if (indexPath.row == 6)
            _ratingOccasion = newRating;
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 2)
    {
        if (buttonIndex == 2) // Cancel
            return;
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (buttonIndex == 0) // Take photo
        {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (buttonIndex == 1) // Choose from Albums
        {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        
        if([UIImagePickerController isSourceTypeAvailable:sourceType])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = sourceType;
            picker.delegate = self;
            picker.editing = NO;
            picker.allowsEditing = YES;
            
            [self.navigationController presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark UINavigationControllerDelegate
#pragma mark UIImagePickerControllerDelegate

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 640;
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution)
    {
        CGFloat ratio = width/height;
        if (ratio > 1)
        {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"image %@", NSStringFromCGSize(imageCopy.size));
    
    return imageCopy;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        editedImage = [self scaleAndRotateImage:editedImage];
        
        [_aryImages addObject:editedImage];
        [self createImageViews];
        self.svImages.contentOffset = CGPointMake(self.svImages.frame.size.width * (_aryImages.count - 1), 0);
        
        [self updatePageLabel];
    }];
}

@end
