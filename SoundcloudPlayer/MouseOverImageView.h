//
//  MouseOverImageView.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 26.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SoundCloudTrack.h"
#import "SoundCloudPlaylist.h"

@interface MouseOverImageView : NSImageView

@property (nonatomic) NSInteger row;
@property (nonatomic) id objectToPlay;
@property (nonatomic) BOOL showLargePlayPauseView;
@property (nonatomic) BOOL playing;

- (void)cursorEntered;
- (void)cursorExited;
- (void)loadArtworkImageWithURL:(NSURL *)artworkURL;
@end
