//
//  UserListViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/15/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "UserListViewController.h"

#import "UserProfileViewController.h"

#import "UserTableViewCell.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface UserListViewController ()<UserTableViewCellDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tvUsers;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, retain) NSMutableArray *aryUsers;

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(loadUsers) forControlEvents:UIControlEventValueChanged];
    [self.tvUsers addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUsers
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:self.strAPIName request:self.dicRequest];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSMutableArray *aryUsers = [dicRet objectForKey:self.strFieldName];
        if (aryUsers != nil)
            self.aryUsers = [aryUsers mutableCopy];
        else
            self.aryUsers = nil;
        
        [self.tvUsers reloadData];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }

    [self.refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.strAPIName != nil && self.strAPIName.length > 0 && self.dicRequest != nil && self.aryUsers == nil)
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(loadUsers) userInfo:nil repeats:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"userprofile"])
    {
        UserProfileViewController *vcUserProfie = segue.destinationViewController;
        vcUserProfie.strUserID = (NSString *)sender;
    }
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.aryUsers == nil)
        return 0;
    
    if (self.aryUsers.count == 0)
    {
        NSString *strMessage = nil;
        if ([self.strAPIName isEqualToString:@"get_user_followings"])
            strMessage = @"No followings are currently available.\nPlease pull down to refresh.";
        else if ([self.strAPIName isEqualToString:@"get_user_followers"])
            strMessage = @"No followers are currently available.\nPlease pull down to refresh.";
        
        // Display a message when the table is empty
        if (tableView.backgroundView == nil)
        {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
            
            messageLabel.text = strMessage;
            messageLabel.textColor = [UIColor lightGrayColor];
            messageLabel.numberOfLines = 2;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont italicSystemFontOfSize:18.0f];
            [messageLabel sizeToFit];
            
            tableView.backgroundView = messageLabel;
        }
        else if (tableView.backgroundView != nil && [tableView.backgroundView isKindOfClass:[UILabel class]])
        {
            [(UILabel *)tableView.backgroundView setText:strMessage];
        }
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        if (tableView.backgroundView != nil)
        {
            [tableView.backgroundView removeFromSuperview];
            tableView.backgroundView = nil;
        }
    }
    
    return self.aryUsers.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = (UserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        [self.tvUsers registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:@"usertableviewcell"];
        cell = [self.tvUsers dequeueReusableCellWithIdentifier:@"usertableviewcell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UserTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *userInfo = [self.aryUsers objectAtIndex:indexPath.row];
    if (userInfo != nil)
        [cell setUserInfo:userInfo];
    
    if ([self.strAPIName isEqualToString:@"get_user_followings"])
    {
        if ([[userInfo objectForKey:@"is_following"] boolValue])
            [cell.btnFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
        else
            [cell.btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
    }
    else if ([self.strAPIName isEqualToString:@"get_user_followers"])
    {
        if ([[userInfo objectForKey:@"is_following"] boolValue])
            [cell.btnFollow setTitle:@"Following" forState:UIControlStateNormal];
        else
            [cell.btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
    }
    
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark UserListTableViewCellDelegate

- (BOOL)followFrield:(NSMutableDictionary *)followerInfo follow:(BOOL)follow
{
    if (followerInfo == nil)
        return NO;
    
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"friend_id" : [followerInfo objectForKey:@"user_id"],
                              };
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strAPIName = nil;
    if (follow)
        strAPIName = @"follow_friend";
    else
        strAPIName = @"unfollow";
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:strAPIName request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        if (strError != nil && strError.length > 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return NO;
        }
        
        NSString *strSuccess = [dicRet objectForKey:@"success"];
        if (strSuccess != nil && strSuccess.length > 0)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedsToRefresh"];
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

- (void) followWithView:(UIView *)view
{
    if (view == nil)
        return;
    
    UserTableViewCell *cell = (UserTableViewCell *)view;
    NSIndexPath *indexPath = [self.tvUsers indexPathForCell:cell];
    NSMutableDictionary *userInfo = [[self.aryUsers objectAtIndex:indexPath.row] mutableCopy];
    if (userInfo == nil)
        return;

    BOOL isFollowing = [[userInfo objectForKey:@"is_following"] boolValue];
    if (isFollowing)
    {
        if ([self followFrield:userInfo follow:NO])
        {
            [userInfo setObject:@"0" forKey:@"is_following"];
            [self.aryUsers setObject:userInfo atIndexedSubscript:indexPath.row];
            [self.tvUsers reloadData];
//            [self loadUsers];
        }
    }
    else
    {
        if ([self followFrield:userInfo follow:YES])
        {
            [userInfo setObject:@"1" forKey:@"is_following"];
            [self.aryUsers setObject:userInfo atIndexedSubscript:indexPath.row];
            [self.tvUsers reloadData];
//            [self loadUsers];
        }
    }
}

- (void)tapProfilePhoto:(UIView *)view
{
    UserTableViewCell *cell = (UserTableViewCell *)view;
    NSIndexPath *indexPath = [self.tvUsers indexPathForCell:cell];
    NSMutableDictionary *userInfo = [self.aryUsers objectAtIndex:indexPath.row];
    NSString *strUserID = [userInfo objectForKey:@"user_id"];
    if (strUserID == nil || ![strUserID isKindOfClass:[NSString class]] || strUserID.length == 0)
        return;
    
    [self performSegueWithIdentifier:@"userprofile" sender:strUserID];
}

@end
