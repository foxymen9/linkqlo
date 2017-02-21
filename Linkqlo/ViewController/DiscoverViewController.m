//
//  DiscoverViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "DiscoverViewController.h"

#import "PostListViewController.h"
#import "UserProfileViewController.h"

#import "UIImageView+WebCache.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface DiscoverViewController ()
{
    int _selectedFilterIndex;
    NSMutableArray *_aryDatas;
    NSMutableArray *_aryDisplay;
}

@property (nonatomic, assign) IBOutlet UIImageView *ivThumb;

@property (nonatomic, assign) IBOutlet UIButton *btnBrands;
@property (nonatomic, assign) IBOutlet UIButton *btnTypes;
@property (nonatomic, assign) IBOutlet UIButton *btnPopular;

@property (nonatomic, assign) IBOutlet UIView *viewVert1;
@property (nonatomic, assign) IBOutlet UIView *viewVert2;
@property (nonatomic, assign) IBOutlet UIView *viewHorz;

@property (nonatomic, assign) IBOutlet UITableView *tvLists;

@property (nonatomic, assign) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _aryDatas = nil;
    _aryDisplay = [[NSMutableArray alloc] init];
    _selectedFilterIndex = -1;
    
    self.btnBrands.center = CGPointMake(self.view.frame.size.width / 6 * 1, self.btnBrands.center.y);
    self.btnTypes.center = CGPointMake(self.view.frame.size.width / 6 * 3, self.btnTypes.center.y);
    self.btnPopular.center = CGPointMake(self.view.frame.size.width / 6 * 5, self.btnPopular.center.y);
    
    self.viewVert1.frame = CGRectMake(self.view.frame.size.width / 3 * 1,
                                      self.viewVert1.frame.origin.y,
                                      1 / [UIScreen mainScreen].scale,
                                      self.viewVert1.frame.size.height);
    
    self.viewVert2.frame = CGRectMake(self.view.frame.size.width / 3 * 2,
                                      self.viewVert2.frame.origin.y,
                                      1 / [UIScreen mainScreen].scale,
                                      self.viewVert2.frame.size.height);
    
    self.viewHorz.frame = CGRectMake(self.view.frame.origin.x,
                                     self.viewHorz.frame.origin.y,
                                     self.view.frame.size.width,
                                     1 / [UIScreen mainScreen].scale);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    [self.tvLists addSubview:self.refreshControl];

    self.searchBar.frame = CGRectMake(CGRectGetWidth(self.view.frame), self.searchBar.frame.origin.y, CGRectGetWidth(self.searchBar.frame), CGRectGetHeight(self.searchBar.frame));
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
    if ([segue.identifier isEqualToString:@"posts"])
    {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
        NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
        
        PostListViewController *vcPostList = segue.destinationViewController;
        if (_selectedFilterIndex == 0)
        {
            NSMutableDictionary *countInfo = [_aryDisplay objectAtIndex:indexPath.row];
            vcPostList.title = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"brand_name"]];
//            vcPostList.strAPIName = @"search_by_brand";
//            vcPostList.dicRequest = @{@"user_id" : strUserID, @"brand_id" : [countInfo objectForKey:@"brand_id"]};
            vcPostList.strAPIName = @"search_by_brand";
            vcPostList.dicRequest = @{@"user_id" : strUserID, @"brand_name" : [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"brand_name"]]};
        }
        else if (_selectedFilterIndex == 1)
        {
            NSMutableDictionary *countInfo = [_aryDisplay objectAtIndex:indexPath.row];
            vcPostList.title = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"clothing_type"]];
            vcPostList.strAPIName = @"search_by_clothing";
            vcPostList.dicRequest = @{@"user_id" : strUserID, @"clothing_id" : [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"clothing_id"]]};
        }
    }
    else if ([segue.identifier isEqualToString:@"profile"])
    {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        UserProfileViewController *vcUserProfile = segue.destinationViewController;

        if (_selectedFilterIndex == 2)
        {
            NSMutableDictionary *userInfo = [_aryDisplay objectAtIndex:indexPath.row];
            vcUserProfile.strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
        }
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    
    self.navigationController.navigationBarHidden = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
//    [self updateSwitch:0];
    if (_selectedFilterIndex == -1)
        [self onBrands:nil];
    else
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateData) userInfo:nil repeats:NO];
}

