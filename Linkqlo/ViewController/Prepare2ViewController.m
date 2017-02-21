//
//  Prepare2ViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "Prepare2ViewController.h"

#import "InputValueViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface Prepare2ViewController () <InputValueViewControllerDelegate>
{
    BOOL _isUs;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;
@property (nonatomic, assign) IBOutlet UITableView *tvMain;

@property (nonatomic, assign) IBOutlet UIImageView *ivSwitch;

@property (nonatomic, assign) IBOutlet UILabel *lblUs;
@property (nonatomic, assign) IBOutlet UILabel *lblMetrics;

@property (nonatomic, assign) IBOutlet UILabel *lblError;

@property (nonatomic, assign) IBOutlet UIImageView *ivThumb;

@property (nonatomic, retain) NSMutableDictionary *specInfo;
@property (nonatomic, retain) NSArray *aryKeys;

@end

@implementation Prepare2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isUs = YES;

//    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
//    NSString *strGender = [userInfo objectForKey:@"gender"];
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
//    if ([strGender isEqualToString:@"male"])
//    {
//        self.aryKeys = [[NSArray alloc] initWithObjects:@"Height", @"Weight", @"Chest", @"Waist", @"Hip", @"Foot", @"Neck", @"Shoulder", @"Arm Length", @"Torso Height", @"Upper Arm Size", @"Belly", @"Leg Length", @"Thigh", @"Calf", nil];
//    }
//    else if ([strGender isEqualToString:@"female"])
//    {
//        self.aryKeys = [[NSArray alloc] initWithObjects:@"Height", @"Weight", @"Chest", @"Waist", @"Hip", @"Cup Size", @"Foot", @"Neck", @"Shoulder", @"Arm Length", @"Torso Height", @"Upper Arm Size", @"Belly", @"Leg Length", @"Thigh", @"Calf", nil];
//    }
    self.aryKeys = [[NSArray alloc] initWithObjects:@"Height", @"Weight", @"Chest", @"Waist", @"Hip", @"Foot", @"Neck", @"Shoulder", @"Arm Length", @"Torso Height", @"Upper Arm Size", @"Abdomen", @"Leg Length", @"Thigh", @"Calf", nil];
    
    for (int index = 0; index < self.aryKeys.count; index++)
        [values addObject:[NSNumber numberWithFloat:0]];

    self.specInfo = [[NSMutableDictionary alloc] initWithObjects:values forKeys:self.aryKeys];
    
    self.svMain.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), self.tvMain.frame.origin.y + 44 * self.specInfo.allKeys.count);
    
    self.lblUs.center = CGPointMake(self.ivSwitch.frame.origin.x + CGRectGetWidth(self.ivSwitch.frame) / 4, self.ivSwitch.frame.origin.y + CGRectGetHeight(self.ivSwitch.frame) / 2);
    self.lblMetrics.center = CGPointMake(self.ivSwitch.frame.origin.x + CGRectGetWidth(self.ivSwitch.frame) * 3 / 4, self.ivSwitch.frame.origin.y + CGRectGetHeight(self.ivSwitch.frame) / 2);
    
    self.ivThumb.center = CGPointMake(self.ivSwitch.frame.origin.x + CGRectGetWidth(self.ivSwitch.frame) / 4, self.ivSwitch.frame.origin.y + CGRectGetHeight(self.ivSwitch.frame) / 2);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSwitch)];
    [self.ivSwitch addGestureRecognizer:tapGesture];
    tapGesture = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getItemTextFromIndex:(int)index
{
    if (index < 0 || index >= self.aryKeys.count)
        return nil;
    
    NSString *strItemText = [self.aryKeys objectAtIndex:index];
    return strItemText;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"inputvalue"])
    {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        NSString *strTitle = [self getItemTextFromIndex:(int)indexPath.row];
        float value = [self getValueFromIndex:(int)indexPath.row toUnit:NO];
        
        InputValueViewController *vcInputValue = segue.destinationViewController;
        vcInputValue.delegate = self;
        vcInputValue.title = strTitle;
        
        if (indexPath.row == 1)
            vcInputValue.initial = [self convertWeightToMetrics:value from:NO to:_isUs];
        else
            vcInputValue.initial = [self convertLengthToMetrics:value from:NO to:_isUs];
        
        vcInputValue.isUSUnit = _isUs;
        vcInputValue.isLength = YES;
        vcInputValue.keyIndex = (int)indexPath.row;
        
        if (indexPath.row == 1)
            vcInputValue.isLength = NO;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.navigationItem setHidesBackButton:YES];
    
    [self updateSwitch:0.0f];

    if ([self validateValues])
        self.lblError.hidden = YES;
    else
        self.lblError.hidden = NO;
}

- (BOOL)validateValues
{
    BOOL isValid = NO;
    for (id value in self.specInfo.allValues)
    {
        if ([value floatValue] != 0)
            isValid = YES;
    }
    
    return isValid;
}

