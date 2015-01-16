//
//  SoundCloudPlaylist.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "SoundCloudPlaylist.h"
#import "SoundCloudUser.h"
#import "SoundCloudTrack.h"

@implementation SoundCloudPlaylist

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self){
        if ([[dict objectForKey:@"artwork_url"] isKindOfClass:[NSString class]])
            self.artworkUrl = [NSURL URLWithString:[dict objectForKey:@"artwork_url"]];
        self.createdAt = [NSDate date];
        self.descriptionText = [dict objectForKey:@"description"];
        self.duration = [[dict objectForKey:@"duration"] doubleValue]/1000;
        self.genre = [dict objectForKey:@"genre"];
        self.lastModified = [NSDate date];
        self.license = [dict objectForKey:@"license"];
        self.likesCount = [dict objectForKey:@"likes_count"];
        if ([[dict objectForKey:@"permalink_url"] isKindOfClass:[NSString class]])
            self.permalinkUrl = [NSURL URLWithString:[dict objectForKey:@"permalink_url"]];
        self.repostsCount = [dict objectForKey:@"reposts_count"];
        self.streamable = [[dict objectForKey:@"streamable"] boolValue];
        self.tagList = [dict objectForKey:@"tag_list"];
        self.title = [dict objectForKey:@"title"];
        self.trackCount = [dict objectForKey:@"track_count"];
        NSArray *trackArray = [dict objectForKey:@"tracks"];
        NSMutableArray *trackCacheArray = [NSMutableArray array];
        for (NSDictionary *trackDict in trackArray){
            [trackCacheArray addObject:[SoundCloudTrack trackForDict:trackDict withPlaylist:self]];
        }
        self.tracks = [NSArray arrayWithArray:trackCacheArray];
        self.user = [SoundCloudUser userForDict:[dict objectForKey:@"user"]];
    }
    return self;
}

+ (SoundCloudPlaylist *)playlistForDict:(NSDictionary *)dict {
    SoundCloudPlaylist *playlistToReturn = [[SoundCloudPlaylist alloc]initWithDict:dict];
    return playlistToReturn;
}
@end
