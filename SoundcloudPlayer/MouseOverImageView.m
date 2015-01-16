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
#import "LoadSpeakerOverlayView.h"

@interface MouseOverImageView ()

@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic) BOOL mouseOver;
@property (nonatomic, strong) PlayPauseOverlayView *playPauseOverlayView;
@property (nonatomic, strong) LoadSpeakerOverlayView *loadSpeakerOverlayView;

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

- (void)setObjectToPlay:(NSDictionary *)objectToPlay {
    _objectToPlay = objectToPlay;
    [self.playPauseOverlayView setObjectToShow:objectToPlay];
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self.loadSpeakerOverlayView setHidden:!playing];
}

- (void)commonInit {
    self.playPauseOverlayView = [[PlayPauseOverlayView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.playPauseOverlayView setHidden:YES];
    [self.playPauseOverlayView setRow:self.row];
    [self addSubview:self.playPauseOverlayView];

    self.loadSpeakerOverlayView = [[LoadSpeakerOverlayView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.loadSpeakerOverlayView setHidden:YES];
    [self addSubview:self.loadSpeakerOverlayView];
    

    
    [self setWantsLayer: YES];
    self.layer.cornerRadius = 2.0;
    self.layer.masksToBounds = YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
}

- (void)setShowLargePlayPauseView:(BOOL)showLargePlayPauseView {
    _showLargePlayPauseView = showLargePlayPauseView;
    [self.playPauseOverlayView setShowLargeIcons:showLargePlayPauseView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


# pragma mark - Mouse Handling

- (void)cursorEntered {
    self.mouseOver = YES;
    [self.playPauseOverlayView setHidden:NO];
    [self.loadSpeakerOverlayView setHidden:YES];
    [self.playPauseOverlayView setNeedsDisplay:YES];
}

- (void)cursorExited {
    self.mouseOver = NO;
    [self.playPauseOverlayView setHidden:YES];
    [self setPlaying:_playing];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.objectToPlay == [[SharedAudioPlayer sharedPlayer] currentItem])
        [[SharedAudioPlayer sharedPlayer] togglePlayPause];
    else if ([[[SharedAudioPlayer sharedPlayer] streamItemsToShowInTableView]indexOfObject:[[[SharedAudioPlayer sharedPlayer]currentItem] playlistTrackIsFrom]] == self.row)
             [[SharedAudioPlayer sharedPlayer] togglePlayPause];
    else {
        if ([[SharedAudioPlayer sharedPlayer].streamItemsToShowInTableView containsObject:self.objectToPlay] && [SharedAudioPlayer sharedPlayer].sourceType != CurrentSourceTypeStream){
            [[SharedAudioPlayer sharedPlayer] switchToStream];
        } else if ([[SharedAudioPlayer sharedPlayer].favoriteItemsToShowInTableView containsObject:self.objectToPlay] && [SharedAudioPlayer sharedPlayer].sourceType != CurrentSourceTypeFavorites) {
            [[SharedAudioPlayer sharedPlayer] switchToFavorites];
        }
    
        NSInteger clickedRow = self.row;
        id clickedItem = self.objectToPlay;
        if ([SharedAudioPlayer sharedPlayer].sourceType == CurrentSourceTypeStream) {
            if ([clickedItem isKindOfClass:[SoundCloudPlaylist class]]){
                clickedItem = [[[SharedAudioPlayer sharedPlayer] streamItemsToShowInTableView] objectAtIndex:clickedRow+1];
            }
            
            NSInteger objectToPlay = [[[SharedAudioPlayer sharedPlayer] streamItemsToShowInTableView] indexOfObject:clickedItem];
            [[SharedAudioPlayer sharedPlayer] jumpToItemAtIndex:objectToPlay];
        } else if ([SharedAudioPlayer sharedPlayer].sourceType == CurrentSourceTypeFavorites) {
            if ([clickedItem isKindOfClass:[SoundCloudPlaylist class]]){
                clickedItem = [[[SharedAudioPlayer sharedPlayer] favoriteItemsToShowInTableView] objectAtIndex:clickedRow+1];
            }
            
            NSInteger objectToPlay = [[[SharedAudioPlayer sharedPlayer] favoriteItemsToShowInTableView] indexOfObject:clickedItem];
            [[SharedAudioPlayer sharedPlayer] jumpToItemAtIndex:objectToPlay];

        }
        [self.playPauseOverlayView setHidden:YES];
    }
    [self.playPauseOverlayView setNeedsDisplay:YES];
}


@end
