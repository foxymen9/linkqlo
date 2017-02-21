//
//  AddPeopleViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/11/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "AddPeopleViewController.h"

#import "UserTableViewCell.h"

#import "UserProfileViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

@interface AddPeopleViewController ()<UserTableViewCellDelegate>
{
    int _selectecMenuIndex;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMenu;
@property (nonatomic, assign) IBOutlet UIView *viewMenu;

@property (nonatomic, assign) IBOutlet UITableView *tvUsers;

@property (nonatomic, retain) NSMutableDictionary *similarUsers;
@property (nonatomic, retain) NSMutableArray *aryUsers;

@end

@implementation AddPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectecMenuIndex = 0;
    
    self.similarUsers = [[NSMutableDictionary alloc] init];
    self.aryUsers = [[NSMutableArray alloc] init];
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
    if ([segue.identifier isEqualToString:@"userprofile"])
    {
        UserProfileViewController *vcUserProfie = segue.destinationViewController;
        vcUserProfie.strUserID = (NSString *)sender;
    }
}

- (void)getSimilarUsers
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    for (int index = 0; index < 4; index++)
    {
        NSString *bsiType = nil;
        if (index == 0) bsiType = @"";
        else if (index == 1) bsiType = @"upper";
        else if (index == 2) bsiType = @"lower";
        else if (index == 3) bsiType = @"full";
        
        NSDictionary *request = @{
                                  @"user_id" : strUserID,
                                  @"bsi_type" : bsiType,
                                  };
        NSLog(@"%@", request);
        
        NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"get_similar_users" request:request];
        
        NSLog(@"%@", dicRet);
        
        if(dicRet != nil)
        {
            NSMutableArray *aryUsers = [dicRet objectForKey:@"users"];
            [self.similarUsers setObject:aryUsers forKey:[NSNumber numberWithInteger:index]];
        }
    }
    
    [JSWaiter HideWaiter];
    [self.tvUsers reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(_initView) userInfo:nil repeats:NO];
}

