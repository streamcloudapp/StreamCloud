//
//  ProgressIndicatorView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ProgressIndicatorView.h"
#import "StreamCloudStyles.h"
#import "SharedAudioPlayer.h"

@implementation ProgressIndicatorView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress) name:@"SharedAudioPlayerUpdatedTimePlayed" object:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [StreamCloudStyles drawProgressIndicatorViewWithPercentShown:floorf(self.progress)];
}

- (void)updateProgress {
    float timeGone = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentTime);
    float durationOfItem = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentItem.duration);
    //float timeToGo = durationOfItem - timeGone;
    float progress = (timeGone/durationOfItem)*100;
    if (!isnan(progress)){
        self.progress = progress;
        [self setNeedsDisplay:YES];
    }
}

@end
