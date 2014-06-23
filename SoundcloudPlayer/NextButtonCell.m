//
//  NextButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 23.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "NextButtonCell.h"
#import "StreamCloudStyles.h"
@implementation NextButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawNextButtonWithFrame:frame];
}

@end
