//
//  RepeatButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "RepeatButtonCell.h"
#import "StreamCloudStyles.h"

@implementation RepeatButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawRepeatButtonWithFrame:frame active:NO];
}

@end
