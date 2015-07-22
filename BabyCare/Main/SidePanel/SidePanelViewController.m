//
//  SidePanelViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/14/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "SidePanelViewController.h"
#import "SidePanelTableViewCell.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "Theme.h"

NSString * const SideMenuControllerWillSignoutNotification = @"SideMenuControllerWillSignoutNotification";

static NSString * const kSideMenuItemIcon = @"kSideMenuItemIcon";
static NSString * const kSideMenuItemTitle = @"kSideMenuItemTitle";
static NSString * const kSideMenuItemClass = @"kSideMenuItemClass";

@interface SidePanelViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, assign) NSUInteger selectedItemIndex;

@end

@implementation SidePanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedItemIndex = 0;
    self.view.backgroundColor = [Theme colorWithAlpha:1.0];
    [self.view addSubview:self.tableView];
    [self setViewConstraints];
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

- (void) setViewConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_tableView]-(0)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tableView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0
                                   constant:0.0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tableView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0
                                   constant:50*self.menuItems.count]];
}



#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SidePanelTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SidePanelTableViewCell"
                                                               forIndexPath:indexPath];
    
    UIView *selectBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    selectBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    selectBackgroundView.backgroundColor = [Theme colorWithAlpha:0.7];
    cell.selectedBackgroundView = selectBackgroundView;
    
    NSDictionary *dic = [self.menuItems objectAtIndex:[indexPath row]];
    cell.titleLabel.text = dic[kSideMenuItemTitle];
    cell.iconImageView.image = [UIImage imageNamed:dic[kSideMenuItemIcon]];
    
    return cell;
}



#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        self.selectedItemIndex = [indexPath row];
        if ( [self.parentViewController isKindOfClass:JASidePanelController.class] )
        {
            JASidePanelController *sidePanelController = (JASidePanelController*)self.parentViewController;
            [sidePanelController toggleLeftPanel:self];
        }
    }
    /*
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SideMenuControllerWillSignoutNotification
                                                            object:self];
    }
     */
    
}


- (void) presentMainViewController
{
    NSDictionary *dic = [self.menuItems objectAtIndex:self.selectedItemIndex];
    NSString *className = dic[kSideMenuItemClass];
    
    if (![className length]) {
        return;
    }
    
    Class controllerClass = NSClassFromString(className);
    
    if (!controllerClass || ![controllerClass isSubclassOfClass:[UIViewController class]]) {
        return;
    }
    
    id viewController = [[controllerClass alloc] init];
    
    if (viewController) {
        
        //[self.navigationController setViewControllers:@[viewController]];
        [(UINavigationController*)(self.sidePanelController.centerPanel) setViewControllers:@[viewController]];
        //self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
}



#pragma mark - Property accessor methods

- (UITableView*) tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        [_tableView registerNib:[UINib nibWithNibName:@"SidePanelTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"SidePanelTableViewCell"];
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.alwaysBounceVertical = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _tableView;
}

- (NSArray*) menuItems
{
    if (!_menuItems)
    {
        _menuItems = @[@{kSideMenuItemIcon:@"icon_home",
                         kSideMenuItemTitle:NSLocalizedString(@"Home", nil),
                         kSideMenuItemClass:@"MainViewController"},
                       
                       @{kSideMenuItemIcon:@"icon_guide",
                         kSideMenuItemTitle:NSLocalizedString(@"Guide", nil),
                         kSideMenuItemClass:@"ComingSoonViewController"},
                       
                       @{kSideMenuItemIcon:@"icon_observe",
                         kSideMenuItemTitle:NSLocalizedString(@"Observe", nil),
                         kSideMenuItemClass:@"LiveViewController"},
                       
                       @{kSideMenuItemIcon:@"icon_diary",
                         kSideMenuItemTitle:NSLocalizedString(@"Diary", nil),
                         kSideMenuItemClass:@"DiaryListViewController"},
                       
                       @{kSideMenuItemIcon:@"icon_remind",
                         kSideMenuItemTitle:NSLocalizedString(@"Remind", nil),
                         kSideMenuItemClass:@"RemindViewController"},
                       
                       @{kSideMenuItemIcon:@"icon_setting",
                         kSideMenuItemTitle:NSLocalizedString(@"Settings", nil),
                         kSideMenuItemClass:@"SettingsViewController"}
                       ];
    }
    return _menuItems;
}

- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex {
    if (_selectedItemIndex != selectedItemIndex) {
        _selectedItemIndex = selectedItemIndex;
        [self presentMainViewController];
    }
}

@end
