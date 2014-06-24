//
//  PlayingIndicatorView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "PlayingIndicatorView.h"
#import "StreamCloudStyles.h"
@implementation PlayingIndicatorView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [StreamCloudStyles drawPlayingIndicatorWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
}


@end