- (BOOL)updateUserSpecs
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return NO;
    
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    if (strUserID == nil || strUserID.length == 0)
        return NO;

    [request setObject:strUserID forKey:@"user_id"];
    
    for (NSString *strKey in self.specInfo.allKeys)
    {
        if ([strKey isEqualToString:@"Height"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"height"];

        if ([strKey isEqualToString:@"Weight"])
            [request setObject:[self.specInfo objectForKey:strKey]  forKey:@"weight"];
        
        if ([strKey isEqualToString:@"Chest"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"chest"];
        
        if ([strKey isEqualToString:@"Waist"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"waist"];
        
        if ([strKey isEqualToString:@"Hip"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"hip"];
        
//        if ([strKey isEqualToString:@"Cup Size"])
//            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"cup_size"];
        
        if ([strKey isEqualToString:@"Foot"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"foot"];
        
        if ([strKey isEqualToString:@"Neck"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"neck"];
        
        if ([strKey isEqualToString:@"Shoulder"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"shoulder"];
        
        if ([strKey isEqualToString:@"Arm Length"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"arm_length"];
        
        if ([strKey isEqualToString:@"Torso Height"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"torso_height"];
        
        if ([strKey isEqualToString:@"Upper Arm Size"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"upper_arm_size"];
        
        if ([strKey isEqualToString:@"Abdomen"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"belly"];
        
        if ([strKey isEqualToString:@"Leg Length"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"leg_length"];
        
        if ([strKey isEqualToString:@"Thigh"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"thigh"];
        
        if ([strKey isEqualToString:@"Calf"])
            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"calf"];
    }
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"update_user_spec" request:request];
    
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

- (IBAction)onGoToTryFollow:(id)sender
{
    if (![self validateValues])
        return;
    
    if ([self updateUserSpecs])
        [self gotoTryFollowScreen];
}

- (void)gotoTryFollowScreen
{
    [self performSegueWithIdentifier:@"tryfollow" sender:nil];
}

- (void) gotoMainScreen
{
    [self performSegueWithIdentifier:@"tryfollow" sender:nil];
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//        
//    }];
}

- (void) tapSwitch
{
    _isUs = !_isUs;
    
    [self updateSwitch:0.3f];
    [self.tvMain reloadData];
}

- (void) updateSwitch:(float)duraiton
{
//    self.lblUs.textColor = _isUs ? [[DataManager shareDataManager] getBackgroundColor] : [UIColor whiteColor];
//    self.lblMetrics.textColor = _isUs ? [UIColor whiteColor] : [[DataManager shareDataManager] getBackgroundColor];
    self.lblUs.textColor = _isUs ? [UIColor blackColor] : [UIColor whiteColor];
    self.lblMetrics.textColor = _isUs ? [UIColor whiteColor] : [UIColor blackColor];
    
    [UIView animateWithDuration:duraiton animations:^{
        
        self.ivThumb.center = CGPointMake(_isUs ? (self.ivSwitch.frame.origin.x + CGRectGetWidth(self.ivSwitch.frame) / 4) : self.ivSwitch.frame.origin.x + CGRectGetWidth(self.ivSwitch.frame) * 3 / 4,
                                          self.ivSwitch.frame.origin.y + CGRectGetHeight(self.ivSwitch.frame) / 2);
        
    } completion:^(BOOL finished) {

    }];
}

- (IBAction)onClose:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)onSave:(id)sender
{
    [self onGoToTryFollow:sender];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.specInfo == nil)
        return 0;
    
    return self.aryKeys.count;
}

- (float)getValueFromIndex:(int)index toUnit:(BOOL)fUSUnit
{
    if (index < 0 || index >= self.aryKeys.count)
        return 0;
    
    NSString *key = [self.aryKeys objectAtIndex:index];
    
    float value = [[self.specInfo objectForKey:key] floatValue];
    if ([key isEqualToString:@"Weight"])
        value = [self convertWeightToMetrics:value from:NO to:fUSUnit];
    else
        value = [self convertLengthToMetrics:value from:NO to:fUSUnit];
    
    return value;
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
    cell.textLabel.text = [self getItemTextFromIndex:(int)indexPath.row];
    
    float value = [self getValueFromIndex:(int)indexPath.row toUnit:_isUs];
    if (value != 0)
    {
        if (_isUs)
        {
            if (indexPath.row == 1)
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f lbs", value];
            else
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f inches", value];
        }
        else
        {
            if (indexPath.row == 1)
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f kg", value];
            else
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f cm", value];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"inputvalue" sender:indexPath];
}

#pragma mark InputValueViewControllerDelegate

- (float)convertLengthToMetrics:(float)length from:(BOOL)fromUnit to:(BOOL)toUnit
{
    if (fromUnit == toUnit)
        return length;
    
    if (fromUnit && !toUnit)
        return length * 2.54;
    else if (!fromUnit && toUnit)
        return length * 0.3937;
    
    return length;
}

- (float)convertWeightToMetrics:(float)weight from:(BOOL)fromUnit to:(BOOL)toUnit
{
    if (fromUnit == toUnit)
        return weight;
    
    if (fromUnit && !toUnit)
        return weight * 0.453592;
    else if (!fromUnit && toUnit)
        return weight * 2.20462;
    
    return weight;
}

- (void)acceptValue:(float)value forIndex:(int)index forUnit:(BOOL)fUSUnit
{
    id key = [self.aryKeys objectAtIndex:index];
    
    if (index == 1)
        value = [self convertWeightToMetrics:value from:fUSUnit to:NO];
    else
        value = [self convertLengthToMetrics:value from:fUSUnit to:NO];
    
    [self.specInfo setObject:[NSNumber numberWithFloat:value] forKey:key];
    
    [self.tvMain reloadData];
}

@end
