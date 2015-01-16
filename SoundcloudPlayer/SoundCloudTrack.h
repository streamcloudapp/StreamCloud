//
//  SoundCloudTrack.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;
@class SoundCloudPlaylist;
@class SoundCloudUser;

@interface SoundCloudTrack : NSObject

@property (nonatomic, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSURL *artworkUrl;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSNumber *downloadCount;
@property (nonatomic, strong) NSURL *downloadUrl;
@property (nonatomic) BOOL downloadable;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *labelName;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSString *license;
@property (nonatomic, strong) NSNumber *likesCount;
@property (nonatomic, strong) NSURL *permalinkUrl;
@property (nonatomic, strong) NSNumber *playbackCount;
@property (nonatomic, strong) NSNumber *repostsCount;
@property (nonatomic, strong) NSURL *streamingUrl;
@property (nonatomic) BOOL streamable;
@property (nonatomic, strong) NSString *tagList;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSURL *uri;
@property (nonatomic, strong) SoundCloudUser *user;
@property (nonatomic ,strong) NSURL *waveformUrl;

@property (nonatomic, strong) SoundCloudPlaylist *playlistTrackIsFrom;

+ (SoundCloudTrack *)trackForDict:(NSDictionary *)dict withPlaylist:(SoundCloudPlaylist *)playlist;

@end
