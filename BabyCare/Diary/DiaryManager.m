//
//  DiaryManager.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/19/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "DiaryManager.h"
#import "AppDelegate.h"

@interface DiaryManager()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation DiaryManager

+ (instancetype) manager
{
    static DiaryManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[DiaryManager alloc] init];
    });
    return manager;
}


- (void) saveDiary:(NSDictionary*)diary
{
    [self.operationQueue addOperationWithBlock:^{
        
        DiaryEntry *diaryEntry = [NSEntityDescription insertNewObjectForEntityForName:@"DiaryEntry"
                                                               inManagedObjectContext:self.managedObjectContext];
        NSDate *now = [NSDate date];
        diaryEntry.creationTime = now;
        diaryEntry.title = diary[@"title"];
        diaryEntry.content = diary[@"content"];
        diaryEntry.hasImage = diary[@"image"] == nil ? @(NO) : @(YES);
        
        if ( diary[@"image"] != nil )
        {
            diaryEntry.imageWidth = diary[@"imageWidth"];
            diaryEntry.imageHeight = diary[@"imageHeight"];
        }
        
        [self.managedObjectContext performBlock:^{
            
            NSError *error = nil;
            BOOL result = [self.managedObjectContext save:&error];
            if ( result )
            {
                [self saveMedia:diary[@"image"] ofType:MCMediaTypeImage forName:[@([now timeIntervalSince1970]) stringValue]];
                NSLog(@"save: %@", [@([now timeIntervalSince1970]) stringValue]);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DiaryManagerNotification"
                                                                object:self
                                                              userInfo:@{@"operation":@"save"}];
        }];
        
    }];
    
}

- (void) updateDeletes
{
    if ( [self.managedObjectContext hasChanges] )
    {
        if (self.managedObjectContext.deletedObjects && self.managedObjectContext.deletedObjects.count)
        {
            [self.operationQueue addOperationWithBlock:^{
                
                [self.managedObjectContext.deletedObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    DiaryEntry *diaryEntry = (DiaryEntry*)obj;
                    
                    [self deleteMediaOfType:MCMediaTypeImage forName:[@([diaryEntry.creationTime timeIntervalSince1970]) stringValue]];
                }];
                
                [self.managedObjectContext performBlock:^{
                    NSError *error = nil;
                    [self.managedObjectContext save:&error];
                }];
                
            }];
        }
        
    }
}

- (void) deleteDiaryEntry:(NSManagedObjectID*)diaryEntryID
{
    [self.managedObjectContext performBlock:^{

        DiaryEntry *diaryEntry = (DiaryEntry*)[self.managedObjectContext objectWithID:diaryEntryID];
        if ( diaryEntry != nil)
        {
            [self.managedObjectContext deleteObject:diaryEntry];
        }
        
    }];
}


#pragma mark - Media store

- (void) validateMediaStore
{
    [MediaCenter validateMediaStore];
}

- (void) saveMedia:(NSData*)media ofType:(MCMediaType)type forName:(NSString*)name
{
    [self.operationQueue addOperationWithBlock:^{
        
        [MediaCenter saveMedia:media ofType:type forName:name];
    }];
}

- (void) deleteMediaOfType:(MCMediaType)type forName:(NSString*)name
{
    [MediaCenter deleteMediaOfType:type forName:name];
}

- (NSData*) loadMediaOfType:(MCMediaType)type andName:(NSString*)name
{
    return [MediaCenter loadMediaOfType:type andName:name];
}


#pragma mark - Asynchronous data access

- (NSOperationQueue*) operationQueue
{
    if (_operationQueue == nil)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"DiaryManagerOperationQueue";
        _operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _operationQueue;
}



#pragma mark - CoreData execution context

- (NSManagedObjectContext*) managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (NSManagedObjectModel*) managedObjectModel
{
    if (_managedObjectModel == nil)
    {
        _managedObjectModel = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectModel;
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil)
    {
        _persistentStoreCoordinator = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator;
    }
    return _persistentStoreCoordinator;
}

- (void) resetCoreData
{
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) resetCoreDataStack];
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
}

@end
