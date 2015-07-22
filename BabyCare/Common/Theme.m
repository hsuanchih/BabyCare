//
//  Theme.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/14/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "Theme.h"

@implementation Theme
+ (UIFont *)fontOfSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)boldFontOfSize:(CGFloat)size
{
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)unitFont
{
    return [UIFont systemFontOfSize:8.0f];
}

+ (UIColor *)textColor
{
    return [UIColor colorWithRed:(55/255.0) green:(55/255.0) blue:(55/255.0) alpha:1.0];
}

+ (UIColor *)colorWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(136/255.0) green:(172/255.0) blue:(83/255.0) alpha:alpha];
}

+ (UIColor *)backgroundColorWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(251/255.0) green:(251/255.0) blue:(251/255.0) alpha:alpha];
}

+ (UIColor *)borderColorWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:alpha];
}
@end
