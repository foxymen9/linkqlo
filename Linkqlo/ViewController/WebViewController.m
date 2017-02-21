//
//  WebViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 12/10/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic, assign) IBOutlet UIWebView *webView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *viewActivity;

@end

@implementation WebViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.strNavigate != nil && self.strNavigate.length > 0)
    {
        NSURL *url = [NSURL URLWithString:self.strNavigate];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:requestObj];
        
        self.viewActivity.hidden = NO;
        [self.viewActivity startAnimating];
    }
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIWebViewDelegate

- (void)hideActivityView
{
    if (!self.viewActivity.hidden)
    {
        [self.viewActivity stopAnimating];
        self.viewActivity.hidden = YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivityView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideActivityView];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
