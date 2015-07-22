//
//  ViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/13/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "ViewController.h"
#import "JASidePanelController.h"
#import "SidePanelViewController.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "DiaryManager.h"
#import "UserDefaults.h"
#import "MediaCenter.h"

@interface ViewController ()
@property (nonatomic, strong) JASidePanelController *sidePanelController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSettingsViewControllerWillSignOutNotification:)
                                                 name:@"SettingsViewControllerWillSignOutNotification"
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([UserDefaults loadObjectWithKey:@"Password"] != nil)
    {
        [self enterMainApp];
    }
    else
    {
        [self showLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private utilities

- (void) enterMainApp
{
    [MediaCenter validateMediaStore];
    [self presentSidePanelController];
}

- (void) showLogin
{
    [MediaCenter invalidateMediaStore];
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void) handleSettingsViewControllerWillSignOutNotification:(NSNotification*)notification
{
    [[DiaryManager manager] resetCoreData];
    [UserDefaults saveObject:nil key:@"Password"];
    [UserDefaults saveObject:nil key:@"birthday"];
    [self.navigationController popToViewController:self animated:NO];
}



#pragma mark - ViewController presentation

- (void) presentSidePanelController
{
    SidePanelViewController *sidePanelVC = [[SidePanelViewController alloc] init];
    self.sidePanelController.leftPanel = sidePanelVC;
    [sidePanelVC presentMainViewController];
    //[self.navigationController setViewControllers:@[self.sidePanelController]];
    [self.navigationController pushViewController:self.sidePanelController animated:YES];
}



#pragma mark - Property accessor methods

- (JASidePanelController*) sidePanelController
{
    if (_sidePanelController == nil)
    {
        _sidePanelController = [[JASidePanelController alloc] init];
        _sidePanelController.centerPanel = [[UINavigationController alloc] init];
        _sidePanelController.recognizesPanGesture = YES;
        _sidePanelController.leftFixedWidth = CGRectGetWidth([UIScreen mainScreen].bounds)*2/3;
    }
    return _sidePanelController;
}

@end
