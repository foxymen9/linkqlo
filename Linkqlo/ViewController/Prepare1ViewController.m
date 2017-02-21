//
//  Prepare1ViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "Prepare1ViewController.h"

@interface Prepare1ViewController ()

@end

@implementation Prepare1ViewController

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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
//    [self.navigationItem setHidesBackButton:YES];
}

- (IBAction)onGotoPrepare2Screen:(id)sender
{
    [self gotoPrepare2Screen];
}

- (void) gotoPrepare2Screen
{
    [self performSegueWithIdentifier:@"prepare2" sender:nil];
}

- (IBAction)onClose:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
