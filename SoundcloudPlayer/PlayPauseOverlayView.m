//
//  PlayPauseOverlayView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 26.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "PlayPauseOverlayView.h"
#import "StreamCloudStyles.h"
#import "SharedAudioPlayer.h"
#import "SoundCloudPlaylist.h"
#import "SoundCloudTrack.h"

@implementation PlayPauseOverlayView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setShowLargeIcons:(BOOL)showLargeIcons {
    _showLargeIcons = showLargeIcons;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    BOOL playing = NO;
    if ([[SharedAudioPlayer sharedPlayer] currentItem] == self.objectToShow && [SharedAudioPlayer sharedPlayer].audioPlayer.rate) {
        playing = YES;
    } else if ([[[SharedAudioPlayer sharedPlayer] streamItemsToShowInTableView]indexOfObject:[[[SharedAudioPlayer sharedPlayer]currentItem] playlistTrackIsFrom]] == self.row && [SharedAudioPlayer sharedPlayer].audioPlayer.rate ) {
        playing = YES;
    }
    if (self.showLargeIcons){
        [StreamCloudStyles drawLargePlayPauseOverlayWithFrame:self.frame playing:playing];
    } else {
        [StreamCloudStyles drawPlayPauseOverlayWithFrame:self.frame playing:playing];
    }
}

@end
