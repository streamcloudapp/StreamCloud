//
//  TrackCellView.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MouseOverImageView.h"
#import "ClickableTextField.h"
@interface TrackCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet ClickableTextField *titleLabel;
@property (nonatomic, strong) IBOutlet MouseOverImageView *artworkView;
@property (nonatomic, strong) IBOutlet ClickableTextField *artistLabel;
@property (nonatomic, strong) IBOutlet NSTextField *durationLabel;
@property (nonatomic ,strong) IBOutlet NSButton *pausePlayButton;
@property (nonatomic, strong) IBOutlet NSView *playingIndicatiorView;
@property (nonatomic, strong) IBOutlet NSView *seperatorView;
@property (nonatomic) NSInteger row;
@property (nonatomic) BOOL mouseInside;

- (void)markAsPlaying:(BOOL)playing;
@end
