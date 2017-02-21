//
//  ClothingTypesViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "ClothingTypesViewController.h"

#import "DataManager.h"

@interface ClothingTypesViewController ()

@property (nonatomic, assign) IBOutlet UITableView *tvItems;

@property (nonatomic, retain) NSMutableArray *aryItems;

@end

@implementation ClothingTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSDictionary *useInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strGender = [NSString stringWithFormat:@"%@", [useInfo objectForKey:@"gender"]];
    
    self.aryItems = [[NSMutableArray alloc] init];
    for (NSDictionary *clothingInfo in [[DataManager shareDataManager] getClothingTypesArray])
    {
        NSString *strClothingGender = [NSString stringWithFormat:@"%@", [clothingInfo objectForKey:@"gender"]];
        if ([strClothingGender isEqualToString:@"all"] || [strClothingGender isEqualToString:strGender])
        {
            [self.aryItems addObject:clothingInfo];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setHidesBackButton:YES];

    if (self.selectedClothingTypeID != NSNotFound)
        [self.tvItems setContentOffset:CGPointMake(0, 44 * (self.selectedClothingTypeID - 1)) animated:YES];
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
    if (self.selectedClothingTypeID == 0 || self.selectedClothingTypeID == NSNotFound)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select a clothing type." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    // Check if this clothing is for your gender or not.
    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    NSString *strGender = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"gender"]];
    
    for (NSMutableDictionary *clothingInfo in self.aryItems)
    {
        if (clothingInfo == nil)
            continue;
        
        if ([[clothingInfo objectForKey:@"clothing_id"] integerValue] == _selectedClothingTypeID)
        {
            NSString *strClothingGender = [NSString stringWithFormat:@"%@", [clothingInfo objectForKey:@"gender"]];
            if ([strClothingGender isEqualToString:@"all"] || [strClothingGender isEqualToString:strGender])
            {
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select a clothing type for your gender." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
        }
    }
   
    if (self.selectedClothingTypeID != 0 && self.selectedClothingTypeID != NSNotFound && self.delegate != nil)
        [self.delegate selectClothingType:self.selectedClothingTypeID];
        
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *clothingInfo = [self.aryItems objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [clothingInfo objectForKey:@"clothing_type"]];
/*
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    
    NSString *strGender = [clothingInfo objectForKey:@"gender"];
    if ([strGender isEqualToString:@"all"])
        cell.detailTextLabel.text = @"Male/Female";
    else if ([strGender isEqualToString:@"male"])
        cell.detailTextLabel.text = @"Male";
    else if ([strGender isEqualToString:@"female"])
        cell.detailTextLabel.text = @"Female";
*/    
    if ([[clothingInfo objectForKey:@"clothing_id"] integerValue] == self.selectedClothingTypeID)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *clothingInfo = [self.aryItems objectAtIndex:indexPath.row];
    if (clothingInfo != nil)
        self.selectedClothingTypeID = [[clothingInfo objectForKey:@"clothing_id"] integerValue];
    
    [self.tvItems reloadData];

    if (self.selectedClothingTypeID != 0 && self.selectedClothingTypeID != NSNotFound && self.delegate != nil)
        [self.delegate selectClothingType:self.selectedClothingTypeID];
    
    [self.navigationController popViewControllerAnimated:YES];}

@end
