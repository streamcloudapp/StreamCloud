//
//  SeperatorView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "SeperatorView.h"
#import "StreamCloudStyles.h"

@implementation SeperatorView

- (void)drawRect:(NSRect)dirtyRect {
    [StreamCloudStyles drawSeperatorViewWithFrame:dirtyRect];
}
@end
