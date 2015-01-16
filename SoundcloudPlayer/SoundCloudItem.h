//
//  SoundCloudItem.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SoundCloudItemTypeUnknown,
    SoundCloudItemTypeTrack,
    SoundCloudItemTypePlaylist,
    SoundCloudItemTypeTrackRepost,
    SoundCloudItemTypePlaylistRepost
} SoundCloudItemType;

@class SoundCloudUser;
@interface SoundCloudItem : NSObject

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic) SoundCloudItemType type;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic) id item;
@property (nonatomic, strong) SoundCloudUser *user;
@property (nonatomic, strong) NSURL *nextHref;

+ (NSArray *)soundCloudItemsFromResponse:(id)response;

@end
