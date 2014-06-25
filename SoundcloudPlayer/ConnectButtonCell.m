//
//  ConnectButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 25.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ConnectButtonCell.h"
#import "StreamCloudStyles.h"
@implementation ConnectButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawLoginButtonWithFrame:frame];
}

@end
