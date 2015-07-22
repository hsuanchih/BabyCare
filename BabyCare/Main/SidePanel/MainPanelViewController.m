//
//  MainPanelViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/18/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "MainPanelViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "Theme.h"

@interface MainPanelViewController ()
@property (nonatomic, strong) UIButton *backButton, *menuButton;
@property (nonatomic, strong) UIBarButtonItem *backButtonItem, *menuButtonItem;
@end

@implementation MainPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.navigationController.navigationBarHidden == YES)
    {
        self.navigationController.navigationBarHidden = NO;
    }
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)])
    {
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    }
    self.navigationController.navigationBar.tintColor = [Theme colorWithAlpha:1.0];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = (self.navigationController.viewControllers.count > 1) ? self.backButtonItem : self.menuButtonItem;
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

- (void) barButtonItemTapped:(id)sender
{
    if ( self.navigationController.viewControllers.count > 1 )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.sidePanelController showLeftPanelAnimated:YES];
    }
}

#pragma mark - Property accessor methods

- (UIButton*) menuButton
{
    if (_menuButton == nil)
    {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.frame = CGRectMake(0, 0, 37, 25);
        [_menuButton setImage:[UIImage imageNamed:@"menu_button"]
                     forState:UIControlStateNormal];
        [_menuButton addTarget:self
                        action:@selector(barButtonItemTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

- (UIBarButtonItem*) menuButtonItem
{
    if (_menuButtonItem == nil)
    {
        _menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    }
    return _menuButtonItem;
}

- (UIButton*) backButton
{
    if (_backButton == nil)
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"back_button"]
                     forState:UIControlStateNormal];
        CGFloat height = CGRectGetHeight(self.navigationController.navigationBar.frame) * 0.5 ;
        CGFloat width = _backButton.imageView.image.size.width * height / _backButton.imageView.image.size.height;
        _backButton.bounds = CGRectMake(0, 0, width, height);
        
        [_backButton addTarget:self
                        action:@selector(barButtonItemTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIBarButtonItem*) backButtonItem
{
    if (_backButtonItem == nil)
    {
        _backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    }
    return _backButtonItem;
}

@end
