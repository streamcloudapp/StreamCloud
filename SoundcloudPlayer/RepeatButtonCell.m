//
//  RepeatButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "RepeatButtonCell.h"
#import "StreamCloudStyles.h"
#import "SharedAudioPlayer.h"

@implementation RepeatButtonCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repeatModeChanged) name:@"SharedAudioPlayerChangedRepeatMode" object:nil];
    }
    return self;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    RepeatMode repeatMode = [[SharedAudioPlayer sharedPlayer] repeatMode];
    switch (repeatMode) {
        case RepeatModeNone:
            [StreamCloudStyles drawRepeatButtonWithFrame:frame active:NO];
            break;
        case RepeatModeAll:
            [StreamCloudStyles drawRepeatButtonWithFrame:frame active:YES];
            break;
        case RepeatModeTrack:
            [StreamCloudStyles drawRepeatButtonWithFrame:frame active:YES];
            break;
    }
}

- (void)repeatModeChanged {
    [self setEnabled:NO];
    [self setEnabled:YES];
}

@end
