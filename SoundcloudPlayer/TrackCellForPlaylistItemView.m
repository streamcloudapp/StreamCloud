//
//  TrackCellForPlaylistItemView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 28.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "TrackCellForPlaylistItemView.h"
#import "StreamCloudStyles.h"

@implementation TrackCellForPlaylistItemView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.artworkView setShowLargePlayPauseView:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    
    if (super.mouseInside){
        [[NSColor colorWithWhite:0.956 alpha:1.000]set];
    } else {
        [[NSColor colorWithWhite:0.956 alpha:1.000]set];
    }
    
    NSRectFill(bounds);
    
}

@end
