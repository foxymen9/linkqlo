//
//  SizeInputViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/16/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "SizeInputViewController.h"

#import "DataManager.h"

@interface SizeInputViewController ()

@property (nonatomic, assign) IBOutlet UILabel *lblFirst;
@property (nonatomic, assign) IBOutlet UILabel *lblSecond;

@property (nonatomic, assign) IBOutlet UIPickerView *pickerView;

@property (nonatomic, assign) NSString *strGender;

@property (nonatomic, assign) NSInteger numberOfSections;

@property (nonatomic, retain) NSString *strFirstTitle;
@property (nonatomic, retain) NSString *strSecondTitle;

@property (nonatomic, retain) NSString *strFirstSection;
@property (nonatomic, retain) NSString *strSecondSection;

@property (nonatomic, retain) NSArray *aryFirst;
@property (nonatomic, retain) NSArray *arySecond;

@end

@implementation SizeInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.numberOfSections = 0;
    self.aryFirst = self.arySecond = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)makeSizeTierArray
{
    NSArray *arySizeTier = [[NSArray alloc] initWithObjects:@"XXS", @"XS", @"S", @"M", @"L", @"XL", @"XXL", @"N.A.", nil];
    return arySizeTier;
}

- (NSArray *)makeSizeNumberArray
{
    NSMutableArray *aryNumber = [[NSMutableArray alloc] init];
    for (int number = 0; number <= 28; number++)
    {
        NSString *strNumber = [NSString stringWithFormat:@"%d", number];
        [aryNumber addObject:strNumber];
    }
    
    [aryNumber addObject:@"N.A."];
    return (NSArray *)aryNumber;
}

- (NSArray *)makeCuttingArray
{
    NSArray *aryCutting = [[NSArray alloc] initWithObjects:@"Extra Trim", @"Trim", @"Regular", @"N.A.", nil];
    return aryCutting;
}

- (NSArray *)makeSuitArray
{
    NSMutableArray *arySuit = [[NSMutableArray alloc] init];
    for (int suit = 34; suit <= 56; suit++)
    {
        NSString *strSuit = [NSString stringWithFormat:@"%d", suit];
        [arySuit addObject:strSuit];
    }
    
    return (NSArray *)arySuit;
}

- (NSArray *)makeNeckArray
{
    NSMutableArray *aryNeck = [[NSMutableArray alloc] init];
    for (int neck = 13; neck <= 21; neck++)
    {
        NSString *strNeck = [NSString stringWithFormat:@"%d", neck];
        [aryNeck addObject:strNeck];
    }
    
    return (NSArray *)aryNeck;
}

- (NSArray *)makeSleeveArray
{
    NSMutableArray *arySleeve = [[NSMutableArray alloc] init];
    for (int sleeve = 30; sleeve <= 38; sleeve++)
    {
        NSString *strSleeve = nil;
        if (sleeve < 38)
            strSleeve = [NSString stringWithFormat:@"%d/%d", sleeve, sleeve + 1];
        else
            strSleeve = [NSString stringWithFormat:@"%d+", sleeve];
        
        [arySleeve addObject:strSleeve];
    }
    
    return (NSArray *)arySleeve;
}

- (NSArray *)makeWaistArray
{
    NSMutableArray *aryWaist = [[NSMutableArray alloc] init];
    for (int waist = 28; waist <= 58; waist++)
    {
        NSString *strWaist = [NSString stringWithFormat:@"%d", waist];
        [aryWaist addObject:strWaist];
    }

    return (NSArray *)aryWaist;
}

- (NSArray *)makeInseamArray
{
    NSMutableArray *aryInseam = [[NSMutableArray alloc] init];
    for (int inseam = 30; inseam <= 37; inseam++)
    {
        NSString *strInseam = nil;
        if (inseam < 37)
            strInseam = [NSString stringWithFormat:@"%d", inseam];
        else
            strInseam = @"36+";
        
        [aryInseam addObject:strInseam];
    }
    
    return (NSArray *)aryInseam;
}

