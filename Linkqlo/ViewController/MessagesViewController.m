//
//  MessagesViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "MessagesViewController.h"

#import "MessageTableViewCell.h"

#import "PostDetailViewController.h"
#import "UserProfileViewController.h"
#import "MyTabBarViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"
#import "DataManager.h"

#import "UIImageView+WebCache.h"

@interface MessagesViewController () <MessageTableViewCellDelegate>
{
    int _selectedFilterIndex;
}

@property (nonatomic, assign) IBOutlet UITableView *tvMessages;

@property (nonatomic, assign) IBOutlet UIImageView *ivThumb;

@property (nonatomic, assign) IBOutlet UIButton *btnAll;
@property (nonatomic, assign) IBOutlet UIButton *btnComments;
@property (nonatomic, assign) IBOutlet UIButton *btnLikes;
@property (nonatomic, assign) IBOutlet UIButton *btnMe;

@property (nonatomic, assign) IBOutlet UIView *viewVert1;
@property (nonatomic, assign) IBOutlet UIView *viewVert2;
@property (nonatomic, assign) IBOutlet UIView *viewVert3;
@property (nonatomic, assign) IBOutlet UIView *viewHorz;

@property (nonatomic, retain) NSMutableArray *aryMessages;
@property (nonatomic, retain) NSMutableArray *aryDisplay;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ivThumb.frame = CGRectMake(0, 0, 74, 26);
    
    self.ivThumb.layer.cornerRadius = 13;
    self.ivThumb.clipsToBounds = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(getNotifications) forControlEvents:UIControlEventValueChanged];
    [self.tvMessages addSubview:self.refreshControl];

    _selectedFilterIndex = 0;
    self.aryDisplay = [[NSMutableArray alloc] init];
    
    self.btnAll.center = CGPointMake(self.view.frame.size.width / 8 * 1, self.btnAll.center.y);
    self.btnComments.center = CGPointMake(self.view.frame.size.width / 8 * 3, self.btnComments.center.y);
    self.btnLikes.center = CGPointMake(self.view.frame.size.width / 8 * 5, self.btnLikes.center.y);
    self.btnMe.center = CGPointMake(self.view.frame.size.width / 8 * 7, self.btnMe.center.y);
    
    self.viewVert1.frame = CGRectMake(self.view.frame.size.width / 4 * 1,
                                      self.viewVert1.frame.origin.y,
                                      1 / [UIScreen mainScreen].scale,
                                      self.viewVert1.frame.size.height);

    self.viewVert2.frame = CGRectMake(self.view.frame.size.width / 4 * 2,
                                      self.viewVert2.frame.origin.y,
                                      1 / [UIScreen mainScreen].scale,
                                      self.viewVert2.frame.size.height);
    
    self.viewVert3.frame = CGRectMake(self.view.frame.size.width / 4 * 3,
                                      self.viewVert3.frame.origin.y,
                                      1 / [UIScreen mainScreen].scale,
                                      self.viewVert3.frame.size.height);
    
    self.viewHorz.frame = CGRectMake(self.view.frame.origin.x,
                                     self.viewHorz.frame.origin.y,
                                     self.view.frame.size.width,
                                     1 / [UIScreen mainScreen].scale);
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
    if ([segue.identifier isEqualToString:@"postdetail"])
    {
        PostDetailViewController *vcPostDetail = segue.destinationViewController;
        vcPostDetail.postID = (NSString *)sender;
    }
    else if ([segue.identifier isEqualToString:@"userprofile"])
    {
        UserProfileViewController *vcUserProfie = segue.destinationViewController;
        vcUserProfie.strUserID = (NSString *)sender;
    }
}

- (void)getCommentsArray
{
    for (NSMutableDictionary *notification in self.aryMessages)
    {
        NSString *strType = [NSString stringWithFormat:@"%@", [notification objectForKey:@"type"]];
        if ([strType isEqualToString:@"comment"])
            [self.aryDisplay addObject:notification];
    }
}

- (void)getLikesArray
{
    for (NSMutableDictionary *notification in self.aryMessages)
    {
        NSString *strType = [NSString stringWithFormat:@"%@", [notification objectForKey:@"type"]];
        if ([strType isEqualToString:@"like"] || [strType isEqualToString:@"comment_like"])
            [self.aryDisplay addObject:notification];
    }
}

- (void)getMeArray
{
    for (NSMutableDictionary *notification in self.aryMessages)
    {
        NSString *strType = [NSString stringWithFormat:@"%@", [notification objectForKey:@"type"]];
        if ([strType isEqualToString:@"mention"])
            [self.aryDisplay addObject:notification];
    }
}

- (void)getNotifications
{
    [JSWaiter ShowWaiter:self title:@"Loading..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"user_id"]];
    
    NSDictionary *request = @{
                              @"user_id" : strUserID,
                              @"start" : @"0",
                              };
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"get_notifications" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        self.aryMessages = [dicRet objectForKey:@"notifications"];
        
        [self.aryDisplay removeAllObjects];
        if (_selectedFilterIndex == 0)
            self.aryDisplay = [self.aryMessages mutableCopy];
        else if (_selectedFilterIndex == 1)
            [self getCommentsArray];
        else if (_selectedFilterIndex == 2)
            [self getLikesArray];
        else if (_selectedFilterIndex == 3)
            [self getMeArray];
        
        [self.tvMessages reloadData];

        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        MyTabBarViewController *vcTab = (MyTabBarViewController *)self.navigationController.tabBarController;
        [vcTab updateBadge];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }

    [self.refreshControl endRefreshing];
}

