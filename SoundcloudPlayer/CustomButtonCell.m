//
//  CustomButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 23.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "CustomButtonCell.h"
#import "StreamCloudStyles.h"

@implementation CustomButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawPlayPauseButtonWithFrame:frame playing:NO];
}

@end