- (NSArray *)makeSizeShoeArray
{
    NSMutableArray *arySizeShoe = [[NSMutableArray alloc] init];
    for (float shoe = 5; shoe <= 20; shoe += 0.5)
    {
        NSString *strSizeShoe = nil;
        if (shoe == (int)shoe)
            strSizeShoe = [NSString stringWithFormat:@"%d", (int)shoe];
        else
            strSizeShoe = [NSString stringWithFormat:@"%.1f", shoe];
        
        [arySizeShoe addObject:strSizeShoe];
    }
    
    return (NSArray *)arySizeShoe;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSDictionary *userInfo = [[DataManager shareDataManager] getUserInfo];
    if (userInfo != nil)
        self.strGender = [userInfo objectForKey:@"gender"];

    if (self.clothingID == 1) // Jeans
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Waist";
            self.aryFirst = [self makeWaistArray];
            self.strFirstSection = self.strWaist;
            
            self.strSecondTitle = @"Inseam";
            self.arySecond = [self makeInseamArray];
            self.strSecondSection = self.strInseam;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 2) // Pants
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Waist";
            self.aryFirst = [self makeWaistArray];
            self.strFirstSection = self.strWaist;

            self.strSecondTitle = @"Inseam";
            self.arySecond = [self makeInseamArray];
            self.strSecondSection = self.strInseam;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 3) // Dress Shirts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Neck";
            self.aryFirst = [self makeNeckArray];
            self.strFirstSection = self.strNeck;
            
            self.strSecondTitle = @"Sleeve";
            self.arySecond = [self makeSleeveArray];
            self.strSecondSection = self.strSleeve;
        }
    }
    else if (self.clothingID == 4) // Shorts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 1;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 5) // Coats
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 1;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 6) // Dresses
    {
        if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 7) // Tights
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Waist";
            self.aryFirst = [self makeWaistArray];
            self.strFirstSection = self.strWaist;
            
            self.strSecondTitle = @"Inseam";
            self.arySecond = [self makeInseamArray];
            self.strSecondSection = self.strInseam;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 8) // T-Shirts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Cutting";
            self.arySecond = [self makeCuttingArray];
            self.strSecondSection = self.strCutting;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
//    else if (self.clothingID == 9) // Trenches
//    {
//        if ([self.strGender isEqualToString:@"male"])
//        {
//            self.numberOfSections = 1;
//            
//            self.strFirstTitle = @"Size-Tier";
//            self.aryFirst = [self makeSizeTierArray];
//            self.strFirstSection = self.strSizeTier;
//        }
//        else if ([self.strGender isEqualToString:@"female"])
//        {
//            self.numberOfSections = 2;
//            
//            self.strFirstTitle = @"Size-Tier";
//            self.aryFirst = [self makeSizeTierArray];
//            self.strFirstSection = self.strSizeTier;
//           
//            self.strSecondTitle = @"Size-Number";
//            self.arySecond = [self makeSizeNumberArray];
//            self.strSecondSection = self.strSizeNumber;
//        }
//    }
    else if (self.clothingID == 10) // Jackets
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 1;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 11) // Sweaters
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Cutting";
            self.arySecond = [self makeCuttingArray];
            self.strSecondSection = self.strCutting;
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
       }
    }
    else if (self.clothingID == 12) // Tops
    {
        if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 13) // Suits
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 1;
            
            self.strFirstTitle = @"Size-Suit";
            self.aryFirst = [self makeSuitArray];
            self.strFirstSection = self.strSizeSuit;
        }
    }
    else if (self.clothingID == 14) // Cacual Shirts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            self.numberOfSections = 1;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
        }
    }
    else if (self.clothingID == 15) // Skirts
    {
        if ([self.strGender isEqualToString:@"female"])
        {
            self.numberOfSections = 2;
            
            self.strFirstTitle = @"Size-Tier";
            self.aryFirst = [self makeSizeTierArray];
            self.strFirstSection = self.strSizeTier;
            
            self.strSecondTitle = @"Size-Number";
            self.arySecond = [self makeSizeNumberArray];
            self.strSecondSection = self.strSizeNumber;
        }
    }
    else if (self.clothingID == 16) // Shoes
    {
        self.numberOfSections = 1;
        
        self.strFirstTitle = @"Size-Shoe";
        self.aryFirst = [self makeSizeShoeArray];
        self.strFirstSection = self.strSizeShoe;
    }
    
    if (self.numberOfSections == 1)
    {
        self.lblFirst.frame = CGRectMake(self.lblFirst.frame.origin.x, self.lblFirst.frame.origin.y, self.pickerView.frame.size.width, self.lblFirst.frame.size.height);
        self.lblSecond.hidden = YES;
    }
    
    if (self.strFirstTitle != nil && self.strFirstTitle.length > 0)
        [self.lblFirst setText:self.strFirstTitle];

    if (self.strSecondTitle != nil && self.strSecondTitle.length > 0)
        [self.lblSecond setText:self.strSecondTitle];
    
    [self.pickerView reloadAllComponents];
    
    if (self.aryFirst != nil)
    {
        if (self.strFirstSection != nil && self.strFirstSection.length > 0)
        {
            NSUInteger rowFirst = [self.aryFirst indexOfObject:self.strFirstSection];
            if (rowFirst != NSNotFound)
            {
                [self.pickerView selectRow:(NSInteger)rowFirst inComponent:0 animated:NO];
                [self setValues:rowFirst inComponent:0];
            }
        }
        else
        {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
            [self setValues:0 inComponent:0];
        }
    }
    
    if (self.arySecond != nil)
    {
        if (self.strSecondSection != nil && self.strSecondSection.length > 0)
        {
            NSUInteger rowSecond = [self.arySecond indexOfObject:self.strSecondSection];
            if (rowSecond != NSNotFound)
            {
                [self.pickerView selectRow:(NSInteger)rowSecond inComponent:1 animated:NO];
                [self setValues:rowSecond inComponent:1];
            }
        }
        else
        {
            [self.pickerView selectRow:0 inComponent:1 animated:NO];
            [self setValues:0 inComponent:1];
        }
    }
}

