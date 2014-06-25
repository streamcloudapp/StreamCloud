//
//  SharedAudioPlayer.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 21.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "SharedAudioPlayer.h"
#import <math.h>
#import "SoundCloudAPIClient.h"
#define CLIENT_ID @"909c2edcdbd7b312b48a04a3f1e6b40c"

@interface SharedAudioPlayer ()

@property (nonatomic) id audioPlayerCallback;

@end

@implementation SharedAudioPlayer

- (id)init {
    self = [super init];
    if (self){
        self.itemsToPlay = [NSMutableArray array];
        self.positionInPlaylist = 0;
        [self setRepeatMode:RepeatModeNone];

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

# pragma mark - Public methods

- (void)togglePlayPause {
    if ([_audioPlayer rate] != 0.0) {
        [self.audioPlayer pause];
    } else {
        [self.audioPlayer play];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
    }
}

- (void)nextItem {
    if (self.shuffleEnabled) {
        [self jumpToItemAtIndex:[self.itemsToPlay indexOfObject:[self.shuffledItemsToPlay objectAtIndex:self.positionInPlaylist]]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
        if (self.positionInPlaylist == self.itemsToPlay.count-1) {
            [self getNextSongs];
        }
    } else {
        if (self.repeatMode == RepeatModeNone || self.repeatMode == RepeatModeAll)
            [self.audioPlayer advanceToNextItem];
        [self itemDidFinishPlaying:nil];
        
    }
}

- (void)previousItem {
    if (self.positionInPlaylist >= 1) {
        [self jumpToItemAtIndex:self.positionInPlaylist-1];
    }
}

- (void)jumpToItemAtIndex:(NSInteger)item {
    [self.audioPlayer pause];
    [self.audioPlayer removeAllItems];
    
    for (NSInteger i = item; i < self.itemsToPlay.count; i++){
        NSDictionary *itemInList = [self.itemsToPlay objectAtIndex:i];
        [self.audioPlayer insertItem:[self itemForDict:itemInList] afterItem:nil];
    }
    self.positionInPlaylist = item;
    [self.audioPlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
}

- (void)advanceToTime:(CMTime)time {
    [self.audioPlayer seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"Finished %@",finished ? @"NO" : @"YES");
    }];
}

- (NSDictionary *)currentItem {
    if (self.itemsToPlay.count)
        return [self.itemsToPlay objectAtIndex:_positionInPlaylist];
    else
        return nil;
}

- (void)toggleRepeatMode {
    switch (self.repeatMode) {
        case RepeatModeNone:
            [self setRepeatMode:RepeatModeTrack];
            break;
        case RepeatModeTrack:
            [self setRepeatMode:RepeatModeAll];
            break;
        case RepeatModeAll:
            [self setRepeatMode:RepeatModeNone];
    }
}
- (void)setShuffleEnabled:(BOOL)shuffleEnabled {
    _shuffleEnabled = shuffleEnabled;
    if (shuffleEnabled) {
        self.shuffledItemsToPlay = [NSMutableArray arrayWithArray:self.itemsToPlay];
        NSUInteger count = [self.shuffledItemsToPlay count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            NSUInteger nElements = count - i;
            NSUInteger n = (arc4random() % nElements) + i;
            [self.shuffledItemsToPlay exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayShuffleStarted" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayShuffleEnded" object:nil];
    }
}

- (void)setRepeatMode:(RepeatMode)repeatMode {
    _repeatMode = repeatMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayerChangedRepeatMode" object:nil];
}

- (void)reset {
    [self.audioPlayer pause];
    [self.audioPlayer removeAllItems];
    [self.itemsToPlay removeAllObjects];
    [self.shuffledItemsToPlay removeAllObjects];
    self.audioPlayer = nil;
    self.shuffledItemsToPlay = nil;
    self.itemsToPlay = nil;
    self.shuffledItemsToPlay = [NSMutableArray array];
    self.itemsToPlay = [NSMutableArray array];
}

# pragma mark - Inserting new items

- (void)insertItemsFromResponse:(NSDictionary *)response {
    NSArray *collectionItems = [response objectForKey:@"collection"];
    self.nextStreamPartURL = [response objectForKey:@"next_href"];
    if (!_audioPlayer){
        NSMutableArray *itemsToPlay = [NSMutableArray array];
        for (NSDictionary *dict in collectionItems){
            AVPlayerItem *itemToPlay = [self itemForDict:dict];
            if (itemToPlay){
                [self.itemsToPlay addObject:dict];
                [itemsToPlay addObject:itemToPlay];
            }
        }
        self.audioPlayer = [AVQueuePlayer queuePlayerWithItems:itemsToPlay];
        [self.audioPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        self.audioPlayerCallback = [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
            if (!isnan(CMTimeGetSeconds(time))) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedAudioPlayerUpdatedTimePlayed" object:[NSNumber numberWithFloat:CMTimeGetSeconds(time)]];
            }
        }];

        [self.audioPlayer setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    } else {
        for (NSDictionary *dict in collectionItems){
            AVPlayerItem *itemToPlay = [self itemForDict:dict];
            if (itemToPlay) {
                [self.itemsToPlay addObject:dict];
                [self.audioPlayer insertItem:itemToPlay afterItem:nil];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [self setShuffleEnabled:_shuffleEnabled];
}

# pragma mark - KVO

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

# pragma mark - NotificationHandling

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    switch (self.repeatMode) {
        case RepeatModeTrack: {
            [self jumpToItemAtIndex:self.positionInPlaylist];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            break;
        }
        case RepeatModeAll: {
            if (self.positionInPlaylist < self.itemsToPlay.count) {
                self.positionInPlaylist++;
            } else {
                [self jumpToItemAtIndex:0];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            if (self.positionInPlaylist == self.itemsToPlay.count-1) {
                [self getNextSongs];
            }
            break;
        }
        default: {
            if (self.shuffleEnabled){
                if (_positionInPlaylist <= self.itemsToPlay.count) {
                    self.positionInPlaylist = [self.itemsToPlay indexOfObject:[self.shuffledItemsToPlay objectAtIndex:_positionInPlaylist+1]];
                    [self jumpToItemAtIndex: _positionInPlaylist];
                }
            } else {
                self.positionInPlaylist++;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            if (self.positionInPlaylist == self.itemsToPlay.count-1) {
                [self getNextSongs];
            }
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
}

- (void)getNextSongs {
    if (self.nextStreamPartURL){
        [[SoundCloudAPIClient sharedClient] getStreamSongsWithURL:self.nextStreamPartURL];
    }
}


# pragma mark - Creating AVPlayerItems

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
