//
//  SignUpViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "SignUpViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface SignUpViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WebManagerDelegate>

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UITextField *txtFirstname;
@property (nonatomic, assign) IBOutlet UITextField *txtLastname;
@property (nonatomic, assign) IBOutlet UITextField *txtUsername;
@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;
@property (nonatomic, assign) IBOutlet UITextField *txtConfirm;
@property (nonatomic, assign) IBOutlet UITextField *txtGender;

@end

@implementation SignUpViewController

- (void)tapView
{
    [self hideKeyboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ivProfile.image = nil;
    self.ivProfile.layer.masksToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    
    self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.svMain.frame), 540);//CGRectGetHeight(self.svMain.frame) + self.svMain.frame.origin.y);

    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self.svMain addGestureRecognizer:tapGestur];
    tapGestur = nil;
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

- (void)hideKeyboard
{
    [self.txtFirstname resignFirstResponder];
    [self.txtLastname resignFirstResponder];
    [self.txtUsername resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtConfirm resignFirstResponder];
    [self.txtGender resignFirstResponder];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^
     {
         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x,self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.svMain.frame.origin.x - 256);
     } completion:^(BOOL finished) {
         
     }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^
     {
         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x,self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - self.svMain.frame.origin.x);
     } completion:^(BOOL finished) {
         
     }];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isValidMailAddress:(NSString *)mailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:mailAddress];
}

