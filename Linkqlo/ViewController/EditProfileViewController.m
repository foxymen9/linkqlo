//
//  EditProfileViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "EditProfileViewController.h"

#import "GenderTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "RegisterViewController.h"
#import "InputTextViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"
#import "UIImageView+WebCache.h"

@interface EditProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, InputTextViewControllerDelegate, WebManagerDelegate, GenderTableViewCellDelegate, ProfileTableViewCellDelegate>
{
    BOOL _isModified;
    BOOL _isPhotoChanged;
    
    UITextField *_activeTextField;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UITableView *tvContents;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, retain) NSString *strFirstName;
//@property (nonatomic, retain) NSString *strLastName;
@property (nonatomic, retain) NSString *strUserName;
@property (nonatomic, retain) NSString *strGender;
@property (nonatomic, retain) NSString *strStatus;
@property (nonatomic, retain) NSString *strLocation;
@property (nonatomic, retain) NSString *strMailAddr;

@property (nonatomic, assign) IBOutlet UIView *viewRegister;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.ivProfile.layer.masksToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    self.ivProfile.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    self.ivProfile.layer.borderColor = [[UIColor blackColor] CGColor];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo != nil)
    {
        NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"photo_url"]];
        [self.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];

        self.strFirstName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"first_name"]];
//        self.strLastName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"last_name"]];
        self.strUserName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
        self.strGender = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"gender"]];
        self.strStatus = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"status"]];
        self.strLocation = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"location"]];
        self.strMailAddr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"email_address"]];
    }
    
    _isModified = NO;
    _isPhotoChanged = NO;

    [self.tvContents registerNib:[UINib nibWithNibName:@"GenderTableViewCell" bundle:nil] forCellReuseIdentifier:@"gender"];
    [self.tvContents registerNib:[UINib nibWithNibName:@"ProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"profile"];
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
    if ([segue.identifier isEqualToString:@"inputvalue"])
    {
        InputTextViewController *vcInputText = segue.destinationViewController;
        vcInputText.delegate = self;
        vcInputText.isAsciiInput = NO;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        vcInputText.index = (int)indexPath.row;
        if (indexPath.row == 0)
        {
            vcInputText.title = @"First Name";
            vcInputText.strValue = self.strFirstName;
        }
//        else if (indexPath.row == 1)
//        {
//            vcInputText.title = @"Last Name";
//            vcInputText.strValue = self.strLastName;
//        }
        else if (indexPath.row == 2)
        {
            vcInputText.title = @"Username";
            vcInputText.isAsciiInput = YES;
            vcInputText.strValue = self.strUserName;
        }
        else if (indexPath.row == 3)
        {
            
        }
        else if (indexPath.row == 4)
        {
            vcInputText.title = @"Status";
            vcInputText.strValue = self.strStatus;
        }
        else if (indexPath.row == 5)
        {
            vcInputText.title = @"Location";
            vcInputText.strValue = self.strLocation;
        }
    }
    else if ([segue.identifier isEqualToString:@"register"])
    {
        UINavigationController *navController = segue.destinationViewController;
        RegisterViewController *vcRegister = (RegisterViewController *)[navController topViewController];
        vcRegister.showLogoutButton = NO;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tvContents reloadData];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strMailAddr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"email_address"]];
    NSString *strFBID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"fb_id"]];
    NSString *strTWID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"tw_id"]];
    if (strMailAddr.length == 0 && strFBID.length == 0 && strTWID.length == 0)
    {
        self.viewRegister.hidden = NO;
        self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.svMain.frame), 510);
    }
    else
    {
        self.viewRegister.hidden = YES;
        self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.svMain.frame), 440);
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
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
    
    float diff = (keyboardRect.origin.y < self.view.frame.size.height) ? keyboardRect.size.height : 0;
    
    [UIView animateWithDuration:0.2 animations:^
     {
         self.svMain.frame = CGRectMake(self.svMain.frame.origin.x, self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - diff);
         
     } completion:^(BOOL finished) {
         
         if (diff > 0)
         {
             CGFloat yOffset = _activeTextField.frame.origin.y;
             [self.svMain setContentOffset:CGPointMake(self.svMain.contentOffset.x, yOffset) animated:NO];
         }
     }];
}

- (IBAction)onBack:(id)sender
{
    if (_activeTextField != nil)
        [_activeTextField resignFirstResponder];
    
    if (_isModified)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unsaved Changes" message:@"You have unsaved changes. Are you sure you want to cancel?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = 1;
        
        [alertView show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)updateUserInfos
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSString *strProfileImagePath = nil;
    
    if (_isPhotoChanged)
    {
        // Save profile image to local directory.
        UIImage *profilePhoto = self.ivProfile.image;
        NSData *imageData = UIImagePNGRepresentation(profilePhoto);
        NSString *imageName = @"profile.png";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; //On le mets au debut
        
        strProfileImagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        [imageData writeToFile:strProfileImagePath atomically:NO];
    }
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return NO;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || strUserID.length == 0)
        return NO;
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    
    [request setObject:strUserID forKey:@"user_id"];
    
    [request setObject:self.strFirstName forKey:@"first_name"];
//    [request setObject:self.strLastName forKey:@"last_name"];
    [request setObject:self.strUserName forKey:@"user_name"];
    [request setObject:self.strGender forKey:@"gender"];
    [request setObject:self.strStatus forKey:@"status"];
    [request setObject:self.strLocation forKey:@"location"];
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = nil;
    if (strProfileImagePath != nil)
        dicRet = [_webMgr requestUpoadFileWithAction:@"update_user_info" request:(NSMutableDictionary *)request file:strProfileImagePath];
    else
        dicRet = [_webMgr requestWithAction:@"update_user_info" request:(NSMutableDictionary *)request];
    
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

