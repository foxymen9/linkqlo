//
//  SelectingOneTimeViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/15/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "SelectItemViewController.h"

@interface SelectItemViewController ()
{
    int _selectedIndex;
}

@property (nonatomic, assign) IBOutlet UITableView *tvItems;

@end

@implementation SelectItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.aryItems == nil)
        return 0;
    
    return self.aryItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [self.aryItems objectAtIndex:indexPath.row];
    
    if(_selectedIndex == indexPath.row)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