- (BOOL)searchData:(int)searchType
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return NO;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || strUserID.length == 0)
        return NO;

    NSString *strAPIName = nil;
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              };
    if (searchType == 0)
        strAPIName = @"count_by_brand";
    else if (searchType == 1)
        strAPIName = @"count_by_clothing";
    else if (searchType == 2)
        strAPIName = @"search_popular";
  
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:strAPIName request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1)
            _aryDatas = [[dicRet objectForKey:@"result"] mutableCopy];
        else if (_selectedFilterIndex == 2)
            _aryDatas = [[dicRet objectForKey:@"users"] mutableCopy];
        
        if (_aryDatas != nil)
        {
            if (_selectedFilterIndex == 0)
            {
//                NSArray *aryBrands = [[DataManager shareDataManager] getBrandsArray];
//                for (NSDictionary *brandInfo in aryBrands)
//                {
//                    BOOL found = NO;
//                    for (NSDictionary *dataInfo in _aryDatas)
//                    {
//                        if ([[brandInfo objectForKey:@"brand_id"] intValue] == [[dataInfo objectForKey:@"brand_id"] intValue])
//                            found = YES;
//                    }
//                    
//                    if (!found)
//                        [_aryDatas addObject:brandInfo];
//                }
            }
            else if (_selectedFilterIndex == 1)
            {
                NSArray *aryClothings = [[DataManager shareDataManager] getClothingTypesArray];
                for (NSDictionary *clothingInfo in aryClothings)
                {
                    BOOL found = NO;
                    for (NSDictionary *dataInfo in _aryDatas)
                    {
                        if ([[clothingInfo objectForKey:@"clothing_id"] intValue] == [[dataInfo objectForKey:@"clothing_id"] intValue])
                            found = YES;
                    }
                    
                    if (!found)
                        [_aryDatas addObject:clothingInfo];
                }
            }

            _aryDatas = [[_aryDatas sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSInteger postCount1 = [[obj1 objectForKey:@"post_count"] integerValue];
                NSInteger postCount2 = [[obj2 objectForKey:@"post_count"] integerValue];
                
                if (postCount1 == postCount2)
                    return NSOrderedSame;
                else if (postCount1 < postCount2)
                    return NSOrderedDescending;
                
                return NSOrderedAscending;
            }] mutableCopy];
            
            _aryDisplay = [_aryDatas mutableCopy];
        }
        
        return YES;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return NO;
}

- (IBAction)onBrands:(id)sender
{
    ((UIButton *)sender).selected = YES;
    
    _selectedFilterIndex = 0;
    
    [self updateSwitch:0.3f];
    
    if (!self.searchBar.hidden)
        self.searchBar.placeholder = @"Search for Brands";
    
    [self performSelector:@selector(updateData) withObject:nil afterDelay:0.1f];
}

- (IBAction)onTypes:(id)sender
{
    ((UIButton *)sender).selected = YES;
    
    _selectedFilterIndex = 1;
    
    [self updateSwitch:0.3f];
    
    if (!self.searchBar.hidden)
        self.searchBar.placeholder = @"Search for Clothing Types";
    
    [self performSelector:@selector(updateData) withObject:nil afterDelay:0.1f];
}

- (IBAction)onPopular:(id)sender
{
    ((UIButton *)sender).selected = YES;
    
    _selectedFilterIndex = 2;
    
    [self updateSwitch:0.3f];
    
    if (!self.searchBar.hidden)
        self.searchBar.placeholder = @"Search for Users";
    
    [self performSelector:@selector(updateData) withObject:nil afterDelay:0.1f];
}

- (void) updateData
{
    if ([self searchData:_selectedFilterIndex])
        [self.tvLists reloadData];

    [self.refreshControl endRefreshing];
}

- (IBAction)onSearch:(id)sender
{
    [UIView animateWithDuration:0.3f animations:^{

        self.searchBar.frame = CGRectMake(0, self.searchBar.frame.origin.y, CGRectGetWidth(self.searchBar.frame), CGRectGetHeight(self.searchBar.frame));
        
        if (_selectedFilterIndex == 0)
            self.searchBar.placeholder = @"Search for Brands";
        else if (_selectedFilterIndex == 1)
            self.searchBar.placeholder = @"Search for Clothing Types";
        else if (_selectedFilterIndex == 2)
            self.searchBar.placeholder = @"Search for Users";
        
        [self.searchBar becomeFirstResponder];
    } completion:^(BOOL finished) {

//        if (_selectedFilterIndex == 0)
//            self.searchBar.placeholder = @"Search for Brands";
//        else if (_selectedFilterIndex == 1)
//            self.searchBar.placeholder = @"Search for Clothing Types";
//        else if (_selectedFilterIndex == 2)
//            self.searchBar.placeholder = @"Search for Users";
//        
//        [self.searchBar becomeFirstResponder];
    }];
}

