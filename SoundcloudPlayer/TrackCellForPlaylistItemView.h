//
//  TrackCellForPlaylistItemView.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 28.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MouseOverImageView.h"

@interface TrackCellForPlaylistItemView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField *titleLabel;
@property (nonatomic, strong) IBOutlet MouseOverImageView *artworkView;
@property (nonatomic, strong) IBOutlet NSTextField *artistLabel;
@property (nonatomic, strong) IBOutlet NSTextField *durationLabel;
@property (nonatomic ,strong) IBOutlet NSButton *pausePlayButton;
@property (nonatomic, strong) IBOutlet NSView *playingIndicatiorView;
@property (nonatomic, strong) IBOutlet NSView *seperatorView;
@property (nonatomic) NSInteger row;

- (void)markAsPlaying:(BOOL)playing;

@end
