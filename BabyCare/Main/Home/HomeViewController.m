//
//  HomeViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/14/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "HomeViewController.h"
#import "StatsViewController.h"
#import "HomeCollectionHeaderView.h"
#import "HomeCollectionViewSection0Cell.h"
#import "HomeCollectionViewSection1Cell.h"
#import "HomeCollectionViewSection2Cell.h"
#import "SensorData.h"
#import "DataManager.h"
#import "Theme.h"

@interface HomeViewController ()
<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableArray *realtimeData;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self populateRealTimeData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataManagerDidUpdateDataNotification:)
                                                 name:@"DataManagerDidUpdateDataNotification"
                                               object:[DataManager manager]];
    
    for (NSUInteger i = 0; i < 3; i++)
    {
        NSString *cellName = [NSString stringWithFormat:@"HomeCollectionViewSection%luCell", (unsigned long)i];
        [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]]
              forCellWithReuseIdentifier:cellName];
    }
    [self.collectionView registerNib:[UINib nibWithNibName:@"HomeCollectionHeaderView"
                                                    bundle:[NSBundle mainBundle]]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:@"HomeCollectionHeaderView"];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
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



#pragma mark - Notification handler

- (void) handleDataManagerDidUpdateDataNotification:(NSNotification*)notification
{
    [self populateRealTimeData];
}




#pragma mark - Private utility

- (void) populateRealTimeData
{
    DataManager *dataManager = [DataManager manager];
    if ( dataManager.realtimeData != nil )
    {
        [dataManager.realtimeData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *data = (NSDictionary*)obj;
            [self.realtimeData replaceObjectAtIndex:idx withObject:data[@"value"]];
        }];
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numItems = 0;
    
    switch (section) {
        case 0:
            numItems = self.realtimeData.count;
            break;
            
        case 1:
            numItems = 3;
            break;
            
        case 2:
            numItems = 1;
            break;
            
        default:
            break;
    }
    return numItems;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionHeaderView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader && indexPath.section == 0) {
        
        reusableview =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:@"HomeCollectionHeaderView"
                                                  forIndexPath:indexPath];
        NSUInteger days = ([[NSDate date] timeIntervalSince1970] - [[DataManager manager] birthday])/(24*60*60);
        reusableview.dayLabel.text = [NSString stringWithFormat:@"%@ %@", @(days), @"days ago"];
    }
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section, row = indexPath.row;
    NSString *cellID = [NSString stringWithFormat:@"HomeCollectionViewSection%luCell", (unsigned long)section];
    id cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID
                                                             forIndexPath:indexPath];
    
    switch (section) {
        case 0:
        {
            ((HomeCollectionViewSection0Cell*)cell).borderImageView.image =
            [UIImage imageNamed:[SensorData borderImageNameForDataType:row]];
            
            ((HomeCollectionViewSection0Cell*)cell).iconImageView.image =
            [UIImage imageNamed:[SensorData iconImageNameForDataType:row]];
            
            ((HomeCollectionViewSection0Cell*)cell).titleLabel.text =
            [[SensorData titleForDataType:row] uppercaseString];
            
            NSString *data = [self.realtimeData[row] stringValue], *unit = [SensorData unitForDataType:row];
            
            NSMutableAttributedString *attributedString =
            [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", data, unit]
                                                   attributes:@{
                                                                NSFontAttributeName:((HomeCollectionViewSection0Cell*)cell).dataLabel.font,
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
            
            ((HomeCollectionViewSection0Cell*)cell).dataLabel.attributedText = attributedString;
        }
            break;
            
        case 1:
        {
            NSDictionary *menuItem = [self.menuItems objectAtIndex:row];
            ((HomeCollectionViewSection1Cell*)cell).iconImageView.image = [UIImage imageNamed:menuItem[@"image"]];
            ((HomeCollectionViewSection1Cell*)cell).titleLabel.text = menuItem[@"title"];
        }
            
        default:
            break;
    }
    return cell;
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            StatsViewController *statsVC = [[StatsViewController alloc] initWithDataType:indexPath.row];
            [self.navigationController pushViewController:statsVC animated:YES];
        }
            break;
            
        case 1:
        {
            NSDictionary *menuItem = [self.menuItems objectAtIndex:indexPath.row];
            NSString *className = menuItem[@"class"];
            
            if (![className length])
            {
                return;
            }
            
            Class controllerClass = NSClassFromString(className);
            
            id viewController;
            
            if (!controllerClass || ![controllerClass isSubclassOfClass:[UIViewController class]])
            {
                return;
            }
            else
            {
                viewController = [[controllerClass alloc] init];
            }
            
            if (viewController)
            {
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
            
        default:
            break;
    }
    
}



#pragma mark - Property accessor methods

- (NSArray*) menuItems {
    
    if (_menuItems== nil) {
        
        _menuItems = @[@{
                           @"class"  : @"RemindViewController",
                           @"image"  : @"remind_image",
                           @"title"  : @"Remind"
                           },
                       @{
                           @"class"  : @"DiaryListViewController",
                           @"image"  : @"diary_image",
                           @"title"  : @"Diary"
                           },
                       @{
                           @"class"  : @"ComingSoonViewController",
                           @"image"  : @"guide_image",
                           @"title"  : @"Guide",
                           }
                       ];
    }
    return _menuItems;
}

- (NSMutableArray*) realtimeData
{
    if (_realtimeData == nil)
    {
        _realtimeData = [NSMutableArray arrayWithArray:@[@(0), @(0), @(0), @(0), @(0), @(0), @(0)]];
    }
    return _realtimeData;
}

@end
