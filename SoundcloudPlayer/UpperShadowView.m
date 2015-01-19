//
//  UpperShadowView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 19.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "UpperShadowView.h"
#import "StreamCloudStyles.h"

@implementation UpperShadowView

- (void)drawRect:(NSRect)dirtyRect {
    [StreamCloudStyles drawPlaylistUpperShadowOverlayWithFrame:dirtyRect];
}

@end
