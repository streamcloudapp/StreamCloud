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
@end
