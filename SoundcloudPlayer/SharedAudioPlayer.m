//
//  SharedAudioPlayer.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 21.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "SharedAudioPlayer.h"
#import <math.h>
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
    }
}

- (void)nextItem {
    [self.audioPlayer advanceToNextItem];
    [self itemDidFinishPlaying:nil];
}

- (void)previousItem {
    
}

- (void)advanceToTime:(CMTime)time {
    [self.audioPlayer seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"Finished %@",finished ? @"NO" : @"YES");
    }];
}

- (NSDictionary *)currentItem {
    return [self.itemsToPlay objectAtIndex:_positionInPlaylist];
}
- (void)insertItemsFromResponse:(NSDictionary *)response {
    NSArray *collectionItems = [response objectForKey:@"collection"];
    if (!_audioPlayer){
        NSMutableArray *itemsToPlay = [NSMutableArray array];
        for (NSDictionary *dict in collectionItems){
            [self.itemsToPlay addObject:dict];
            AVPlayerItem *itemToPlay = [self itemForDict:dict];
            [itemsToPlay addObject:itemToPlay];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:itemToPlay];
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
            [self.itemsToPlay addObject:dict];
            AVPlayerItem *itemToPlay = [self itemForDict:dict];
            [self.audioPlayer insertItem:itemToPlay afterItem:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:itemToPlay];

        }
    }
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
    self.positionInPlaylist++;
    if (self.positionInPlaylist == self.itemsToPlay.count-1) {
        //TODO: Get new items!
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
