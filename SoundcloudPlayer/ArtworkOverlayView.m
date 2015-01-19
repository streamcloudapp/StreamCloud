
//
//  ArtworkOverlayView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 19.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "ArtworkOverlayView.h"
#import "StreamCloudStyles.h"

@import QuartzCore;

@implementation ArtworkOverlayView

- (void)drawRect:(NSRect)dirtyRect {
    [[StreamCloudStyles orangeDark] setFill];
    NSRectFill(dirtyRect);
}

- (void)hideWithFadeOut {
    [[NSAnimationContext currentContext] setDuration:0.7];
    [self.animator setAlphaValue:0.0];

}

@end