- (IBAction)onSave:(id)sender
{
    if (_activeTextField != nil)
        [_activeTextField resignFirstResponder];
    
    NSString *strMessage = nil;
    do {
        UIImage *profilePhoto = self.ivProfile.image;
        if (profilePhoto == nil)
        {
            strMessage = @"Please select profile photo.";
            break;
        }
        
        if (self.strFirstName.length == 0)
        {
            strMessage = @"Please input name.";
            break;
        }
        
//        if (self.strLastName.length == 0)
//        {
//            strMessage = @"Please input last name.";
//            break;
//        }
        
        if (self.strUserName.length == 0)
        {
            strMessage = @"Please input user name.";
            break;
        }
    } while (FALSE);
    
    if (strMessage != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([self updateUserInfos])
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSelectPhoto:(id)sender
{
    if (_activeTextField != nil)
        [_activeTextField resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Camera Roll", nil];
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
}

- (IBAction)onRegister:(id)sender
{
    if (_activeTextField != nil)
        [_activeTextField resignFirstResponder];
    
    [self performSegueWithIdentifier:@"register" sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 4)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"gender"];
        GenderTableViewCell *myCell = (GenderTableViewCell *)cell;
        myCell.delegate = self;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"profile"];
        ProfileTableViewCell *myCell = (ProfileTableViewCell *)cell;
        myCell.indexPath = indexPath;
        myCell.delegate = self;
        
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3)
            myCell.isEditable = YES;
        else
        {
            myCell.isEditable = NO;
            
            myCell.txtDetail.borderStyle = UITextBorderStyleNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4)
    {
        GenderTableViewCell *myCell = (GenderTableViewCell *)cell;
        [myCell.ivImage setImage:[UIImage imageNamed:@"profile_icon_gender"]];
        myCell.lblText.text = @"Gender";
        
        if ([self.strGender isEqualToString:@"male"])
            myCell.sgGender.selectedSegmentIndex = 0;
        else if ([self.strGender isEqualToString:@"female"])
            myCell.sgGender.selectedSegmentIndex = 1;
    }
    else
    {
        ProfileTableViewCell *myCell = (ProfileTableViewCell *)cell;
        
        if(indexPath.row == 0)
        {
            [myCell.ivImage setImage:[UIImage imageNamed:@"profile_icon_fullname"]];
            myCell.lblText.text = @"Name";
            myCell.txtDetail.text = self.strFirstName;
        }
        else if(indexPath.row == 1)
        {
            [myCell.ivImage setImage:[UIImage imageNamed:@"profile_icon_username"]];
            myCell.lblText.text = @"User Name";
            myCell.txtDetail.text = self.strUserName;
        }
        else if(indexPath.row == 2)
        {
            [myCell.ivImage setImage:[UIImage imageNamed:@"profile_icon_status"]];
            myCell.lblText.text = @"Status";
            myCell.txtDetail.text = self.strStatus;
        }
        else if(indexPath.row == 3)
        {
            [myCell.ivImage setImage:[UIImage imageNamed:@"profile_icon_location"]];
            myCell.lblText.text = @"Location";
            myCell.txtDetail.text = self.strLocation;
        }
        else if(indexPath.row == 5)
        {
            [myCell.ivImage setImage:[UIImage imageNamed:@"profile_icon_mail"]];
            myCell.lblText.text = @"E-mail";
            myCell.txtDetail.text = self.strMailAddr;
        }
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
/*
    if (indexPath.row == 2 || indexPath.row == 3)
        return;
    
    [self performSegueWithIdentifier:@"inputvalue" sender:indexPath];
*/
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
        
//        [self.navigationController popViewControllerAnimated:YES];
        
        _isModified = YES;
        _isPhotoChanged = YES;
        self.ivProfile.image = profilePhoto;
    }];
}

#pragma mark InputTextViewControllerDelegate

- (void) acceptText:(NSString *)text forIndex:(int)index
{
    if (index == 0)
        self.strFirstName = text;
//    else if (index == 1)
//        self.strLastName = text;
    else if (index == 2)
        self.strUserName = text;
    else if (index == 3)
        self.strGender = text;
    else if (index == 4)
        self.strStatus = text;
    else if (index == 5)
        self.strLocation = text;
    
    _isModified = YES;
    [self.tvContents reloadData];
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

#pragma mark GenderTableViewCellDelegate

- (void)updateGender:(NSString *)newGender
{
    self.strGender = newGender;
    
    _isModified = YES;
}

#pragma mark ProfileTableViewCellDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeTextField = nil;
}

- (void)textFieldShouldReturn:(UITextField *)textField cell:(UITableViewCell *)cell
{
    ProfileTableViewCell *curCell = (ProfileTableViewCell *)cell;
    ProfileTableViewCell *nextCell = nil;
    
    int row = -1;
    if (curCell.indexPath.row == 0)
        row = 2;
    else if (curCell.indexPath.row == 2)
        row = 3;
    else if (curCell.indexPath.row == 3)
        row = 0;
    
    if (row == -1)
        return;
    
    nextCell = (ProfileTableViewCell *)[self.tvContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:curCell.indexPath.section]];
    
    if (nextCell != nil)
        [nextCell.txtDetail becomeFirstResponder];
}

- (void)updateText:(NSString *)newText forCell:(UITableViewCell *)cell;
{
    ProfileTableViewCell *myCell = (ProfileTableViewCell *)cell;
    if (myCell.indexPath.row == 0)
        self.strFirstName = newText;
    else if (myCell.indexPath.row == 1)
        self.strUserName = newText;
    else if (myCell.indexPath.row == 2)
        self.strStatus = newText;
    else if (myCell.indexPath.row == 3)
        self.strLocation = newText;
    
    _isModified = YES;
}

@end
