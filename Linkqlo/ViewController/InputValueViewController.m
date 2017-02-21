//
//  InputValueViewController.m
//  Linkqlo
//
//  Created by hanjinghe on 10/9/14.
//  Copyright (c) 2014 Linkqlo. All rights reserved.
//

#import "InputValueViewController.h"

@interface InputValueViewController ()

@property (nonatomic, assign) IBOutlet UITextField *txtValue;

@property (nonatomic, assign) IBOutlet UILabel *lblUnit;

@property (nonatomic, assign) IBOutlet UILabel *lblInstruction;
@property (nonatomic, assign) IBOutlet UITextView *tvInstruction;

@end

@implementation InputValueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInstruction
{
    NSString *strInstruction = nil;
    if ([self.title isEqualToString:@"Height"])
    {
        strInstruction = @"Review your last check-up result.";
    }
    else if ([self.title isEqualToString:@"Weight"])
    {
        strInstruction = @"Review your last check-up result.";
    }
    else if ([self.title isEqualToString:@"Chest"])
    {
        strInstruction = @"Lift your arms slightly and measure around the fullest part of the chest/bust area (circumference), keeping the tape level under your arms and across your back.";
    }
    else if ([self.title isEqualToString:@"Waist"])
    {
        strInstruction = @"Measure around the narrowest part of your waistline (circumference) where you normally wear your pants.";
    }
    else if ([self.title isEqualToString:@"Hip"])
    {
        strInstruction = @"Measure around the fullest part (circumference) of the hips.";
    }
    else if ([self.title isEqualToString:@"Foot"])
    {
        strInstruction = @"Measure the length of your foot.";
    }
    else if ([self.title isEqualToString:@"Neck"])
    {
        strInstruction = @"Measure around the middle of your neck (circumference), at the Adam’s apple (for men).";
    }
    else if ([self.title isEqualToString:@"Shoulder"])
    {
        strInstruction = @"Measure up and over the curve of your shoulders, across your back, then back down to the outside edge of the other shoulder point.\n\nThe tape measure will not be horizontally straight during this measurement. It must bend at a gentle curve along with your shoulders.";
    }
    else if ([self.title isEqualToString:@"Arm Length"])
    {
        strInstruction = @"Bend your elbow 90 degrees and place your hand on your hip. Hold the tape at the center back of your neck.\n\nMeasure across your shoulder to your elbow and down to your wrist, along the outside of the arm.";
    }
    else if ([self.title isEqualToString:@"Torso Height"])
    {
        strInstruction = @"Locate the bony bump at the base of your neck, where the slope of your shoulder meets your neck. This is your C7 vertebra.\n\nPlace the end of the tape measure on the C7 vertebra and measure downward, toward the hips.\n\nPlace your hands on your hips so you can feel your iliac crest, which servers as the “shelf” of your pelvic girdle. Position your hands so your thumbs are reaching behind you.\n\nImagine a line between your thumbs and take the measurement to where the tape measure crosses that line. This distance is your torso length.";
    }
    else if ([self.title isEqualToString:@"Upper Arm Size"])
    {
        strInstruction = @"Stand up straight with the arm relaxed at your side and measure around the midpoint between the shoulder bone and the elbow of one arm (circumference).";
    }
    else if ([self.title isEqualToString:@"Abdomen"])
    {
        strInstruction = @"Stand with feet together and torso straight but relaxed and measure around the widest part of your torso (circumference), often around your belly button.";
    }
    else if ([self.title isEqualToString:@"Leg Length"])
    {
        strInstruction = @"Stand with your feet a little under a foot apart.\n\nMeasure one leg from your hip bone to the ball of your foot while it is fully extended.";
    }
    else if ([self.title isEqualToString:@"Thigh"])
    {
        strInstruction = @"Measure around the fullest part (circumference) of your thigh.";
    }
    else if ([self.title isEqualToString:@"Calf"])
    {
        strInstruction = @"Measure around the fullest part (circumference) of your calf, often about halfway between the knee and the ankle.";
    }
    
    if (strInstruction != nil)
    {
        self.lblInstruction.text = strInstruction;
        self.tvInstruction.text = strInstruction;
    }
    
    [self.lblInstruction sizeToFit];
    [self.tvInstruction setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:16.f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.initial != 0)
        self.txtValue.text = [NSString stringWithFormat:@"%.1f", self.initial];
    
    if (self.isUSUnit)
    {
        if (self.isLength)
            self.lblUnit.text = @"inches";
        else
            self.lblUnit.text = @"lbs";
    }
    else
    {
        if (self.isLength)
            self.lblUnit.text = @"cm";
        else
            self.lblUnit.text = @"kg";
    }
    
    [self setInstruction];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    [self.txtValue becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    
    float diff = (keyboardRect.origin.y < self.view.frame.size.height) ? keyboardRect.size.height : 0;
    
    [UIView animateWithDuration:0.2 animations:^ {
        self.tvInstruction.frame = CGRectMake(self.tvInstruction.frame.origin.x, self.tvInstruction.frame.origin.y, self.tvInstruction.frame.size.width, self.view.frame.size.height - self.tvInstruction.frame.origin.y - diff);
        
    } completion:^(BOOL finished) {
        
    }];
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
    
    if (self.txtValue.text.length > 0 && self.delegate != nil)
        [self.delegate acceptValue:[self.txtValue.text floatValue] forIndex:self.keyIndex forUnit:self.isUSUnit];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
