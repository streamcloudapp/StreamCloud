//
//  LowerShadowView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 19.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "LowerShadowView.h"
#import "StreamCloudStyles.h"
@implementation LowerShadowView

- (void)drawRect:(NSRect)dirtyRect {
    [StreamCloudStyles drawPlaylistLowerShadowOverlayWithFrame:dirtyRect];
}

@end
