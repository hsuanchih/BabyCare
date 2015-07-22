//
//  DataManager.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/16/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "DataManager.h"
#import "UserDefaults.h"

@interface DataManager()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation DataManager

+ (instancetype) manager
{
    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[DataManager alloc] init];
    });
    return manager;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        [self initData];
    }
    return self;
}

- (void) initData
{
    [self.operationQueue addOperationWithBlock:^{
        
        NSDate *endOfToday = [[NSDate date] endOfDay];
        NSTimeInterval endTime = [endOfToday timeIntervalSince1970], startTime = endTime-6*24*60*60;
        
        NSMutableArray *realtimeData = [NSMutableArray array], *historicData = [NSMutableArray array];
        
        for ( NSUInteger i = 0; i < 7; i++ )
        {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
            
            for ( NSUInteger j = 0; j < 10; j++ )
            {
                NSTimeInterval timeStamp = startTime + arc4random_uniform(6*24*60*60);
                FPRange valueRange = [self rangeForDataType:i];
                CGFloat value = valueRange.location + arc4random_uniform(valueRange.length);
                [array addObject:@{@"time": @(timeStamp), @"value":@(value)}];
            }
            
            [array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]];
            [historicData addObject:array];
        }
        
        [historicData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [realtimeData addObject:historicData[idx][0]];
        }];
        
        self.realtimeData = [NSArray arrayWithArray:realtimeData];
        self.historicData = [NSArray arrayWithArray:historicData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataManagerDidUpdateDataNotification"
                                                            object:self];
        
    }];
}

- (FPRange) rangeForDataType:(NSUInteger)dataType {
    
    FPRange range;
    switch (dataType) {
        
        case 0:
            range = FPMakeRange(80, 150-80);
            break;
            
        case 1:
            range = FPMakeRange(35, 42-35);
            break;
            
        case 2:
            range = FPMakeRange(4.5, 8-4.5);
            break;
            
        case 3:
            range = FPMakeRange(50, 70-50);
            break;
            
        case 4:
            range = FPMakeRange(1, 4-1);
            break;
            
        case 5:
            range = FPMakeRange(3, 32-3);
            break;
            
        case 6:
            range = FPMakeRange(20, 90-20);
            break;
            
        default:
            range = FPMakeRange(0, 0);
            break;
    }
    return range;
}

- (NSOperationQueue*) operationQueue
{
    if (_operationQueue == nil)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"DataManagerOperationQueue";
        _operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _operationQueue;
}

- (NSTimeInterval) birthday
{
    NSNumber *birthday = [UserDefaults loadObjectWithKey:@"birthday"];
    if ( birthday == nil )
    {
        NSTimeInterval birthday = [[NSDate date] timeIntervalSince1970] - 15*24*60*60 + arc4random_uniform(15*24*60*60);
        [UserDefaults saveObject:@(birthday) key:@"birthday"];
        return birthday;
    }
    return [birthday doubleValue];
}

- (void) resetBirthday
{
    [UserDefaults saveObject:nil key:@"birthday"];
}

@end
