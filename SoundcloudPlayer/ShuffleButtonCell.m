//
//  ShuffleButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ShuffleButtonCell.h"
#import "StreamCloudStyles.h"

@implementation ShuffleButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawShuffleButtonWithFrame:frame active:NO];
}

@end
