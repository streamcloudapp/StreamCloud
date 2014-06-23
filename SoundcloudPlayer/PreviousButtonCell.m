//
//  PreviousButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 23.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "PreviousButtonCell.h"
#import "StreamCloudStyles.h"

@implementation PreviousButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawPreviousButtonWithFrame:frame];
}

@end
