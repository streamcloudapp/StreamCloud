//
//  SoundCloudTrack.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "SoundCloudTrack.h"
#import "SoundCloudUser.h"
#define CLIENT_ID @"909c2edcdbd7b312b48a04a3f1e6b40c"

@interface SoundCloudTrack ()

@property (nonatomic, readwrite) AVPlayerItem *playerItem;

@end

@implementation SoundCloudTrack

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self){
        if ([[dict objectForKey:@"artwork_url"] isKindOfClass:[NSString class]])
            self.artworkUrl = [NSURL URLWithString:[dict objectForKey:@"artwork_url"]];
        self.commentCount = [dict objectForKey:@"comment_count"];
        self.createdAt = [NSDate date];
        self.descriptionText = [dict objectForKey:@"description"];
        self.downloadCount = [dict objectForKey:@"download_count"];
        if ([[dict objectForKey:@"download_url"] isKindOfClass:[NSString class]])
            self.downloadUrl = [NSURL URLWithString:[dict objectForKey:@"download_url"]];
        self.downloadable = [[dict objectForKey:@"downloadable"] boolValue];
        self.duration = [[dict objectForKey:@"duration"] doubleValue]/1000;
        self.genre = [dict objectForKey:@"genre"];
        self.labelName = [dict objectForKey:@"label_name"];
        self.lastModified = [NSDate date];
        self.license = [dict objectForKey:@"license"];
        self.likesCount = [dict objectForKey:@"likes_count"];
        if ([[dict objectForKey:@"permalink_url"] isKindOfClass:[NSString class]])
            self.permalinkUrl = [NSURL URLWithString:[dict objectForKey:@"permalink_url"]];
        self.playbackCount = [dict objectForKey:@"playback_count"];
        self.repostsCount = [dict objectForKey:@"reposts_count"];
        if ([[dict objectForKey:@"stream_url"] isKindOfClass:[NSString class]])
            self.streamingUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&allow_redirects=False",[dict objectForKey:@"stream_url"],CLIENT_ID]];
        self.streamable = [[dict objectForKey:@"streamable"] boolValue];
        self.tagList = [dict objectForKey:@"tag_list"];
        if ([dict objectForKey:@"title"])
            self.title = [dict objectForKey:@"title"];
        else
            self.title = @"";
        self.updatedAt = [NSDate date];
        if ([[dict objectForKey:@"uri"] isKindOfClass:[NSString class]])
            self.uri = [NSURL URLWithString:[dict objectForKey:@"uri"]];
        self.user = [SoundCloudUser userForDict:[dict objectForKey:@"user"]];
        if ([[dict objectForKey:@"waveform_url"] isKindOfClass:[NSString class]])
            self.waveformUrl = [NSURL URLWithString:[dict objectForKey:@"waveform_url"]];
        if (self.streamable)
            self.playerItem = [AVPlayerItem playerItemWithURL:self.streamingUrl];
    }
    return self;
}

+ (SoundCloudTrack *)trackForDict:(NSDictionary *)dict withPlaylist:(SoundCloudPlaylist *)playlist repostedBy:(SoundCloudUser *)repostedBy {
    SoundCloudTrack *trackToReturn = [[SoundCloudTrack alloc]initWithDict:dict];
    trackToReturn.playlistTrackIsFrom = playlist;
    trackToReturn.repostedBy = repostedBy;
    return trackToReturn;
}


@end
