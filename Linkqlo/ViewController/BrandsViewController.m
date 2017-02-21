//
//  BrandsViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "BrandsViewController.h"

#import "DataManager.h"

@interface BrandsViewController ()

@property (nonatomic, assign) IBOutlet UITextField *txtBrand;
@property (nonatomic, assign) IBOutlet UITableView *tvItems;

//@property (nonatomic, retain) NSArray *aryTitles;
//@property (nonatomic, retain) NSMutableDictionary *dicDatas;
@property (nonatomic, retain) NSArray *aryBrands;

@end

@implementation BrandsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
/*
    self.dicDatas = [[NSMutableDictionary alloc] init];
    for (NSMutableDictionary *brandInfo in [[DataManager shareDataManager] getBrandsArray])
    {
        NSString *strBrandName = [brandInfo objectForKey:@"brand_name"];
        NSString *firstLetter = [strBrandName substringToIndex:1];
        NSInteger index = [self.dicDatas.allKeys indexOfObject:firstLetter];
        if (index == NSNotFound)
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [self.dicDatas setObject:array forKey:firstLetter];
        }
        
        NSMutableArray *values = [self.dicDatas objectForKey:firstLetter];
        [values addObject:brandInfo];
    }
    
    self.aryTitles = [self.dicDatas.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
*/
    NSMutableArray *aryBrands = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *brandInfo in [[DataManager shareDataManager] getBrandsArray])
    {
        NSString *strBrandName = [NSString stringWithFormat:@"%@", [brandInfo objectForKey:@"brand_name"]];
        [aryBrands addObject:strBrandName];
    }
    
    self.aryBrands = [aryBrands sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationItem setHidesBackButton:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
/*
    if (self.selectedBrandID != NSNotFound)
    {
        for (NSString *strTitle in self.aryTitles)
        {
            NSArray *brandsArray = [self.dicDatas objectForKey:strTitle];
            for (NSMutableDictionary *brandInfo in brandsArray)
            {
                if ([[brandInfo objectForKey:@"brand_id"] integerValue] == self.selectedBrandID)
                {
                    NSInteger section = [self.aryTitles indexOfObject:strTitle];
                    NSInteger row = [brandsArray indexOfObject:brandInfo];
                    
                    [self.tvItems scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
            
        }
    }
*/
    if (self.selectedBrand != nil)
    {
/*
        for (NSString *strTitle in self.aryTitles)
        {
            NSArray *brandsArray = [self.dicDatas objectForKey:strTitle];
            for (NSMutableDictionary *brandInfo in brandsArray)
            {
                if ([[brandInfo objectForKey:@"brand_name"] isEqualToString:self.selectedBrand])
                {
                    NSInteger section = [self.aryTitles indexOfObject:strTitle];
                    NSInteger row = [brandsArray indexOfObject:brandInfo];
                    
                    [self.tvItems scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
        }
*/
        self.txtBrand.text = self.selectedBrand;
        
        for (NSString *strTitle in self.aryBrands)
        {
            if ([strTitle isEqualToString:self.selectedBrand])
            {
                NSInteger row = [self.aryBrands indexOfObject:strTitle];
                [self.tvItems scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
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
    [self.txtBrand resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
/*
    if (self.selectedBrandID == 0 || self.selectedBrandID == NSNotFound)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select a brand." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (self.selectedBrandID != 0 && self.selectedBrandID != NSNotFound && self.delegate != nil)
        [self.delegate selectBrand:self.selectedBrandID];
*/
    [self.txtBrand resignFirstResponder];

    if (self.selectedBrand == nil || self.selectedBrand.length == 0)
    {
        if (self.txtBrand.text.length == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select a brand." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    
    self.selectedBrand = self.txtBrand.text;
    if (self.selectedBrand != nil && self.selectedBrand.length > 0 && self.delegate != nil)
        [self.delegate selectBrand:self.selectedBrand];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return self.aryTitles.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSString *strTitle = [self.aryTitles objectAtIndex:section];
//    NSArray *brands = [self.dicDatas objectForKey:strTitle];
//    return [brands count];
    return self.aryBrands.count;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.aryTitles objectAtIndex:section];
}
*/
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
//    NSString *strTitle = [self.aryTitles objectAtIndex:indexPath.section];
//    NSArray *brands = [self.dicDatas objectForKey:strTitle];
//    NSMutableDictionary *brandInfo = [brands objectAtIndex:indexPath.row];
//    cell.textLabel.text = [brandInfo objectForKey:@"brand_name"];
    NSString *strBrand = [self.aryBrands objectAtIndex:indexPath.row];
    cell.textLabel.text = strBrand;
    
//    if ([[brandInfo objectForKey:@"brand_id"] integerValue] == self.selectedBrandID)
    if ([strBrand isEqualToString:self.selectedBrand])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *strTitle = [self.aryTitles objectAtIndex:indexPath.section];
//    NSArray *brands = [self.dicDatas objectForKey:strTitle];
//    NSDictionary *selectedBrand = [brands objectAtIndex:indexPath.row];
//    if (selectedBrand != nil)
//        self.selectedBrandID = [[selectedBrand objectForKey:@"brand_id"] integerValue];
    NSString *strBrand = [self.aryBrands objectAtIndex:indexPath.row];

    self.txtBrand.text = strBrand;

    self.selectedBrand = strBrand;
    [self.tvItems reloadData];
    
//    if (self.selectedBrandID != 0 && self.selectedBrandID != NSNotFound && self.delegate != nil)
//        [self.delegate selectBrand:self.selectedBrandID];
    
//    [self.navigationController popViewControllerAnimated:YES];
}
/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.aryTitles;
}
*/
@end
