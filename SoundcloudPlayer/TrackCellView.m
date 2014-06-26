//
//  TrackCellView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "TrackCellView.h"
#import "StreamCloudStyles.h"

@implementation TrackCellView

- (void)awakeFromNib {
    [self.artistLabel setTextColor:[StreamCloudStyles artistLabelColor]];
    [self markAsPlaying:NO];
    [self.durationLabel setTextColor:[StreamCloudStyles durationLabelColor]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseOverImage:) name:@"MouseOverImageEntered" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mouseOutImage:) name:@"MouseOverImageExited" object:nil];
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

- (void)mouseOverImage:(NSNotification *)notification {
    NSImageView *notificaitonView = [notification object];
    if (notificaitonView == self.artworkView){
        NSLog(@"I was hovered");
    }
}

- (void)mouseOutImage:(NSNotification *)notification {
    NSImageView *notificaitonView = [notification object];
    if (notificaitonView == self.artworkView){
        NSLog(@"I was exited");
    }
}

@end