- (void) updateSwitch:(float) duration
{
    self.btnBrands.selected = _selectedFilterIndex == 0;
    self.btnTypes.selected = _selectedFilterIndex == 1;
    self.btnPopular.selected = _selectedFilterIndex == 2;
    
    [UIView animateWithDuration:duration animations:^{

        if(_selectedFilterIndex == 0)
            self.ivThumb.center = self.btnBrands.center;
        else if(_selectedFilterIndex == 1)
            self.ivThumb.center = self.btnTypes.center;
        else if(_selectedFilterIndex == 2)
            self.ivThumb.center = self.btnPopular.center;
        
    } completion:^(BOOL finished) {

    }];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_aryDisplay == nil)
        return 0;
    
    return _aryDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 32, 32);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];

    if (_selectedFilterIndex == 0)
    {
        NSMutableDictionary *countInfo = [_aryDisplay objectAtIndex:indexPath.row];
        
        NSString *strBrand = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"brand_name"]];
        if (strBrand != nil && [strBrand isKindOfClass:[NSString class]])
            cell.textLabel.text = strBrand;
        else
            cell.textLabel.text = @"";
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"post_count"]];
    }
    else if (_selectedFilterIndex == 1)
    {
        NSMutableDictionary *countInfo = [_aryDisplay objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"clothing_type"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"post_count"]];
    }
    else if (_selectedFilterIndex == 2)
    {
        NSMutableDictionary *userInfo = [_aryDisplay objectAtIndex:indexPath.row];
        
        NSString *strUserName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"first_name"]];
        if (strUserName.length == 0)
            strUserName = [NSString stringWithFormat:@"@%@", [userInfo objectForKey:@"user_name"]];
        
        cell.textLabel.text = strUserName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"post_count"]];
    }
    
//    UIImageView *ivDetail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discover_icon_detail"]];
//    ivDetail.frame = CGRectMake(0, 0, 12, 14);
//    ivDetail.userInteractionEnabled = YES;
//    
//    cell.accessoryView = ivDetail;
//    ivDetail = nil;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedFilterIndex == 2)
        [self performSegueWithIdentifier:@"profile" sender:indexPath];
    else
        [self performSegueWithIdentifier:@"posts" sender:indexPath];
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (_selectedFilterIndex != 0)
        return;
    
    [_aryDisplay removeAllObjects];

    if (searchText.length == 0)
    {
        _aryDisplay = [_aryDatas mutableCopy];
    }
    else
    {
        for (NSMutableDictionary *countInfo in _aryDatas)
        {
            NSString *strBrandName = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"brand_name"]];
            if ([strBrandName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
                [_aryDisplay addObject:countInfo];
        }
    }
    
    [self.tvLists reloadData];
}

- (void)searchByBrandName:(NSString *)strBrand
{
    [JSWaiter ShowWaiter:self title:@"Updating..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo == nil)
        return;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || strUserID.length == 0)
        return;
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"brand_name" : strBrand,
                              };
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"count_by_brand_name" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        _aryDisplay = [[dicRet objectForKey:@"result"] mutableCopy];
        if (_aryDisplay != nil)
        {
            _aryDisplay = [[_aryDisplay sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSInteger postCount1 = [[obj1 objectForKey:@"post_count"] integerValue];
                NSInteger postCount2 = [[obj2 objectForKey:@"post_count"] integerValue];
                
                if (postCount1 == postCount2)
                    return NSOrderedSame;
                else if (postCount1 < postCount2)
                    return NSOrderedDescending;
                
                return NSOrderedAscending;
            }] mutableCopy];
        }
        
        [self.tvLists reloadData];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.searchBar.frame = CGRectMake(CGRectGetWidth(self.view.frame), self.searchBar.frame.origin.y, CGRectGetWidth(self.searchBar.frame), CGRectGetHeight(self.searchBar.frame));
        
    } completion:^(BOOL finished) {
        
        [self.searchBar resignFirstResponder];
        
    }];
    
    NSString *strSearch = self.searchBar.text;
    if (strSearch == nil || strSearch.length == 0)
        return;
    
    [_aryDisplay removeAllObjects];
    
    if (_selectedFilterIndex == 0)
    {
/*
        for (NSMutableDictionary *countInfo in _aryDatas)
        {
            NSString *strBrandName = [countInfo objectForKey:@"brand_name"];
            if ([strBrandName rangeOfString:strSearch options:NSCaseInsensitiveSearch].location != NSNotFound)
                [_aryDisplay addObject:countInfo];
        }
*/
        [self performSelector:@selector(searchByBrandName:) withObject:strSearch afterDelay:0.1f];
    }
    else if (_selectedFilterIndex == 1)
    {
        for (NSMutableDictionary *countInfo in _aryDatas)
        {
            NSString *strClothingType = [NSString stringWithFormat:@"%@", [countInfo objectForKey:@"clothing_type"]];
            if ([strClothingType rangeOfString:strSearch options:NSCaseInsensitiveSearch].location != NSNotFound)
                [_aryDisplay addObject:countInfo];
        }
    }
    else if (_selectedFilterIndex == 2)
    {
        for (NSMutableDictionary *userInfo in _aryDatas)
        {
            NSString *strFullName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"first_name"]];
            NSString *strUserName = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_name"]];
            if ([strFullName rangeOfString:strSearch options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [strUserName rangeOfString:strSearch options:NSCaseInsensitiveSearch].location != NSNotFound)
                [_aryDisplay addObject:userInfo];
        }
    }
    
    [self.tvLists reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.searchBar.frame = CGRectMake(CGRectGetWidth(self.view.frame), self.searchBar.frame.origin.y, CGRectGetWidth(self.searchBar.frame), CGRectGetHeight(self.searchBar.frame));
        
    } completion:^(BOOL finished) {
        
        [self.searchBar resignFirstResponder];
        
    }];
}

@end
