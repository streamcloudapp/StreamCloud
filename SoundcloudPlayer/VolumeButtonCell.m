//
//  VolumeButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 25.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "VolumeButtonCell.h"
#import "StreamCloudStyles.h"
#import "SharedAudioPlayer.h"
@implementation VolumeButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    float volumeToUse =[SharedAudioPlayer sharedPlayer].audioPlayer.volume*100;
    if ([SharedAudioPlayer sharedPlayer].audioPlayer){
        [StreamCloudStyles drawVolumeSettingsWithFrame:frame volumeToShow:volumeToUse];
    } else {
        [StreamCloudStyles drawVolumeSettingsWithFrame:frame volumeToShow:100];
    }
}


@end
