//
//  TrackCellView.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TrackCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField *titleLabel;
@property (nonatomic, strong) IBOutlet NSImageView *artworkView;
@property (nonatomic, strong) IBOutlet NSTextField *artistLabel;
@property (nonatomic, strong) IBOutlet NSTextField *durationLabel;
@property (nonatomic ,strong) IBOutlet NSButton *pausePlayButton;
@property (nonatomic, strong) IBOutlet NSView *playingIndicatiorView;
@property (nonatomic, strong) IBOutlet NSView *seperatorView;

- (void)markAsPlaying:(BOOL)playing;
@end
