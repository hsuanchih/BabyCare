//
//  DiaryEntry.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/20/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiaryEntry : NSManagedObject

@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber *hasImage;
@property (nonatomic, retain) NSNumber *imageWidth;
@property (nonatomic, retain) NSNumber *imageHeight;

@end
