//
//  MouseOverImageView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 26.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "MouseOverImageView.h"
#import "PlayPauseOverlayView.h"
#import "SharedAudioPlayer.h"

@interface MouseOverImageView ()

@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic) BOOL mouseOver;
@property (nonatomic, strong) PlayPauseOverlayView *playPauseOverlayView;

@end

@implementation MouseOverImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self commonInit];
    }
    return self;
}

- (void)setRow:(NSInteger)row {
    _row = row;
    [self.playPauseOverlayView setRow:row];
}

- (void)commonInit {
    self.playPauseOverlayView = [[PlayPauseOverlayView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.playPauseOverlayView setHidden:YES];
    [self.playPauseOverlayView setRow:self.row];
    [self addSubview:self.playPauseOverlayView];
    [self setWantsLayer: YES];  // edit: enable the layer for the view.  Thanks omz
    
    self.layer.cornerRadius = 2.0;
    self.layer.masksToBounds = YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
}

- (void)mouseEntered:(NSEvent *)theEvent {
    self.mouseOver = YES;
    [self.playPauseOverlayView setHidden:NO];
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.mouseOver = NO;
    [self.playPauseOverlayView setHidden:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.row == [[[SharedAudioPlayer sharedPlayer] itemsToShowInTableView] indexOfObject:[[SharedAudioPlayer sharedPlayer] currentItem]])
        [[SharedAudioPlayer sharedPlayer] togglePlayPause];
    else {
        NSInteger clickedRow = self.row;
        NSDictionary *clickedDict = [[[SharedAudioPlayer sharedPlayer] itemsToShowInTableView] objectAtIndex:clickedRow];
        if ([[clickedDict objectForKey:@"type"] isEqualToString:@"playlist"]){
            clickedDict = [[[SharedAudioPlayer sharedPlayer] itemsToShowInTableView] objectAtIndex:clickedRow+1];
        }
        
        NSInteger objectToPlay = [[[SharedAudioPlayer sharedPlayer] itemsToPlay] indexOfObject:clickedDict];
        [[SharedAudioPlayer sharedPlayer] jumpToItemAtIndex:objectToPlay];
    }
    [self.playPauseOverlayView setNeedsDisplay:YES];
}

-(void)updateTrackingAreas
{
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

@end
