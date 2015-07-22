//
//  DiaryManager.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/19/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DiaryEntry.h"
#import "MediaCenter.h"

@interface DiaryManager : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
+ (instancetype) manager;
- (void) saveDiary:(NSDictionary*)diary;
- (void) updateDeletes;
- (NSData*) loadMediaOfType:(MCMediaType)type andName:(NSString*)name;
- (void) resetCoreData;
@end
