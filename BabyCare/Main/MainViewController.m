//
//  MainViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/14/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "MainViewController.h"
#import "AKSegmentedControl.h"
#import "UIViewController+Containment.h"
#import "Theme.h"

static NSString * const kSegmentTitle = @"kSegmentTitle";
static NSString * const kSegmentClass = @"kSegmentClass";

@interface MainViewController ()
@property (nonatomic, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *pageView;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *segments;
@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Home", nil);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *segments = [NSMutableArray array];
    [self.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ( [obj isKindOfClass:NSDictionary.class] )
        {
            NSString *segmentTitle = obj[kSegmentTitle];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = idx;
            [button setTitle:[NSLocalizedString(segmentTitle, nil) uppercaseString]
                    forState:UIControlStateNormal];
            [button setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4]
                         forState:UIControlStateNormal];
            [button setTitleColor:[Theme colorWithAlpha:1.0]
                         forState:UIControlStateSelected];
            button.titleLabel.font = [Theme boldFontOfSize:12.0f];
            [button addTarget:self
                       action:@selector(buttonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
            [segments addObject:button];
        }
    }];
    [self.segmentedControl setButtonsArray:segments];
    
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.pageView];
    [self setViewConstraints];
    
    [self displayViewController:self.pageViewController inView:self.pageView withFrame:self.pageView.bounds];
    
    [self buttonTapped:segments[0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Update constraints

- (void) setViewConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_segmentedControl, _pageView);
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[_segmentedControl(==50)]-0-[_pageView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_segmentedControl]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_pageView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}



#pragma mark - Target-action

- (void)buttonTapped:(id)sender
{
    if ( [sender isKindOfClass:UIButton.class] )
    {
        UIButton *button = (UIButton*)sender;
        [self.segmentedControl.buttonsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            UIButton *__button = (UIButton*)obj;
            __button.selected = button.tag == idx;
        }];
        NSDictionary *dic = self.segments[button.tag];
        NSString *className = dic[kSegmentClass];
        
        if (![className length])
        {
            return;
        }
        
        Class controllerClass = NSClassFromString(className);
        
        if (!controllerClass || ![controllerClass isSubclassOfClass:[UIViewController class]]) {
            return;
        }
        
        id viewController = [[controllerClass alloc] init];
        
        if (viewController)
        {
            [self.pageViewController setViewControllers:@[viewController]
                                              direction:button.tag ? UIPageViewControllerNavigationDirectionReverse :UIPageViewControllerNavigationDirectionForward
             
                                               animated:YES
                                             completion:nil];
        }
    }
}



#pragma mark - Property accessor methods

- (AKSegmentedControl*) segmentedControl {
    
    if (_segmentedControl == nil)
    {
        _segmentedControl = [[AKSegmentedControl alloc] initWithFrame:CGRectZero];
        _segmentedControl.backgroundColor = [UIColor whiteColor];
        [_segmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _segmentedControl;
}

- (UIView*) pageView {
    
    if (_pageView == nil)
    {
        _pageView = [[UIView alloc] initWithFrame:CGRectZero];
        [_pageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _pageView;
}

- (UIPageViewController*) pageViewController
{
    if (_pageViewController == nil)
    {
        _pageViewController =
        [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                      options:nil];
    }
    return _pageViewController;
}

- (NSArray*) segments
{
    if (_segments == nil)
    {
        _segments = @[@{kSegmentTitle:@"Baby's Parameter",kSegmentClass: @"HomeViewController"},
                      @{kSegmentTitle:@"Live",            kSegmentClass: @"LiveViewController"}];
    }
    return _segments;
}

@end
