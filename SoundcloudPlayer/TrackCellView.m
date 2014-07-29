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

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint selfPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    if (CGRectContainsPoint(self.artistLabel.frame, selfPoint)) {
        [self.artistLabel mouseDown:theEvent];
    }
    if (CGRectContainsPoint(self.titleLabel.frame, selfPoint)) {
        [self.titleLabel mouseDown:theEvent];
    }
}


@end
