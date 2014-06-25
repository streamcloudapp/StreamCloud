//
//  ShuffleButtonCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ShuffleButtonCell.h"
#import "StreamCloudStyles.h"
#import "SharedAudioPlayer.h"

@interface ShuffleButtonCell ()

@property (nonatomic) BOOL shuffeling;

@end

@implementation ShuffleButtonCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shuffleStarted) name:@"SharedAudioPlayShuffleStarted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shuffleEnded) name:@"SharedAudioPlayShuffleEnded" object:nil];
    }
    return self;
}
- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    [StreamCloudStyles drawShuffleButtonWithFrame:frame active:[SharedAudioPlayer sharedPlayer].shuffleEnabled];
}

- (void)shuffleStarted {
    self.shuffeling = YES;
    [self setEnabled:NO];
    [self setEnabled:YES];
}

- (void)shuffleEnded {
    self.shuffeling = NO;
    [self setEnabled:NO];
    [self setEnabled:YES];
}
@end
