//
//  CustomButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 23.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "PlayPauseButtonCell.h"
#import "StreamCloudStyles.h"

@implementation PlayPauseButtonCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markAsPlaying:) name:@"SharedAudioPlayerIsPlaying" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markAsPausing:) name:@"SharedAudioPlayerIsPausing" object:nil];
    }
    return self;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawPlayPauseButtonWithFrame:frame playing:_playing];
}

- (void)markAsPlaying:(NSNotification *)notification {
    [self setPlaying:YES];
}

- (void)markAsPausing:(NSNotification *)notification {
    [self setPlaying:NO];
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self setEnabled:YES];
}

@end
