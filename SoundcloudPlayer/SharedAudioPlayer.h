//
//  SharedAudioPlayer.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 21.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    RepeatModeNone,
    RepeatModeAll,
    RepeatModeTrack,
} RepeatMode;

@import AVFoundation;

@interface SharedAudioPlayer : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVQueuePlayer *audioPlayer;
@property (nonatomic, strong) NSMutableArray *itemsToPlay;
@property (nonatomic, strong) NSMutableArray *shuffledItemsToPlay;
@property (nonatomic) BOOL shuffleEnabled;
@property (nonatomic) NSInteger positionInPlaylist;
@property (nonatomic, strong) NSString *nextStreamPartURL;
@property (nonatomic) RepeatMode repeatMode;

+ (SharedAudioPlayer *)sharedPlayer;
- (void)insertItemsFromResponse:(NSDictionary *)response;
- (void)togglePlayPause;
- (void)previousItem;
- (void)nextItem;
- (void)jumpToItemAtIndex:(NSInteger)item;
- (void)advanceToTime:(CMTime)time;
- (NSDictionary *)currentItem;
- (void)getNextSongs;
- (void)toggleRepeatMode;
- (void)reset;
@end
