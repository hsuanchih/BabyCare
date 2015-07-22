//
//  SensorData.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/15/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GraphType) {
    GraphTypeNumeric,
    GraphTypeNominal
};

@interface SensorData : NSObject
+ (NSString*) unitForDataType:(NSUInteger)type;
+ (NSString*) titleForDataType:(NSUInteger)type;
+ (NSString*) iconImageNameForDataType:(NSUInteger)type;
+ (NSString*) borderImageNameForDataType:(NSUInteger)type;
+ (NSString*) backImageNameForDataType:(NSUInteger)type;
+ (UIColor*) themeColorForDataType:(NSUInteger)type;
+ (GraphType) graphTypeForDataType:(NSUInteger)type;
+ (CGFloat) graphIntervalForDataType:(NSUInteger)type;
@end
