//
//  NewSignUpViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 12/10/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "NewSignUpViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface NewSignUpViewController () <WebManagerDelegate>
{
    NSInteger _currentStep;
    
    NSString *_strUserName;
    
    CGFloat _userHeight;
    NSInteger _unitHeight;
    
    CGFloat _userWeight;
    NSInteger _unitWeight;
    NSInteger _userGender;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UIImageView *ivSteps;

@property (nonatomic, assign) IBOutlet UILabel *lblRemark;

@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIButton *btnNext;

@property (nonatomic, assign) IBOutlet UILabel *lblMessage;

@property (nonatomic, assign) IBOutlet UIView *viewStep1;
@property (nonatomic, assign) IBOutlet UITextField *txtUserName;

@property (nonatomic, assign) IBOutlet UIView *viewStep2US;
@property (nonatomic, assign) IBOutlet UIView *viewStep2MT;
@property (nonatomic, assign) IBOutlet UITextField *txtHeightCM;
@property (nonatomic, assign) IBOutlet UITextField *txtHeightFT;
@property (nonatomic, assign) IBOutlet UITextField *txtHeightIN;

@property (nonatomic, assign) IBOutlet UIView *viewStep3;
@property (nonatomic, assign) IBOutlet UITextField *txtWeight;
@property (nonatomic, assign) IBOutlet UILabel *lblUnit;

@property (nonatomic, assign) IBOutlet UIView *viewUnits;
@property (nonatomic, assign) IBOutlet UIButton *btnUS;
@property (nonatomic, assign) IBOutlet UIButton *btnMetrics;

@property (nonatomic, assign) IBOutlet UIView *viewGender;
@property (nonatomic, assign) IBOutlet UIButton *btnMale;
@property (nonatomic, assign) IBOutlet UIButton *btnFemale;

@end

@implementation NewSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _currentStep = 0;
    
    _strUserName = nil;
    _userHeight = 0;
    _unitHeight = 0;
    _userWeight = 0;
    _unitWeight = 0;
    _userGender = 0;
    
    [[self.btnMale imageView] setContentMode:UIViewContentModeScaleAspectFill];
    [[self.btnFemale imageView] setContentMode:UIViewContentModeScaleAspectFill];

//    self.btnMale.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
//    self.btnMale.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;

//    self.btnFemale.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
//    self.btnFemale.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [self.svMain setContentSize:CGSizeMake(self.svMain.contentSize.width, self.lblMessage.frame.origin.y + self.lblMessage.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initView
{
    self.lblMessage.hidden = YES;
    [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, 0)];
    
    if (_currentStep == 0)
    {
        self.lblRemark.hidden = NO;
        [self.ivSteps setImage:[UIImage imageNamed:@"signup_img_step1@3x.png"]];
        [self.btnNext setImage:[UIImage imageNamed:@"signup_btn_next@3x.png"] forState:UIControlStateNormal];
        
        self.viewStep1.hidden = NO;
        self.viewStep2US.hidden = YES;
        self.viewStep2MT.hidden = YES;
        self.viewStep3.hidden = YES;
        self.viewUnits.hidden = YES;
        self.viewGender.hidden = YES;
        
        [self.txtUserName becomeFirstResponder];
    }
    else if (_currentStep == 1)
    {
        self.lblRemark.hidden = YES;
        [self.ivSteps setImage:[UIImage imageNamed:@"signup_img_step2@3x.png"]];
        [self.btnNext setImage:[UIImage imageNamed:@"signup_btn_next@3x.png"] forState:UIControlStateNormal];

        self.viewStep1.hidden = YES;
        
        if (_unitHeight == 0)
        {
            self.viewStep2US.hidden = NO;
            self.viewStep2MT.hidden = YES;
            [self.txtHeightFT becomeFirstResponder];
        }
        else if (_unitHeight == 1)
        {
            self.viewStep2US.hidden = YES;
            self.viewStep2MT.hidden = NO;
            [self.txtHeightCM becomeFirstResponder];
        }
        
        self.viewStep3.hidden = YES;
        self.viewUnits.hidden = NO;
        self.viewGender.hidden = YES;
        
        [self updateUnit:_unitHeight];
    }
    else if (_currentStep == 2)
    {
        self.lblRemark.hidden = YES;
        [self.ivSteps setImage:[UIImage imageNamed:@"signup_img_step3@3x.png"]];
        [self.btnNext setImage:[UIImage imageNamed:@"signup_btn_next@3x.png"] forState:UIControlStateNormal];

        self.viewStep1.hidden = YES;
        self.viewStep2US.hidden = YES;
        self.viewStep2MT.hidden = YES;
        self.viewStep3.hidden = NO;
        self.viewUnits.hidden = NO;
        self.viewGender.hidden = YES;
        
        [self updateUnit:_unitWeight];
        
        if (_unitWeight == 0)
            self.lblUnit.text = @"lbs";
        else if (_unitWeight == 1)
            self.lblUnit.text = @"kgs";
        
        [self.txtWeight becomeFirstResponder];
    }
    else if (_currentStep == 3)
    {
        self.lblRemark.hidden = YES;
        [self.ivSteps setImage:[UIImage imageNamed:@"signup_img_step4@3x.png"]];
        [self.btnNext setImage:[UIImage imageNamed:@"signup_btn_start@3x.png"] forState:UIControlStateNormal];

        self.viewStep1.hidden = YES;
        self.viewStep2US.hidden = YES;
        self.viewStep2MT.hidden = YES;
        self.viewStep3.hidden = YES;
        self.viewUnits.hidden = YES;
        self.viewGender.hidden = NO;
        
        [self.btnMale setImage:[UIImage imageNamed:@"signup_btn_male@3x.png"] forState:UIControlStateNormal];
        [self.btnMale setImage:[UIImage imageNamed:@"signup_btn_male_sel@3x.png"] forState:UIControlStateSelected];

        [self.btnFemale setImage:[UIImage imageNamed:@"signup_btn_female@3x.png"] forState:UIControlStateNormal];
        [self.btnFemale setImage:[UIImage imageNamed:@"signup_btn_female_sel@3x.png"] forState:UIControlStateSelected];
        
        [self updateGender:_userGender];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    
    float diff = (keyboardRect.origin.y < self.view.frame.size.height) ? keyboardRect.size.height : 0;
    
    [UIView animateWithDuration:0.2 animations:^
     {
         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x, self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.svMain.frame.origin.y - diff);
         
     } completion:^(BOOL finished) {
         int offset = self.svMain.contentSize.height - self.svMain.frame.size.height;
         if (offset > 0)
             self.svMain.contentOffset = CGPointMake(self.svMain.contentOffset.x, offset);
     }];
}

