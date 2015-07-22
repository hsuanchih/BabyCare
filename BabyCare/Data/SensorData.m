//
//  SensorData.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/15/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "SensorData.h"

static NSString * const kItemBorder = @"kItemBorder";
static NSString * const kItemImage  = @"kItemImage";
static NSString * const kItemTitle  = @"kItemTitle";
static NSString * const kItemUnit   = @"kItemUnit";
static NSString * const kItemBack   = @"kItemBack";

@implementation SensorData

+ (NSString*) unitForDataType:(NSUInteger)type
{
    return NSLocalizedString([SensorData sensorDataMeta][type][kItemUnit], nil);
}

+ (NSString*) titleForDataType:(NSUInteger)type
{
    return NSLocalizedString([SensorData sensorDataMeta][type][kItemTitle], nil);
}

+ (NSString*) iconImageNameForDataType:(NSUInteger)type
{
    return [SensorData sensorDataMeta][type][kItemImage];
}

+ (NSString*) borderImageNameForDataType:(NSUInteger)type
{
    return [SensorData sensorDataMeta][type][kItemBorder];
}

+ (NSString*) backImageNameForDataType:(NSUInteger)type
{
    return [SensorData sensorDataMeta][type][kItemBack];
}

+ (NSArray*) sensorDataMeta
{
    static dispatch_once_t token;
    static NSArray *sensorDataMeta = nil;
    dispatch_once(&token, ^
    {
        sensorDataMeta = @[@{
                             kItemBorder : @"heartrate_border",
                             kItemImage  : @"heartrate_image",
                             kItemTitle  : @"Heart Rate",
                             kItemUnit   : @"t/min",
                             kItemBack   : @"heartrate_back"
                             },
                         @{
                             kItemBorder : @"bodytemp_border",
                             kItemImage  : @"bodytemp_image",
                             kItemTitle  : @"Body Temp",
                             kItemUnit   : @"°C",
                             kItemBack   : @"bodytemp_back"
                             },
                         @{
                             kItemBorder : @"weight_border",
                             kItemImage  : @"weight_image",
                             kItemTitle  : @"Weight",
                             kItemUnit   : @"kg",
                             kItemBack   : @"weight_back"
                             },
                         @{
                             kItemBorder : @"height_border",
                             kItemImage  : @"height_image",
                             kItemTitle  : @"Height",
                             kItemUnit   : @"cm",
                             kItemBack   : @"height_back"
                             },
                         @{
                             kItemBorder : @"airquality_border",
                             kItemImage  : @"airquality_image",
                             kItemTitle  : @"Air Quality",
                             kItemUnit   : @"",
                             kItemBack   : @"airquality_back"
                             },
                         @{
                             kItemBorder : @"roomtemp_border",
                             kItemImage  : @"roomtemp_image",
                             kItemTitle  : @"Room Temp",
                             kItemUnit   : @"°C",
                             kItemBack   : @"roomtemp_back"
                             },
                         @{
                             kItemBorder : @"humidity_border",
                             kItemImage  : @"humidity_image",
                             kItemTitle  : @"Humidity",
                             kItemUnit   : @"%",
                             kItemBack   : @"humidity_back"
                             }
                         ];
        
    });
    return sensorDataMeta;
}



// Theme color

+ (UIColor*) themeColorForDataType:(NSUInteger)type
{
    UIColor *themeColor;
    
    switch (type) {
            
        case 0:
            themeColor = [UIColor colorWithRed:(234/255.0) green:(107/255.0) blue:(111/255.0) alpha:1];
            break;
            
        case 1:
            themeColor = [UIColor colorWithRed:(124/255.0) green:(146/255.0) blue:(92/255.0) alpha:1];
            break;
            
        case 2:
            themeColor = [UIColor colorWithRed:(238/255.0) green:(165/255.0) blue:(99/255.0) alpha:1];
            break;
            
        case 3:
            themeColor = [UIColor colorWithRed:(136/255.0) green:(164/255.0) blue:(224/255.0) alpha:1];
            break;
            
        case 4:
            themeColor = [UIColor colorWithRed:(109/255.0) green:(192/255.0) blue:(160/255.0) alpha:1];
            break;
            
        case 5:
            themeColor = [UIColor colorWithRed:(96/255.0) green:(173/255.0) blue:(197/255.0) alpha:1];
            break;
            
        case 6:
            themeColor = [UIColor colorWithRed:(156/255.0) green:(116/255.0) blue:(203/255.0) alpha:1];
            break;
            
        default:
            themeColor = [UIColor grayColor];
            break;
    }
    return themeColor;
}



// Graph Type

+ (GraphType) graphTypeForDataType:(NSUInteger)type
{
    return (type == 4) ? GraphTypeNominal : GraphTypeNumeric;
}

+ (CGFloat) graphIntervalForDataType:(NSUInteger)type
{
    switch (type) {
            
        case 1:
            return 1.0;
            break;
            
        case 2:
            return 2.0;
            break;
            
        case 5:
            return 5.0;
            break;
            
        case 6:
        case 0:
        case 3:
            return 10.0;
            break;
            
        case 4:
        default:
            return 0;
            break;
    }
}

@end
