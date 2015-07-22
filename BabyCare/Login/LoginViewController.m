//
//  LoginViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/14/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "LoginViewController.h"
#import "ComingSoonViewController.h"
#import "UserDefaults.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *signInButton;
@property (nonatomic, weak) IBOutlet UIButton *registrationButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    [self.signInButton addTarget:self
                          action:@selector(buttonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.registrationButton addTarget:self
                                action:@selector(buttonTapped:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    self.signInButton.layer.cornerRadius = self.registrationButton.layer.cornerRadius = 2.0;
    self.registrationButton.layer.borderWidth = 1.0;
    self.registrationButton.layer.borderColor = [[UIColor colorWithRed:132/255.0
                                                                 green:171/255.0
                                                                  blue:82/255.0
                                                                 alpha:1.0] CGColor];
    self.signInButton.enabled = (self.usernameTextField.text.length > 0 && self.passwordTextField.text.length > 0);
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.usernameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    UITextField *otherTextField = textField == self.usernameTextField ? self.passwordTextField : self.usernameTextField;
    self.signInButton.enabled = (newLength > 0 && otherTextField.text.length > 0);
    return YES;
}


#pragma mark - Private utilities

- (void) buttonTapped:(id)sender
{
    if ( sender == self.signInButton )
    {
        [UserDefaults saveObject:self.passwordTextField.text key:@"Password"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ( sender == self.registrationButton )
    {
        ComingSoonViewController *comingSoonVC = [[ComingSoonViewController alloc] init];
        [self.navigationController pushViewController:comingSoonVC animated:YES];
    }
}

@end
