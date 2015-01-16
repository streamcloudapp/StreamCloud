//
//  SoundCloudPlaylist.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  SoundCloudUser;
@interface SoundCloudPlaylist : NSObject

@property (nonatomic, strong) NSURL *artworkUrl;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSString *license;
@property (nonatomic, strong) NSNumber *likesCount;
@property (nonatomic, strong) NSURL *permalinkUrl;
@property (nonatomic, strong) NSNumber *repostsCount;
@property (nonatomic) BOOL streamable;
@property (nonatomic, strong) NSString *tagList;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *trackCount;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) SoundCloudUser *user;

+ (SoundCloudPlaylist *)playlistForDict:(NSDictionary *)dict;
@end
