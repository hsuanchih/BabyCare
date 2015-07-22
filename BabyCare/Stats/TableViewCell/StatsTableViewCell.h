//
//  StatsTableViewCell.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/17/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *dataLabel;
@end
