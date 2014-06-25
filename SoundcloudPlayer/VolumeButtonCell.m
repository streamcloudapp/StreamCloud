//
//  VolumeButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 25.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "VolumeButtonCell.h"
#import "StreamCloudStyles.h"
@implementation VolumeButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawVolumeSettingsWithFrame:frame];
}


@end
