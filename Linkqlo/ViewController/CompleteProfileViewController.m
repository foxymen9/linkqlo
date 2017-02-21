//
//  CompleteProfileViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "CompleteProfileViewController.h"

#import "InputTextViewController.h"

#import "UIImageView+WebCache.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface CompleteProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, InputTextViewControllerDelegate>
{
    BOOL isPhotoChanged;
}

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UITableView *tvMain;

@property (nonatomic, retain) NSString *strEmailAddr;
@property (nonatomic, retain) NSString *strFirstName;
//@property (nonatomic, retain) NSString *strLastName;
@property (nonatomic, retain) NSString *strUserName;
@property (nonatomic, retain) NSString *strGender;
@property (nonatomic, retain) NSString *strStatus;
@property (nonatomic, retain) NSString *strLocation;

@end

@implementation CompleteProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.ivProfile.layer.masksToBounds = YES;
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    
    NSString *strPhotoURL = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"photo_url"]];
    if (strPhotoURL != nil && strPhotoURL.length > 0)
        [self.ivProfile setImageWithURL:[NSURL URLWithString:strPhotoURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    self.strEmailAddr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"email_address"]];
    self.strFirstName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"first_name"]];
//    self.strLastName =  [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"last_name"]];
    self.strUserName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
    self.strGender = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"gender"]];
    self.strStatus = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"status"]];
    self.strLocation = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"location"]];
    
    isPhotoChanged = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationItem setHidesBackButton:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"inputvalue"])
    {
        InputTextViewController *vcInputText = segue.destinationViewController;
        vcInputText.isAsciiInput = NO;
        vcInputText.delegate = self;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        vcInputText.index = (int)indexPath.row;
        if (indexPath.row == 1)
        {
            vcInputText.title = @"First Name";
            vcInputText.strValue = self.strFirstName;
        }
//        else if (indexPath.row == 2)
//        {
//            vcInputText.title = @"Last Name";
//            vcInputText.strValue = self.strLastName;
//        }
        else if (indexPath.row == 3)
        {
            vcInputText.title = @"Username";
            vcInputText.isAsciiInput = YES;
            vcInputText.strValue = self.strUserName;
        }
        else if (indexPath.row == 5)
        {
            vcInputText.title = @"Status";
            vcInputText.strValue = self.strStatus;
        }
        else if (indexPath.row == 6)
        {
            vcInputText.title = @"Location";
            vcInputText.strValue = self.strLocation;
        }
    }
}

- (void)updateUserInfos
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSString *strProfileImagePath = nil;
    
    if (isPhotoChanged)
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
        return;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || strUserID.length == 0)
        return;
    
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
            
            return;
        }
        else // Success
        {
            // Current User Info.
            [[DataManager shareDataManager] setUserInfo:dicRet];
            
            [self gotoNextScreen:dicRet];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
}

- (void)gotoNextScreen:(NSMutableDictionary *)userInfo
{
    NSMutableArray *specInfo = [userInfo objectForKey:@"spec"];
    if (specInfo == nil || [specInfo count] == 0)
    {
//        [self gotoPrepareScreen];
        [self gotoMainScreen];
        return;
    }
    
    [self gotoMainScreen];
}

- (void) gotoPrepareScreen
{
    [self performSegueWithIdentifier:@"prepare1" sender:nil];
}

- (void) gotoMainScreen
{
    [self performSegueWithIdentifier:@"main" sender:nil];
}

- (IBAction)onDone:(id)sender
{
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
            strMessage = @"Please input first name.";
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
        
        if (self.strGender.length == 0)
        {
            strMessage = @"Please input your gender.";
            break;
        }
    } while (FALSE);
    
    if (strMessage != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self updateUserInfos];
}

- (IBAction)onSelectPhoto:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Camera Roll", nil];
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Email";
        cell.detailTextLabel.text = self.strEmailAddr;
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"First Name";
        cell.detailTextLabel.text = self.strFirstName;
    }
//    else if (indexPath.row == 2)
//    {
//        cell.textLabel.text = @"Last Name";
//        cell.detailTextLabel.text = self.strLastName;
//    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = @"Username";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", self.strUserName];
    }
    else if (indexPath.row == 4)
    {
        cell.textLabel.text = @"Gender";
        cell.detailTextLabel.text = self.strGender;
    }
    else if (indexPath.row == 5)
    {
        cell.textLabel.text = @"Status";
        cell.detailTextLabel.text = self.strStatus;
    }
    else if (indexPath.row == 6)
    {
        cell.textLabel.text = @"Location";
        cell.detailTextLabel.text = self.strLocation;
    }
    else
    {
        cell.textLabel.text = @"";
    }
    
    if (indexPath.row == 0 || indexPath.row == 3)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 3)
    {
        return;
    }
    else if (indexPath.row == 4)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Gender" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Male", @"Female", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
        actionSheet = nil;
    }
    else
    {
        [self performSegueWithIdentifier:@"inputvalue" sender:indexPath];
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        if (buttonIndex == 0)
        {
            self.strGender = @"male";
        }
        else if (buttonIndex == 1)
        {
            self.strGender = @"female";
        }
        
        [self.tvMain reloadData];
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
        
        isPhotoChanged = YES;
        self.ivProfile.image = profilePhoto;
    }];
}

#pragma mark InputTextViewControllerDelegate

- (void) acceptText:(NSString *)text forIndex:(int)index
{
    if (index == 1)
        self.strFirstName = text;
//    else if (index == 2)
//        self.strLastName = text;
    else if (index == 3)
        self.strUserName = text;
    else if (index == 5)
        self.strStatus = text;
    else if (index == 6)
        self.strLocation = text;
    
    [self.tvMain reloadData];
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
