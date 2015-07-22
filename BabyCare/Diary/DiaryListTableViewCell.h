//
//  DiaryListTableViewCell.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/19/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiaryListTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *contentLabel;
@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;
@end