- (BOOL)processSignup
{
    [JSWaiter ShowWaiter:self title:@"Processing..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    UIImage *profilePhoto = self.ivProfile.image;
    NSString *strMail = self.txtEmail.text;
    NSString *strPass = self.txtPassword.text;
    NSString *strFirstName = self.txtFirstname.text;
//    NSString *strLastName = self.txtLastname.text;
    NSString *strUserName = self.txtUsername.text;
    strUserName = [[strUserName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strGender = self.txtGender.text;
    
    NSString *strProfileImagePath = nil;
    if (profilePhoto != nil)
    {
        // Save profile image to local directory.
        NSData *imageData = UIImagePNGRepresentation(profilePhoto);
        NSString *imageName = @"profile.png";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; //On le mets au debut
        
        strProfileImagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        [imageData writeToFile:strProfileImagePath atomically:NO];
    }
    
    NSString *strDeviceToken = [[DataManager shareDataManager] getDeviceToken];
    if (strDeviceToken == nil) strDeviceToken = @"";
    
    NSDictionary *request = @{
                              @"email_address"  : strMail,
                              @"password"       : strPass,
                              @"first_name"     : strFirstName,
                              @"last_name"      : @"",
                              @"user_name"      : strUserName,
                              @"gender"         : [strGender lowercaseString],
                              @"device_token"   : strDeviceToken,
                              };
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strAPIName = @"signup";
    NSMutableDictionary *dicRet = [_webMgr requestUpoadFileWithAction:strAPIName request:(NSMutableDictionary *)request file:strProfileImagePath];
    
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
            [pref setObject:@"login" forKey:@"apiName"];
            request = @{
                        @"email_address"  : strMail,
                        @"password"       : strPass,
                        @"device_token"   : strDeviceToken,
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

- (IBAction)onDone:(id)sender
{
    [self hideKeyboard];
    
    UIImage *profilePhoto = self.ivProfile.image;
    NSString *strMail = self.txtEmail.text;
    NSString *strPass = self.txtPassword.text;
    NSString *strConfirm = self.txtConfirm.text;
    NSString *strFirstName = self.txtFirstname.text;
    NSString *strLastName = self.txtLastname.text;
    NSString *strUserName = self.txtUsername.text;
    NSString *strGender = self.txtGender.text;
    
    NSString *strMessage = nil;
    do {
        if (profilePhoto == nil)
        {
            strMessage = @"Please select profile photo.";
            break;
        }
        
        if (strMail.length == 0)
        {
            strMessage = @"Please input an e-mail address.";
            break;
        }

        if (![self isValidMailAddress:strMail])
        {
            strMessage = @"Please input a valid e-mail address.";
            break;
        }
        
        if (strPass.length == 0)
        {
            strMessage = @"Please input the password.";
            break;
        }
        
        if (![strPass isEqualToString:strConfirm])
        {
            strMessage = @"Password is mismatch.";
            break;
        }
        
        if (strFirstName.length == 0)
        {
            strMessage = @"Please input first name.";
            break;
        }
        
        if (strLastName.length == 0)
        {
            strMessage = @"Please input last name.";
            break;
        }
        
        if (strUserName.length == 0)
        {
            strMessage = @"Please input user name.";
            break;
        }
        
        if (strGender.length == 0)
        {
            strMessage = @"Please input gender.";
            break;
        }
    } while (FALSE);
    
    if (strMessage != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([self processSignup])
    {
        NSMutableDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        if (userInfo != nil)
            [self gotoNextScreen:userInfo];
    }
}

- (IBAction)onSignin:(id)sender
{
    [self performSegueWithIdentifier:@"signin" sender:nil];
}

- (IBAction)onSelectProfile:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Camera Roll", nil];
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
}

- (void)gotoNextScreen:(NSMutableDictionary *)userInfo
{
    BOOL isFirstTime = [[userInfo objectForKey:@"is_first"] boolValue];
    if (isFirstTime)
    {
        [self gotoProfileScreen];
        return;
    }
    
    NSString *strPhotoURL = [userInfo objectForKey:@"photo_url"];
    NSString *strEmailAddr = [userInfo objectForKey:@"email_address"];
    NSString *strFirstName = [userInfo objectForKey:@"first_name"];
//    NSString *strLastName =  [userInfo objectForKey:@"last_name"];
    NSString *strUserName = [userInfo objectForKey:@"user_name"];
    NSString *strGender = [userInfo objectForKey:@"gender"];
//    NSString *strStatus = [userInfo objectForKey:@"status"];
//    NSString *strLocation = [userInfo objectForKey:@"location"];
    if (strPhotoURL == nil || strPhotoURL.length == 0 ||
        strEmailAddr == nil || strEmailAddr.length == 0 ||
        strFirstName == nil || strFirstName.length == 0 ||
//        strLastName == nil || strLastName.length == 0 ||
        strUserName == nil || strUserName.length == 0 ||
        strGender == nil || strGender.length == 0)
    {
        [self gotoProfileScreen];
        return;
    }
    
    NSMutableArray *specInfo = [userInfo objectForKey:@"spec"];
    if (specInfo == nil || [specInfo count] == 0)
    {
//        [self gotoPrepareScreen];
        [self gotoMainScreen];
        return;
    }
    
    [self gotoMainScreen];
}

- (void) gotoProfileScreen
{
    [self performSegueWithIdentifier:@"completeprofile" sender:nil];
}

- (void) gotoPrepareScreen
{
    [self performSegueWithIdentifier:@"prepare1" sender:nil];
}

- (void) gotoMainScreen
{
    [self performSegueWithIdentifier:@"main" sender:nil];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        if (buttonIndex == 0)
        {
            self.txtGender.text = @"male";
        }
        else if (buttonIndex == 1)
        {
            self.txtGender.text = @"female";
        }
    }
    else if (actionSheet.tag == 2)
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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.txtGender == textField)
    {
        [self hideKeyboard];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Gender" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Male", @"Female", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
        actionSheet = nil;
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtUsername)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        
        return YES;
    }
    
    return YES;
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count] == 2)
    {
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        
        plCropOverlay.hidden = YES;
        
        int position = (screenHeight - screenWidth) / 2;
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:
                               CGRectMake(0.0f, position, screenWidth, screenWidth)];
        [path2 setUsesEvenOddFillRule:YES];
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenWidth, screenHeight-72) cornerRadius:0];
        
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
        
        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        [moveLabel setText:@"Move and Scale"];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}

#pragma mark UIImagePickerControllerDelegate
- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 128;
    
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
        UIImage *profilePhoto = [self scaleAndRotateImage:editedImage];
        
        self.ivProfile.image = profilePhoto;
    }];
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
