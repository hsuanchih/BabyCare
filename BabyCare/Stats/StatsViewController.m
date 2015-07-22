//
//  StatsViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/15/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "StatsViewController.h"
#import "GraphViewController.h"
#import "StatsTableViewHeaderView.h"
#import "StatsTableViewCell.h"
#import "TitleView.h"
#import "UIViewController+Containment.h"
#import "SensorData.h"
#import "DataManager.h"
#import "Theme.h"

@interface StatsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UIView *graphView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSUInteger dataType;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) GraphViewController *graphViewController;
@property (nonatomic, strong) NSArray *historicData;
@end

@implementation StatsViewController

- (instancetype) initWithDataType:(NSUInteger)dataType
{
    self = [super init];
    if ( self )
    {
        self.dataType = dataType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.backButtonItem;
    
    [self populateHistoricData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataManagerDidUpdateDataNotification:)
                                                 name:@"DataManagerDidUpdateDataNotification"
                                               object:[DataManager manager]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StatsTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"StatsTableViewCell"];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.titleView = self.titleView;
    
    [self displayViewController:self.graphViewController
                         inView:self.graphView
                      withFrame:self.graphView.bounds];
    [self.graphViewController launchPlot];
    [self updateGraphData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - KVO

- (void) handleDataManagerDidUpdateDataNotification:(NSNotification*)notification
{
    [self populateHistoricData];
    [self updateGraphData];
}



#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historicData ? self.historicData.count : 0;
}



#pragma mark - UITableView datasource

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    StatsTableViewHeaderView *headerView = [[StatsTableViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 50.0)];
    headerView.dataLabel.text = [[SensorData titleForDataType:self.dataType] uppercaseString];
    return headerView;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatsTableViewCell"
                                                               forIndexPath:indexPath];
    
    NSUInteger row = indexPath.row;
    NSString *data = [self.historicData[row][@"value"] stringValue], *unit = [SensorData unitForDataType:self.dataType];
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", data, unit]
                                           attributes:@{
                                                        NSFontAttributeName:[Theme boldFontOfSize:20],
                                                        NSBaselineOffsetAttributeName:@0
                                                        }];
    if ([unit isEqualToString:NSLocalizedString(@"°C", nil)] ||
        [unit isEqualToString:NSLocalizedString(@"%", nil)])
    {
        [attributedString setAttributes:@{
                                          NSFontAttributeName:[Theme boldFontOfSize:11.0f],
                                          NSBaselineOffsetAttributeName:@5
                                          }
                                  range:NSMakeRange(data.length, attributedString.length - data.length)];
    } else {
        
        [attributedString setAttributes:@{
                                          NSFontAttributeName:[Theme boldFontOfSize:11.0f],
                                          NSBaselineOffsetAttributeName:@0
                                          }
                                  range:NSMakeRange(data.length, attributedString.length - data.length)];
        
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY\nHH:mm"];
    
    NSTimeInterval birthTime = [[NSDate date] timeIntervalSince1970] - 60*60*24*7,
    daysPassed = floorl(([self.historicData[row][@"time"] doubleValue] - birthTime)/(60*60*24));
    
    
    cell.timeLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.historicData[row][@"time"] doubleValue]]];
    cell.dayLabel.text = [NSString stringWithFormat:@"%@", [@(daysPassed) stringValue]];
    cell.dataLabel.attributedText = attributedString;
    cell.dataLabel.textColor = [SensorData themeColorForDataType:self.dataType];
    
    return cell;
}



#pragma mark - Private utilities

- (void) populateHistoricData
{
    DataManager *dataManager = [DataManager manager];
    if ( dataManager.historicData != nil && dataManager.historicData.count > self.dataType )
    {
        self.historicData = [NSArray arrayWithArray:dataManager.historicData[self.dataType]];
    }
}

- (void) updateGraphData
{
    NSDate *endOfToday = [[NSDate date] endOfDay];
    NSTimeInterval endTime = [endOfToday timeIntervalSince1970], startTime = endTime-6*24*60*60;
    self.graphViewController.xRange = NSMakeRange(startTime, 6*24*60*60);
    
    if (self.dataType == 4)
    {
        self.graphViewController.yRange = NSMakeRange(0, 4);
    }
    else
    {
        FPRange yRange = [[DataManager manager] rangeForDataType:self.dataType];
        self.graphViewController.yRange = NSMakeRange(floorf(yRange.location), floorf(yRange.length));
    }
    self.graphViewController.graphData = self.historicData;
    [self.graphViewController reloadPlotData];
}

- (void) buttonTapped:(id)sender
{
    if (sender == self.backButtonItem.customView)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}



#pragma mark - Property accessor methods

- (UIButton*) backButton
{
    if (_backButton == nil)
    {
        UIImage *backButtonImage = [UIImage imageNamed:[SensorData backImageNameForDataType:self.dataType]];
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat height = CGRectGetHeight(self.navigationController.navigationBar.bounds);
        CGFloat width = backButtonImage.size.width * height / backButtonImage.size.height;
        _backButton.bounds= CGRectMake(0, 0, width, height);
        [_backButton addTarget:self
                        action:@selector(buttonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:backButtonImage forState:UIControlStateNormal];
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

- (TitleView*) titleView
{
    if (_titleView == nil)
    {
        _titleView = [[TitleView alloc] initWithFrame:self.navigationController.navigationBar.frame];
        _titleView.imageView.image = [UIImage imageNamed:[SensorData iconImageNameForDataType:self.dataType]];
        _titleView.titleLabel.text = [SensorData titleForDataType:self.dataType];
        _titleView.titleLabel.textColor = [SensorData themeColorForDataType:self.dataType];
    }
    return _titleView;
}

- (GraphViewController*) graphViewController
{
    if (_graphViewController == nil)
    {
        _graphViewController = [[GraphViewController alloc] initWithGraphType:[SensorData graphTypeForDataType:self.dataType]];
        
        _graphViewController.lineColor = [SensorData themeColorForDataType:self.dataType];
        
        CGFloat graphInterval = [SensorData graphIntervalForDataType:self.dataType];
        if (graphInterval)
        {
            _graphViewController.yAxisInterval = graphInterval;
        }
        
        /*
         * Set plot symbol style
         */
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = 3.0;
        lineStyle.lineColor =
        [CPTColor colorWithCGColor:[[SensorData themeColorForDataType:self.dataType] CGColor]];
        _graphViewController.plotSymbol.lineStyle = lineStyle;
        _graphViewController.plotSymbol.fill =
        [CPTFill fillWithColor:[CPTColor colorWithComponentRed:251/255.0
                                                         green:249/255.0
                                                          blue:250/255.0
                                                         alpha:1.0]];
        _graphViewController.plotSymbol.size = CGSizeMake(10.0, 10.0);
        _graphViewController.plotSymbol.symbolType = CPTPlotSymbolTypeEllipse;
        
        /*
         * Set plot titles
         */
        _graphViewController.xTitle = nil;
        _graphViewController.yTitle = nil;
        
    }
    return _graphViewController;
}

@end
