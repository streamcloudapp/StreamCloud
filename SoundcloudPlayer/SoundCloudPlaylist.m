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
#import <SoundCloudAPI/SCAPI.h>

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
        self.identifier = [dict objectForKey:@"id"];
        self.user = [SoundCloudUser userForDict:[dict objectForKey:@"user"]];
    }
    return self;
}

+ (SoundCloudPlaylist *)playlistForDict:(NSDictionary *)dict repostedBy:(SoundCloudUser *)repostedBy {
    SoundCloudPlaylist *playlistToReturn = [[SoundCloudPlaylist alloc]initWithDict:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudPlaylistTracksWillLoad" object:playlistToReturn];
    [playlistToReturn loadTracksForPlaylist];
    if (repostedBy)
        playlistToReturn.repostBy = repostedBy;
    return playlistToReturn;
}

- (void)loadTracksForPlaylist {
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/playlists/%@",self.identifier]]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                 } else {
                     NSLog(@"Got data, yeah");
                     NSError *error;
                     id objectFromData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                     if (!error){
                         if ([objectFromData isKindOfClass:[NSDictionary class]]){
                             if ([objectFromData objectForKey:@"tracks"]){
                                 NSMutableArray *tracksCache = [NSMutableArray array];
                                 for (NSDictionary *track in [objectFromData objectForKey:@"tracks"]) {
                                     [tracksCache addObject:[SoundCloudTrack trackForDict:track withPlaylist:self repostedBy:nil]];
                                 }
                                 self.tracks = [NSArray arrayWithArray:tracksCache];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudPlaylistTracksLoaded" object:self];
                             }
                         }
                     } else {
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudPlaylistFailedToLoadTracks" object:self];
                     }
                 }
             }];
}
@end
