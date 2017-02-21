//
//  InputTextViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/15/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "InputTextViewController.h"

@interface InputTextViewController ()

@property (nonatomic, assign) IBOutlet UITextField *txtValue;

@end

@implementation InputTextViewController

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
    
    if (self.strValue != nil)
        self.txtValue.text = self.strValue;
    
    [self.txtValue becomeFirstResponder];
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
    [self.txtValue resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender
{
    [self.txtValue resignFirstResponder];
    
    if (self.delegate != nil)
        [self.delegate acceptText:self.txtValue.text forIndex:self.index];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.isAsciiInput)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        
        return YES;
    }
    
    return YES;
}

@end
