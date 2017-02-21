//
//  BSISpecsViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/12/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "BSISpecsViewController.h"

#import "BSITableViewCell.h"

#import "InputValueViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import "SVProgressHUD.h"

@interface BSISpecsViewController () <InputValueViewControllerDelegate>
{
    BOOL _isUs;
    BOOL _isModified;
}

@property (nonatomic, assign) IBOutlet UITableView *tvContents;

@property (nonatomic, assign) IBOutlet UIButton *btnUS;
@property (nonatomic, assign) IBOutlet UIButton *btnMetrics;

@property (nonatomic, retain) NSMutableDictionary *specInfo;
@property (nonatomic, retain) NSArray *aryKeys;

@end

@implementation BSISpecsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isUs = YES;
    _isModified = NO;
    
    [self.tvContents registerNib:[UINib nibWithNibName:@"BSITableViewCell" bundle:nil] forCellReuseIdentifier:@"bsicell"];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
//    NSString *strGender = [userInfo objectForKey:@"gender"];
    
//    if ([strGender isEqualToString:@"male"])
//    {
//        self.aryKeys = [[NSArray alloc] initWithObjects:@"Height", @"Weight", @"Chest", @"Waist", @"Hip", @"Foot", @"Neck", @"Shoulder", @"Arm Length", @"Torso Height", @"Upper Arm Size", @"Belly", @"Leg Length", @"Thigh", @"Calf", nil];
//    }
//    else if ([strGender isEqualToString:@"female"])
//    {
//        self.aryKeys = [[NSArray alloc] initWithObjects:@"Height", @"Weight", @"Chest", @"Waist", @"Hip", @"Cup Size", @"Foot", @"Neck", @"Shoulder", @"Arm Length", @"Torso Height", @"Upper Arm Size", @"Belly", @"Leg Length", @"Thigh", @"Calf", nil];
//    }
    self.aryKeys = [[NSArray alloc] initWithObjects:@"Height", @"Weight", @"Chest", @"Waist", @"Hip", @"Foot", @"Neck", @"Shoulder", @"Arm Length", @"Torso Height", @"Upper Arm Size", @"Abdomen", @"Leg Length", @"Thigh", @"Calf", nil];
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (int index = 0; index < self.aryKeys.count; index++)
        [values addObject:[NSNumber numberWithFloat:0]];
    
    self.specInfo = [[NSMutableDictionary alloc] initWithObjects:values forKeys:self.aryKeys];
    
    NSMutableDictionary *specs = [userInfo objectForKey:@"spec"];
    
    if (specs.count > 0)
    {
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"height"]] forKey:@"Height"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"weight"]] forKey:@"Weight"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"chest"]] forKey:@"Chest"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"waist"]] forKey:@"Waist"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"hip"]] forKey:@"Hip"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"foot"]] forKey:@"Foot"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"neck"]] forKey:@"Neck"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"shoulder"]] forKey:@"Shoulder"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"arm_length"]] forKey:@"Arm Length"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"torso_height"]] forKey:@"Torso Height"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"upper_arm_size"]] forKey:@"Upper Arm Size"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"belly"]] forKey:@"Abdomen"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"leg_length"]] forKey:@"Leg Length"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"thigh"]] forKey:@"Thigh"];
        [self.specInfo setValue:[NSString stringWithFormat:@"%@", [specs objectForKey:@"calf"]] forKey:@"Calf"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (NSString *)getItemTextFromIndex:(int)index
{
    if (index < 0 || index >= self.aryKeys.count)
        return nil;
    
    NSString *strItemText = [self.aryKeys objectAtIndex:index];
    return strItemText;
}

- (float)getValueFromIndex:(int)index toUnit:(BOOL)fUSUnit
{
    if (index < 0 || index >= self.aryKeys.count)
        return 0;
    
    NSString *key = [self.aryKeys objectAtIndex:index];
    float value = [[self.specInfo objectForKey:key] floatValue];
    
    if ([key isEqualToString:@"Weight"])
        value = [self convertWeightValue:value from:NO to:fUSUnit];
    else
        value = [self convertLengthValue:value from:NO to:fUSUnit];
    
    return value;
}

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
            vcInputValue.initial = [self convertWeightValue:value from:NO to:_isUs];
        else
            vcInputValue.initial = [self convertLengthValue:value from:NO to:_isUs];
        
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
    
    [self updateUnit];
    [self.tvContents reloadData];
}

