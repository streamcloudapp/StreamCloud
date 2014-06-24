//
//  PlayingIndicatorView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "PlayingIndicatorView.h"
#import "StreamCloudStyles.h"
@implementation PlayingIndicatorView

- (void)drawRect:(NSRect)dirtyRect {
    [StreamCloudStyles drawPlayingIndicatorWithFrame:dirtyRect];
}

@end
