//
//  SharedAudioPlayer.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 21.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "SharedAudioPlayer.h"

#define CLIENT_ID @"909c2edcdbd7b312b48a04a3f1e6b40c"

@interface SharedAudioPlayer ()

@property (nonatomic, strong) AVQueuePlayer *audioPlayer;

@end

@implementation SharedAudioPlayer

- (id)init {
    self = [super init];
    if (self){
        
    }
    return self;
}

+ (SharedAudioPlayer *)sharedPlayer {
    static dispatch_once_t once;
    static SharedAudioPlayer* sharedPlayer;
    dispatch_once(&once, ^{
        sharedPlayer = [[self alloc] init];
    });
    return sharedPlayer;
}

- (void)togglePlayPause {
    if ([_audioPlayer rate] != 0.0) {
        [self.audioPlayer pause];
    } else {
        [self.audioPlayer play];
    }
}

- (void)nextItem {
    [self.audioPlayer advanceToNextItem];
}

- (void)previousItem {
    
}

- (void)insertItemsFromResponse:(NSDictionary *)response {
    NSArray *collectionItems = [response objectForKey:@"collection"];
    if (!_audioPlayer){
        NSMutableArray *itemsToPlay = [NSMutableArray array];
        for (NSDictionary *dict in collectionItems){
            [itemsToPlay addObject:[self itemForDict:dict]];
        }
        self.audioPlayer = [AVQueuePlayer queuePlayerWithItems:itemsToPlay];
        [self.audioPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    } else {
        for (NSDictionary *dict in collectionItems){
            [self.audioPlayer insertItem:[self itemForDict:dict] afterItem:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([self.audioPlayer rate]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayerIsPlaying" object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayerIsPausing" object:nil];
        }
    }
}

- (AVPlayerItem *)itemForDict:(NSDictionary *)dict {
    if ([dict[@"type"] isEqualToString:@"track"] && [dict[@"origin"][@"streamable"] boolValue]) {
        NSDictionary *originDict = dict[@"origin"];
        NSString *streamURLString = originDict[@"stream_url"];
        streamURLString = [streamURLString stringByAppendingString:[NSString stringWithFormat:@"?client_id=%@&allow_redirects=False",CLIENT_ID]];
        NSURL *streamURL = [NSURL URLWithString:streamURLString];
        AVURLAsset *assetForURL = [AVURLAsset assetWithURL:streamURL];
        AVPlayerItem *itemToReturn = [AVPlayerItem playerItemWithAsset:assetForURL];
        return itemToReturn;
    }
    return nil;
}
@end