- (void) _initView
{
//    NSArray *subviews = self.svMenu.subviews;
//    for (UIView *subview in subviews) {
//        
//        if(subview.tag > 0)
//            [subview removeFromSuperview];
//    }
    
    UIButton *focusbutton = nil;
    
    float width = 120; float height = 24; float gap = 10;
    for (int n = 0 ; n < 4; n ++)
    {
        UIButton *button = [[UIButton alloc] init];

        button.tag = n + 1;
        if (n == 0)
        {
            [button setTitle:@"Simple Match" forState:UIControlStateNormal];
        }
        else
        {
            if (n == 1)
                [button setTitle:@"Upper Body Match" forState:UIControlStateNormal];
            else if (n == 2)
                [button setTitle:@"Lower Body Match" forState:UIControlStateNormal];
            else if (n == 3)
                [button setTitle:@"Full Body Match" forState:UIControlStateNormal];
        }
        
        button.frame = CGRectMake(0, 0, width, height);
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = height / 2;
        button.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
//        button.layer.borderColor = [[DataManager shareDataManager] getBackgroundColor].CGColor;
        button.layer.borderColor = [UIColor blackColor].CGColor;
//        [button setTitleColor:[[DataManager shareDataManager] getBackgroundColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.center = CGPointMake(gap + width / 2 + (width + gap) * n, CGRectGetHeight(self.svMenu.frame) / 2);
        
        [button addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.svMenu addSubview:button];
        
        if(n == 0) focusbutton = button;
    }
    
    self.svMenu.contentSize = CGSizeMake(gap + (width + gap) * 4, CGRectGetHeight(self.svMenu.frame));
    
    [self onMenu:focusbutton];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMenu:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [self.aryUsers removeAllObjects];
    
    NSArray *subviews = self.svMenu.subviews;
    for (UIView *subview in subviews)
    {
        if([subview isKindOfClass:[UIButton class]])
        {
//            if(button.tag == 1)
            {
                if(subview == button)
                {
                    button.selected = YES;
                }
                else
                {
                    ((UIButton *)subview).selected = NO;
                }
            }
//            else
//            {
//                if(subview.tag == 1)
//                {
//                    ((UIButton *)subview).selected = NO;
//                }
//                else if(subview == button)
//                {
//                    button.selected = !button.isSelected;
//                }
//            }
            
            if(((UIButton *)subview).isSelected)
            {
//                subview.backgroundColor = [[DataManager shareDataManager] getBackgroundColor];
                subview.backgroundColor = [UIColor blackColor];
                [(UIButton *)subview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                _selectecMenuIndex = (int)subview.tag - 1;
                
                if ([self.similarUsers objectForKey:[NSNumber numberWithInteger:_selectecMenuIndex]] == nil)
                {
                    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
                    
                    [self getSimilarUsers];
                }
                
                [self.aryUsers addObjectsFromArray:[self.similarUsers objectForKey:[NSNumber numberWithInteger:_selectecMenuIndex]]];
                
                self.aryUsers = [[self.aryUsers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    float percent1 = [[obj1 objectForKey:@"similar_percent"] floatValue];
                    float percent2 = [[obj2 objectForKey:@"similar_percent"] floatValue];
                    
                    if (percent1 == percent2)
                        return NSOrderedSame;
                    else if (percent1 < percent2)
                        return NSOrderedDescending;
                    
                    return NSOrderedAscending;
                }] mutableCopy];
            }
            else
            {
                subview.backgroundColor = [UIColor whiteColor];
//                [(UIButton *)subview setTitleColor:[[DataManager shareDataManager] getBackgroundColor] forState:UIControlStateNormal];
                [(UIButton *)subview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }
    
    [self.tvUsers reloadData];
}

#pragma mark UserListTableViewCellDelegate

- (BOOL)followFriend:(NSMutableDictionary *)followerInfo follow:(BOOL)follow
{
    if (followerInfo == nil)
        return NO;
    
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"friend_id" : [NSString stringWithFormat:@"%@", [followerInfo objectForKey:@"user_id"]],
                              };
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSString *strAPIName = nil;
    if (follow) strAPIName = @"follow_friend";
    else strAPIName = @"unfollow";
    
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
        
        NSString *strSuccess = [NSString stringWithFormat:@"%@", [dicRet objectForKey:@"success"]];
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

- (void)updateList
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    [self getSimilarUsers];
    
    NSArray *subviews = self.svMenu.subviews;
    for (UIView *subview in subviews)
    {
        if (subview.tag - 1 == _selectecMenuIndex)
            [self onMenu:subview];
    }
}

- (void) followWithView:(UIView *)view
{
    UserTableViewCell *cell = (UserTableViewCell *)view;
    NSIndexPath *indexPath = [self.tvUsers indexPathForCell:cell];
    NSMutableDictionary *followerInfo = [[self.aryUsers objectAtIndex:indexPath.row] mutableCopy];
    if (followerInfo != nil)
    {
        if ([[followerInfo objectForKey:@"is_following"] boolValue])
        {
            if ([self followFriend:followerInfo follow:NO])
            {
                [followerInfo setObject:@"0" forKey:@"is_following"];
                [self.aryUsers setObject:followerInfo atIndexedSubscript:indexPath.row];
                [self.tvUsers reloadData];
//                [self updateList];
            }
        }
        else
        {
            if ([self followFriend:followerInfo follow:YES])
            {
                [followerInfo setObject:@"1" forKey:@"is_following"];
                [self.aryUsers setObject:followerInfo atIndexedSubscript:indexPath.row];
                [self.tvUsers reloadData];
//                [self updateList];
            }
        }
    }
}

- (void)tapProfilePhoto:(UIView *)view
{
    UserTableViewCell *cell = (UserTableViewCell *)view;
    NSIndexPath *indexPath = [self.tvUsers indexPathForCell:cell];
    NSMutableDictionary *userInfo = [self.aryUsers objectAtIndex:indexPath.row];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    if (strUserID == nil || ![strUserID isKindOfClass:[NSString class]] || strUserID.length == 0)
        return;
    
    [self performSegueWithIdentifier:@"userprofile" sender:strUserID];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.aryUsers == nil)
        return 0;
/*
    if (self.aryUsers.count == 0)
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        
        messageLabel.text = @"No people is currently available.";
        messageLabel.textColor = [UIColor lightGrayColor];
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont italicSystemFontOfSize:18.0f];
        [messageLabel sizeToFit];
        
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
*/    
    return self.aryUsers.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

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
    NSMutableDictionary *user = [self.aryUsers objectAtIndex:indexPath.row];
    if (user != nil)
        [cell setUserInfo:user];
    
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *user = [self.aryUsers objectAtIndex:indexPath.row];
    if (user == nil)
        return;
    
    NSString *strUserID = [NSString stringWithFormat:@"%@", [user objectForKey:@"user_id"]];
    if (strUserID == nil || ![strUserID isKindOfClass:[NSString class]] || strUserID.length == 0)
        return;
    
    [self performSegueWithIdentifier:@"userprofile" sender:strUserID];
}


@end
