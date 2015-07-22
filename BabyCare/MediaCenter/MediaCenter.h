//
//  MediaCenter.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/20/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MCMediaType)
{
    MCMediaTypeImage,
    MCMediaTypeVideo,
    MCMediaTypeAudio
};

@interface MediaCenter : NSObject
+ (void) validateMediaStore;
+ (void) invalidateMediaStore;
+ (void) saveMedia:(NSData*)media ofType:(MCMediaType)type forName:(NSString*)name;
+ (void) deleteMediaOfType:(MCMediaType)type forName:(NSString*)name;
+ (NSData*) loadMediaOfType:(MCMediaType)type andName:(NSString*)name;
@end