#pragma mark - Navigation

/*
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
    if (self.delegate != nil)
    {
        if (self.strSizeTier == nil) self.strSizeTier = @"";
        if (self.strSizeNumber == nil) self.strSizeNumber = @"";
        if (self.strCutting == nil) self.strCutting = @"";
        if (self.strSizeSuit == nil) self.strSizeSuit = @"";
        
        if (self.strNeck == nil) self.strNeck = @"";
        if (self.strSleeve == nil) self.strSleeve = @"";
        if (self.strWaist == nil) self.strWaist = @"";
        if (self.strInseam == nil) self.strInseam = @"";
        
        if (self.strSizeShoe == nil) self.strSizeShoe = @"";
        
        NSDictionary *dicSizeParams = @{
                                        @"size_tier" : self.strSizeTier,
                                        @"size_number" : self.strSizeNumber,
                                        @"cutting" : self.strCutting,
                                        @"size_suit" : self.strSizeSuit,
                                        @"neck" : self.strNeck,
                                        @"sleeve" : self.strSleeve,
                                        @"waist" : self.strWaist,
                                        @"inseam" : self.strInseam,
                                        @"size_shoe" : self.strSizeShoe,
                                        };
        [self.delegate selectSizeParams:dicSizeParams];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIPickerViewDelegate

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return (int)self.numberOfSections;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return (int)self.aryFirst.count;
    }
    else if (component == 1)
    {
        return (int)self.arySecond.count;
    }
    
    return 0;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.aryFirst[row];
    }
    else if (component == 1)
    {
        return self.arySecond[row];
    }
    
    return nil;
}

- (void)setValues:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if (self.clothingID == 1) // Jeans
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strWaist = self.aryFirst[row];
            else if (component == 1)
                self.strInseam = self.arySecond[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 2) // Pants
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strWaist = self.aryFirst[row];
            else if (component == 1)
                self.strInseam = self.arySecond[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 3) // Dress Shirts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strNeck = self.aryFirst[row];
            else if (component == 1)
                self.strSleeve = self.arySecond[row];
        }
    }
    else if (self.clothingID == 4) // Shorts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strWaist = self.aryFirst[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 5) // Coats
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 6) // Dresses
    {
        if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 7) // Tights
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strWaist = self.aryFirst[row];
            else if (component == 1)
                self.strInseam = self.arySecond[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 8) // T-Shirts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strCutting = self.arySecond[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
//    else if (self.clothingID == 9) // Trenches
//    {
//        if ([self.strGender isEqualToString:@"male"])
//        {
//            if (component == 0)
//                self.strSizeTier = self.aryFirst[row];
//        }
//        else if ([self.strGender isEqualToString:@"female"])
//        {
//            if (component == 0)
//                self.strSizeTier = self.aryFirst[row];
//            else if (component == 1)
//                self.strSizeNumber = self.arySecond[row];
//        }
//    }
    else if (self.clothingID == 10) // Jackets
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 11) // Sweaters
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strCutting = self.arySecond[row];
        }
        else if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 12) // Tops
    {
        if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 13) // Suits
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strSizeSuit = self.aryFirst[row];
        }
    }
    else if (self.clothingID == 14) // Cacual Shirts
    {
        if ([self.strGender isEqualToString:@"male"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
        }
    }
    else if (self.clothingID == 15) // Skirts
    {
        if ([self.strGender isEqualToString:@"female"])
        {
            if (component == 0)
                self.strSizeTier = self.aryFirst[row];
            else if (component == 1)
                self.strSizeNumber = self.arySecond[row];
        }
    }
    else if (self.clothingID == 16) // Shoes
    {
        if (component == 0)
            self.strSizeShoe = self.aryFirst[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setValues:row inComponent:component];
}

@end
