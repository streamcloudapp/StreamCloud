//
//  LoadSpeakerOverlayView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 04.08.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "LoadSpeakerOverlayView.h"
#import "StreamCloudStyles.h"
@implementation LoadSpeakerOverlayView

- (void)setShowLargeIcon:(BOOL)showLargeIcon {
    _showLargeIcon = showLargeIcon;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [StreamCloudStyles drawPlayingOverlayWithFrame:self.frame];
}
@end