- (NSAttributedString *)getDisplayString:(NSDictionary *)messageInfo
{
    NSAttributedString *strDisplay = nil;
    return strDisplay;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateSwitch:0];

    if (self.aryMessages == nil || [UIApplication sharedApplication].applicationIconBadgeNumber != 0)
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(getNotifications) userInfo:nil repeats:NO];
}

- (IBAction)onAll:(id)sender
{
    ((UIButton *)sender).selected = YES;
    
    _selectedFilterIndex = 0;
    
    [self updateSwitch:0.3f];
    
    [self.aryDisplay removeAllObjects];
    self.aryDisplay = [self.aryMessages mutableCopy];
    [self.tvMessages reloadData];
}

- (IBAction)onComments:(id)sender
{
    ((UIButton *)sender).selected = YES;
    
    _selectedFilterIndex = 1;
    
    [self updateSwitch:0.3f];

    [self.aryDisplay removeAllObjects];
    [self getCommentsArray];
    [self.tvMessages reloadData];
}

- (IBAction)onLikes:(id)sender
{
    ((UIButton *)sender).selected = YES;
    
    _selectedFilterIndex = 2;
    
    [self updateSwitch:0.3f];

    [self.aryDisplay removeAllObjects];
    [self getLikesArray];
    [self.tvMessages reloadData];
}

- (IBAction)onMe:(id)sender
{
    ((UIButton *)sender).selected = YES;
    
    _selectedFilterIndex = 3;
    
    [self updateSwitch:0.3f];

    [self.aryDisplay removeAllObjects];
    [self getMeArray];
    [self.tvMessages reloadData];
}

- (void) updateSwitch:(float) duration
{
    self.btnAll.selected = _selectedFilterIndex == 0;
    self.btnComments.selected = _selectedFilterIndex == 1;
    self.btnLikes.selected = _selectedFilterIndex == 2;
    self.btnMe.selected = _selectedFilterIndex == 3;
    
    [UIView animateWithDuration:duration animations:^{
        
        if(_selectedFilterIndex == 0)
        {
            self.ivThumb.frame = CGRectMake(0, 0, 72, 26);
            self.ivThumb.center = self.btnAll.center;
        }
        else if(_selectedFilterIndex == 1)
        {
            self.ivThumb.frame = CGRectMake(0, 0, 82, 26);
            self.ivThumb.center = self.btnComments.center;
        }
        else if(_selectedFilterIndex == 2)
        {
            self.ivThumb.frame = CGRectMake(0, 0, 72, 26);
            self.ivThumb.center = self.btnLikes.center;
        }
        else if(_selectedFilterIndex == 3)
        {
            self.ivThumb.frame = CGRectMake(0, 0, 72, 26);
            self.ivThumb.center = self.btnMe.center;
        }
     
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
    if (self.aryDisplay == nil)
        return 0;
    
    if (self.aryDisplay.count == 0)
    {
        // Display a message when the table is empty
        NSString *strMessage = @"No message is currently available.\nPlease pull down to refresh.";
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
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    return self.aryDisplay.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tvMessages)
    {
        NSMutableDictionary *notification = [self.aryDisplay objectAtIndex:indexPath.row];
        if (notification == nil)
            return 0;
        
        return [MessageTableViewCell heightForMessage:notification cellWidth:self.tvMessages.frame.size.width];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MessageTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    cell.ivPost.center = CGPointMake(CGRectGetWidth(self.tvMessages.frame) - CGRectGetWidth(cell.ivPost.frame) / 2 - 8, cell.ivPost.center.y);
//    cell.lblClothing.center = CGPointMake(CGRectGetWidth(self.tvMessages.frame) - CGRectGetWidth(cell.ivPost.frame) - CGRectGetWidth(cell.lblClothing.frame) / 2 - 16, cell.lblClothing.center.y);
//    
//    cell.lblContent.frame = CGRectMake(cell.lblContent.frame.origin.x,
//                                     cell.lblContent.frame.origin.y,
//                                     self.tvMessages.frame.size.width - cell.lblContent.frame.origin.x - cell.ivPost.frame.size.width - 16,
//                                     cell.lblContent.frame.size.height);
    
    NSMutableDictionary *notification = [self.aryDisplay objectAtIndex:indexPath.row];
    if (notification == nil)
        return;
    
    [cell setMessageInfo:notification];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *notification = [self.aryDisplay objectAtIndex:indexPath.row];
    if (notification == nil)
        return;
    
    NSString *strPostID = [NSString stringWithFormat:@"%@", [notification objectForKey:@"post_id"]];
    if (strPostID == nil || ![strPostID isKindOfClass:[NSString class]] || strPostID.length == 0)
        return;
    
    [self performSegueWithIdentifier:@"postdetail" sender:strPostID];
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *notification = [self.aryDisplay objectAtIndex:indexPath.row];
    if (notification == nil)
        return 0;

    CGFloat cellWidth = self.tvMessages.frame.size.width;
    CGSize contentSize = [MessageTableViewCell sizeForMessage:notification cellWidth:cellWidth];
    return contentSize.height;
}
*/
#pragma mark MessageTableViewCellDelegate

- (void)tapProfilePhoto:(UIView *)view
{
    MessageTableViewCell *cell = (MessageTableViewCell *)view;
    NSMutableDictionary *messageInfo = [cell getMessageInfo];
    NSString *strUserID = [NSString stringWithFormat:@"%@", [messageInfo objectForKey:@"user_id"]];
    if (strUserID == nil || ![strUserID isKindOfClass:[NSString class]] || strUserID.length == 0)
        return;
    
    [self performSegueWithIdentifier:@"userprofile" sender:strUserID];
}
@end
