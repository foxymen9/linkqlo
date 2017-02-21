//
//  ResetPasswordViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 1/6/15.
//  Copyright (c) 2015 Linkqlo. All rights reserved.
//

#import "ResetPasswordViewController.h"

#import "JSWaiter.h"
#import "WebManager.h"

@interface ResetPasswordViewController () <UIAlertViewDelegate>

@property (nonatomic, assign) IBOutlet UITextField *txtMailAddr;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.txtMailAddr resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isValidMailAddress:(NSString *)mailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:mailAddress];
}

- (void)processSubmit
{
    [JSWaiter ShowWaiter:self title:@"Submitting..." type:0];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    NSString *strMailAddr = self.txtMailAddr.text;
    
    NSDictionary *request = @{
                              @"forgot_email" : strMailAddr,
                              };
    
    NSLog(@"%@", request);
    
    WebManager *_webMgr = [[WebManager alloc] initWithAsyncOption:false];
    _webMgr.delegate = self;
    
    NSMutableDictionary *dicRet = [_webMgr requestWithAction:@"forgot" request:request];
    
    [JSWaiter HideWaiter];
    
    NSLog(@"%@", dicRet);
    
    if(dicRet != nil)
    {
        NSString *strError = [dicRet objectForKey:@"error"];
        
        if(strError != nil && [strError isKindOfClass:[NSString class]]) // Failed
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else // Success
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Please check your mail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alertView.tag = 1;
            alertView.delegate = self;
            
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Failed to connect to server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (IBAction)onSubmit:(id)sender
{
    [self.txtMailAddr resignFirstResponder];
    
    NSString *strMailAddr = self.txtMailAddr.text;
    if (strMailAddr.length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    if (![self isValidMailAddress:strMailAddr])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }

    [self processSubmit];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
        [self.navigationController popViewControllerAnimated:YES];
}

@end