- (IBAction)onBack:(id)sender
{
    if (_currentStep > 0)
    {
        _currentStep --;
        [self initView];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showMessage:(NSString *)strMessage
{
    if (strMessage == nil || strMessage.length == 0)
        return;
    
    self.lblMessage.text = strMessage;
    self.lblMessage.hidden = NO;
}

- (NSString *)validateUserName
{
    NSDictionary *request = @{
                              @"user_name"      : self.txtUserName.text,
                              };
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"validate_name" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
            return strError;
        
        return @"";
    }
    else
    {
        return @"Failed to connect to server. Please try again.";
    }
    
    return @"";
}

- (BOOL)checkValues
{
    if (_currentStep == 0)
    {
        if (self.txtUserName.text.length == 0)
        {
            [self showMessage:@"Please input your nickname."];
            return NO;
        }
        
        if (self.txtUserName.text.length < 6)
        {
            [self showMessage:@"The nickname length should be 6 at least."];
            return NO;
        }
        
        [JSWaiter ShowWaiter:self title:@"Checking..." type:0];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        
        NSString *strError = [self validateUserName];
        if (strError.length > 0)
        {
            [self showMessage:strError];
            return NO;
        }
        
        [self.txtUserName resignFirstResponder];
    }
    else if (_currentStep == 1)
    {
        if ((_unitHeight == 0 && self.txtHeightFT.text.length == 0 && self.txtHeightIN.text.length == 0) ||
            (_unitHeight == 1 && self.txtHeightCM.text.length == 0))
        {
            [self showMessage:@"Please input your height."];
            return NO;
        }
        
        if (_unitHeight == 0)
        {
            CGFloat feets = [self.txtHeightFT.text floatValue];
            CGFloat inches = [self.txtHeightIN.text floatValue];
            _userHeight = feets * 30.48 + inches * 2.54;
        }
        else if (_unitHeight == 1)
        {
            _userHeight = [self.txtHeightCM.text floatValue];
        }
        
        [self.txtHeightCM resignFirstResponder];
        [self.txtHeightFT resignFirstResponder];
        [self.txtHeightIN resignFirstResponder];
    }
    else if (_currentStep == 2)
    {
        if (self.txtWeight.text.length == 0)
        {
            [self showMessage:@"Please input your weight."];
            return NO;
        }
        
        if (_unitWeight == 0)
        {
            CGFloat lbs = [self.txtWeight.text floatValue];
            _userWeight = lbs * 0.453592;
        }
        else if (_unitWeight == 1)
        {
            _userWeight = [self.txtWeight.text floatValue];
        }
        
        [self.txtWeight resignFirstResponder];
    }
    
    self.lblMessage.hidden = YES;
    
    return YES;
}

- (BOOL)processSignup
{
    [JSWaiter ShowWaiter:self title:@"Processing..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSString *strUserName = self.txtUserName.text;
    
    NSString *strDeviceToken = [[DataManager shareDataManager] getDeviceToken];
    if (strDeviceToken == nil) strDeviceToken = @"";
    
    NSDictionary *request = @{
                              @"user_name" : strUserName,
                              @"height" : [NSNumber numberWithFloat:_userHeight],
                              @"weight" : [NSNumber numberWithFloat:_userWeight],
                              @"gender" : (_userGender == 0) ? @"male" : @"female",
                              @"device_token" : strDeviceToken,
                              };
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strAPIName = @"newsignup";
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:strAPIName request:(NSMutableDictionary *)request];
    
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
            // Current User Info.
            [[DataManager shareDataManager] setUserInfo:dicRet];
            
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setObject:@"login_name" forKey:@"apiName"];
            request = @{
                        @"user_name" : strUserName,
                        @"device_token" : strDeviceToken,
                        };
            [pref setObject:request forKey:@"loginRequest"];
            [pref synchronize];
            
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

- (void) onNext
{
    if (![self checkValues])
        return;
    
    if (_currentStep < 3)
    {
        _currentStep ++;
        [self initView];
    }
    else
    {
        if ([self processSignup])
            [self performSegueWithIdentifier:@"main" sender:nil];
    }
}

- (IBAction)onNext:(id)sender
{
    [self performSelector:@selector(onNext) withObject:nil afterDelay:0.01f];
}

- (void)updateUnit:(NSInteger)unit
{
    if (unit == 0)
    {
        [self.btnUS.titleLabel setTextColor:[UIColor blackColor]];
        [self.btnUS setBackgroundColor:[UIColor whiteColor]];

        [self.btnMetrics.titleLabel setTextColor:[UIColor colorWithRed:137.f/255.f green:137.f/255.f blue:137.f/255.f alpha:1.0f]];
        [self.btnMetrics setBackgroundColor:[UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.0f]];
    }
    else
    {
        [self.btnUS.titleLabel setTextColor:[UIColor colorWithRed:137.f/255.f green:137.f/255.f blue:137.f/255.f alpha:1.0f]];
        [self.btnUS setBackgroundColor:[UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.0f]];
        
        [self.btnMetrics.titleLabel setTextColor:[UIColor blackColor]];
        [self.btnMetrics setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (_currentStep == 1)
        _unitHeight = unit;
    else if (_currentStep == 2)
        _unitWeight = unit;
}

- (IBAction)onUnit:(id)sender
{
    if (sender == self.btnUS)
    {
        if (_currentStep == 1 && _unitHeight == 0)
            return;
        
        if (_currentStep == 2 && _unitWeight == 0)
            return;
        
        [self updateUnit:0];
        
        if (_currentStep == 1)
        {
            self.viewStep2US.hidden = NO;
            self.viewStep2MT.hidden = YES;
            
            [self.txtHeightFT becomeFirstResponder];
            
            CGFloat curHeight = [self.txtHeightCM.text floatValue];
            NSInteger feets = (NSInteger)(curHeight / 30.48);
            self.txtHeightFT.text = [NSString stringWithFormat:@"%d", (int)feets];
            CGFloat inches = (curHeight - (feets * 30.48)) / 2.54;
            self.txtHeightIN.text = [NSString stringWithFormat:@"%.1f", inches];
        }
        else if (_currentStep == 2)
        {
            self.lblUnit.text = @"lbs";
            
            CGFloat curLBs = [self.txtWeight.text floatValue];
            CGFloat newWeight = curLBs * 2.20462;
            self.txtWeight.text = [NSString stringWithFormat:@"%.1f", newWeight];
        }
    }
    else if (sender == self.btnMetrics)
    {
        if (_currentStep == 1 && _unitHeight == 1)
            return;
        
        if (_currentStep == 2 && _unitWeight == 1)
            return;
        
        [self updateUnit:1];

        if (_currentStep == 1)
        {
            self.viewStep2US.hidden = YES;
            self.viewStep2MT.hidden = NO;
            
            [self.txtHeightCM becomeFirstResponder];

            CGFloat curFeets = [self.txtHeightFT.text floatValue];
            CGFloat curInches = [self.txtHeightIN.text floatValue];
            CGFloat newHeight = curFeets * 30.48 + curInches * 2.54;
            self.txtHeightCM.text = [NSString stringWithFormat:@"%.1f", newHeight];
        }
        else if (_currentStep == 2)
        {
            self.lblUnit.text = @"kgs";

            CGFloat curKGs = [self.txtWeight.text floatValue];
            CGFloat newWeight = curKGs * 0.453592;
            self.txtWeight.text = [NSString stringWithFormat:@"%.1f", newWeight];
        }
    }
}

- (void)updateGender:(NSInteger)gender
{
    _userGender = gender;
    
    if (gender == 0)
    {
        self.btnMale.selected = YES;
        self.btnFemale.selected = NO;
    }
    else if (gender == 1)
    {
        self.btnMale.selected = NO;
        self.btnFemale.selected = YES;
    }
}

- (IBAction)onGender:(id)sender
{
    if (sender == self.btnMale)
    {
        [self updateGender:0];
    }
    else if (sender == self.btnFemale)
    {
        [self updateGender:1];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)isLeadingNumberInString:(NSString*)string
{
    if (string == nil || string.length == 0)
        return NO;
    
    return isnumber([string characterAtIndex:0]);
}

- (BOOL)validateStringContainsAlphabetsOnly:(NSString*)string
{
//    NSCharacterSet *strCharSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"];
    NSCharacterSet *strCharSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890"];
    
    strCharSet = [strCharSet invertedSet];
    
    NSRange r = [string rangeOfCharacterFromSet:strCharSet];
    if (r.location != NSNotFound)
        return NO;

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtUserName)
    {
        if (textField.text.length == 0)
        {
            if ([self isLeadingNumberInString:string])
                return NO;
        }
        
        return [self validateStringContainsAlphabetsOnly:string];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtUserName)
    {
        [self performSelector:@selector(onNext) withObject:nil afterDelay:0.01f];
    }
    
    return YES;
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

@end
