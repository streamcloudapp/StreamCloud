//
//  TrackCellForPlaylistItemView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 28.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "TrackCellForPlaylistItemView.h"
#import "StreamCloudStyles.h"

@implementation TrackCellForPlaylistItemView

- (void)awakeFromNib {
    [self.artistLabel setTextColor:[StreamCloudStyles artistLabelColor]];
    [self markAsPlaying:NO];
    [self.durationLabel setTextColor:[StreamCloudStyles durationLabelColor]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        
    }
    return self;
}

- (void)setRow:(NSInteger)row {
    _row = row;
    [self.artworkView setRow:row];
}

- (void)markAsPlaying:(BOOL)playing {
    if (playing){
        [self.playingIndicatiorView setHidden:NO];
        [self.playingIndicatiorView setNeedsDisplay:YES];
    } else {
        [self.playingIndicatiorView setHidden:YES];
    }
}

@end