- (IBAction)onBack:(id)sender
{
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

- (BOOL)updateUserSpecs
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return NO;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || strUserID.length == 0)
        return NO;
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    
    [request setObject:strUserID forKey:@"user_id"];
    
    for (NSString *strKey in self.specInfo.allKeys)
    {
        if ([strKey isEqualToString:@"Height"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"height"];
        
        if ([strKey isEqualToString:@"Weight"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]]  forKey:@"weight"];
        
        if ([strKey isEqualToString:@"Chest"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"chest"];
        
        if ([strKey isEqualToString:@"Waist"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"waist"];
        
        if ([strKey isEqualToString:@"Hip"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"hip"];
        
//        if ([strKey isEqualToString:@"Cup Size"])
//            [request setObject:[self.specInfo objectForKey:strKey] forKey:@"cup_size"];
        
        if ([strKey isEqualToString:@"Foot"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"foot"];
        
        if ([strKey isEqualToString:@"Neck"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"neck"];
        
        if ([strKey isEqualToString:@"Shoulder"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"shoulder"];
        
        if ([strKey isEqualToString:@"Arm Length"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"arm_length"];
        
        if ([strKey isEqualToString:@"Torso Height"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"torso_height"];
        
        if ([strKey isEqualToString:@"Upper Arm Size"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"upper_arm_size"];
        
        if ([strKey isEqualToString:@"Abdomen"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"belly"];
        
        if ([strKey isEqualToString:@"Leg Length"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"leg_length"];
        
        if ([strKey isEqualToString:@"Thigh"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"thigh"];
        
        if ([strKey isEqualToString:@"Calf"])
            [request setObject:[NSString stringWithFormat:@"%@", [self.specInfo objectForKey:strKey]] forKey:@"calf"];
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
            
            [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
            [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
            [SVProgressHUD showSuccessWithStatus:@"Saved"];
            
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
    if ([self updateUserSpecs])
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateUnit
{
    if (_isUs)
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
}

- (IBAction)onUS:(id)sender
{
    _isUs = YES;
    
    [self updateUnit];
    [self.tvContents reloadData];
}

- (IBAction)onMetrics:(id)sender
{
    _isUs = NO;
    
    [self updateUnit];
    [self.tvContents reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.aryKeys == nil)
        return 0;
    
    return self.aryKeys.count;
}

- (float)convertLengthValue:(float)value from:(BOOL)fromUnit to:(BOOL)toUnit
{
    if (fromUnit == toUnit)
        return value;
    
    if (fromUnit && !toUnit) // US -> Metrics
    {
        return value * 2.54;
    }
    else if (!fromUnit && toUnit) // Metrics -> US
    {
        return value * 0.393701;
    }
    
    return 0;
}

- (float)convertWeightValue:(float)value from:(BOOL)fromUnit to:(int)toUnit
{
    if (fromUnit == toUnit)
        return value;
    
    if (fromUnit && !toUnit) // US -> Metrics
    {
        return value * 0.453592;
    }
    else if (!fromUnit && toUnit) // Metrics -> US
    {
        return value * 2.20462;
    }

    return 0;
}

- (NSString *)getUnitString:(int)contentType isLength:(BOOL)isLength
{
    if (contentType == 0) // US unit
    {
        if (isLength)
            return @"inches";
        else
            return @"lbs";
    }
    else
    {
        if (isLength)
            return @"cm";
        else
            return @"kg";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSITableViewCell *bsiCell = [tableView dequeueReusableCellWithIdentifier:@"bsicell"];
    return bsiCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSITableViewCell *bsiCell = (BSITableViewCell *)cell;
    bsiCell.lblTitle.text = [self getItemTextFromIndex:(int)indexPath.row];
    
    bsiCell.lblValue.text = @"";
    float value = [self getValueFromIndex:(int)indexPath.row toUnit:_isUs];
    if (value != 0)
    {
        if (_isUs)
        {
            if (indexPath.row == 1)
                bsiCell.lblValue.text = [NSString stringWithFormat:@"%.1f lbs", value];
            else
                bsiCell.lblValue.text = [NSString stringWithFormat:@"%.1f in", value];
        }
        else
        {
            if (indexPath.row == 1)
                bsiCell.lblValue.text = [NSString stringWithFormat:@"%.1f kg", value];
            else
                bsiCell.lblValue.text = [NSString stringWithFormat:@"%.1f cm", value];
        }
    }
    
    if (bsiCell.lblValue.text.length > 0)
    {
        [bsiCell.lblValue setTextColor:[UIColor blackColor]];
    }
    else
    {
        bsiCell.lblValue.text = @"Enter Size";
        [bsiCell.lblValue setTextColor:[UIColor grayColor]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"inputvalue" sender:indexPath];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark InputValueViewControllerDelegate

- (void)acceptValue:(float)value forIndex:(int)index forUnit:(BOOL)fUSUnit
{
    id key = [self.aryKeys objectAtIndex:index];
    
    if (index == 1)
        value = [self convertWeightValue:value from:fUSUnit to:NO];
    else
        value = [self convertLengthValue:value from:fUSUnit to:NO];
    
    [self.specInfo setObject:[NSNumber numberWithFloat:value] forKey:key];
    
    _isModified = YES;
    [self.tvContents reloadData];
}

@end
