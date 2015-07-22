//
//  IBView.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 2/26/15.
//  Copyright (c) 2015 Qiwo SmartLink Technology Ltd. All rights reserved.
//

#import "IBView.h"

@interface IBView()
@property (nonatomic, strong) IBOutlet UIView *view;
@end

@implementation IBView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupViewFromNib];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupViewFromNib];
    }
    return self;
}

- (void) setupViewFromNib
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    self.bounds = self.view.bounds;
    [self addSubview:self.view];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
