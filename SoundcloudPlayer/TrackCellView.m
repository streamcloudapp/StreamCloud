//
//  TrackCellView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "TrackCellView.h"
#import "StreamCloudStyles.h"

@interface TrackCellView ()

@property (nonatomic, strong) NSTrackingArea *trackingArea;

@property (nonatomic) BOOL mouseInside;
@property (nonatomic) BOOL markedAsPlaying;

@end

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

- (void)setMouseInside:(BOOL)mouseInside {
    _mouseInside = mouseInside;
    [self setNeedsDisplay:YES];
}

- (void)markAsPlaying:(BOOL)playing {
    if (playing){
        [self.playingIndicatiorView setHidden:NO];
        [self.playingIndicatiorView setNeedsDisplay:YES];
    } else {
        [self.playingIndicatiorView setHidden:YES];
    }
    [self.artworkView setPlaying:playing];
    [self setMarkedAsPlaying:playing];
}

- (void)setMarkedAsPlaying:(BOOL)markedAsPlaying {
    _markedAsPlaying = markedAsPlaying;
    [self setNeedsDisplay:YES];
}


# pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    
    if (_markedAsPlaying) {
        [[NSColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1] set];
    }
    else if (_mouseInside){
        [[NSColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1] set];
    } else {
        [[NSColor colorWithRed:1 green:1 blue:1 alpha:1] set];
    }
    
    NSRectFill(bounds);
    
}

# pragma mark - MouseDown

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint selfPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    if (CGRectContainsPoint(self.artistLabel.frame, selfPoint)) {
        [self.artistLabel mouseDown:theEvent];
    }
    if (CGRectContainsPoint(self.titleLabel.frame, selfPoint)) {
        [self.titleLabel mouseDown:theEvent];
    }
}

# pragma mark - Mouse Over Managment

- (void)ensureTrackingArea {
    if (_trackingArea == nil) {
        _trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self ensureTrackingArea];
    if (![[self trackingAreas] containsObject:_trackingArea]) {
        [self addTrackingArea:_trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if ([self.playingIndicatiorView isHidden]){
        [self setMouseInside:YES];
    }
    [self.artworkView mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if ([self.playingIndicatiorView isHidden]){
        [self setMouseInside:NO];
    }
    [self.artworkView mouseExited:theEvent];
}


@end
