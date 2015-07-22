//
//  MediaCenter.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/20/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "MediaCenter.h"

@implementation MediaCenter

+ (NSArray*) mediaTypes
{
    return @[@"Image", @"Video", @"Audio"];
}

+ (NSString*) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString*) mediaDirectoryForType:(MCMediaType)type
{
    if (type >= MCMediaTypeImage && type <= MCMediaTypeAudio)
    {
        NSString
        *documentsDirectory = [MediaCenter documentsDirectory],
        *mediaType = [[MediaCenter mediaTypes] objectAtIndex:type];
        return [documentsDirectory stringByAppendingPathComponent:mediaType];
    }
    return nil;
}

+ (void) validateMediaStore
{
    for (NSInteger mediaType = MCMediaTypeImage; mediaType <= MCMediaTypeAudio; mediaType++)
    {
        NSString *mediaDirectory = [MediaCenter mediaDirectoryForType:mediaType];
        if (mediaDirectory != nil)
        {
            NSError * error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:mediaDirectory
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            
            if (error != nil)
            {
                NSLog(@"error creating directory: %@", error);
            }
        }
    }
}

+ (void) invalidateMediaStore
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSInteger mediaType = MCMediaTypeImage; mediaType <= MCMediaTypeAudio; mediaType++)
    {
        NSString *mediaDirectory = [MediaCenter mediaDirectoryForType:mediaType];
        if (mediaDirectory != nil)
        {
            NSError * error = nil;
            NSArray *files = [fileManager contentsOfDirectoryAtPath:mediaDirectory
                                                              error:&error];
            if (error == nil)
            {
                for( NSString *file in files )
                {
                    [fileManager removeItemAtPath:[mediaDirectory stringByAppendingPathComponent:file]
                                            error:&error];
                    if( error != nil )
                    {
                        NSString *urlString = [(NSURL*)file absoluteString];
                        NSLog(@"MediaCenter invalidateMediaStore with delete file at path %@/%@ failed: %@",
                              mediaDirectory,
                              (urlString == nil) ? @" ":urlString,
                              error);
                    }
                }
            }
            else
            {
                NSLog(@"MediaCenter invalidateMediaStore with mediaType failed: %@", error);
                break;
            }
        }
    }
}

+ (void) saveMedia:(NSData*)media ofType:(MCMediaType)type forName:(NSString*)name
{
    if (media != nil)
    {
        NSString *mediaDirectory = [MediaCenter mediaDirectoryForType:type];
        
        if (mediaDirectory != nil)
        {
            NSString *file = [mediaDirectory stringByAppendingPathComponent:name];
            [media writeToFile:file atomically:YES];
        }
    }
}

+ (void) deleteMediaOfType:(MCMediaType)type forName:(NSString*)name
{
    NSString *mediaDirectory = [MediaCenter mediaDirectoryForType:type];
    
    if (mediaDirectory != nil)
    {
        NSString *file = [mediaDirectory stringByAppendingPathComponent:name];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ( [fileManager fileExistsAtPath:file] )
        {
            NSError * error = nil;
            [fileManager removeItemAtPath:file
                                    error:&error];
            if (error != nil)
            {
                NSLog(@"MediaCenter deleteMedia:%@ failed:%@", file, error);
            }
        }
    }
}

+ (NSData*) loadMediaOfType:(MCMediaType)type andName:(NSString*)name
{
    NSString *mediaDirectory = [MediaCenter mediaDirectoryForType:type];
    
    if (mediaDirectory != nil)
    {
        NSString *file = [mediaDirectory stringByAppendingPathComponent:name];
        if ( [[NSFileManager defaultManager] fileExistsAtPath:file] )
        {
            return [NSData dataWithContentsOfFile:file];
        }
    }
    return nil;
}

@end
