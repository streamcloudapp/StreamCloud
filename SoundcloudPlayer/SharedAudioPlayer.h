//
//  SharedAudioPlayer.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 21.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundCloudItem.h"
#import "SoundCloudTrack.h"
#import "SoundCloudPlaylist.h"
#import "SoundCloudUser.h"

typedef enum : NSUInteger {
    RepeatModeNone,
    RepeatModeAll,
    RepeatModeTrack,
} RepeatMode;

typedef enum : NSUInteger {
    CurrentSourceTypeStream,
    CurrentSourceTypeFavorites,
} CurrentSourceType;

@import AVFoundation;

@interface SharedAudioPlayer : NSObject <AVAudioPlayerDelegate, NSUserNotificationCenterDelegate>

@property (nonatomic, strong) AVQueuePlayer *audioPlayer;
@property (nonatomic, strong) NSMutableArray *itemsToPlay;
@property (nonatomic, strong) NSMutableArray *streamItemsToShowInTableView;
@property (nonatomic, strong) NSMutableArray *favoriteItemsToShowInTableView;
@property (nonatomic, strong) NSMutableArray *shuffledItemsToPlay;
@property (nonatomic) BOOL shuffleEnabled;
@property (nonatomic) NSInteger positionInPlaylist;
@property (nonatomic, strong) NSURL *nextStreamPartURL;
@property (nonatomic) RepeatMode repeatMode;
@property (nonatomic) CurrentSourceType sourceType;
@property (nonatomic ,strong) NSMutableArray *scrobbledItems;

+ (SharedAudioPlayer *)sharedPlayer;
- (void)insertStreamItems:(NSArray *)items;
- (void)insertFavoriteItems:(NSArray *)items;
- (void)togglePlayPause;
- (void)previousItem;
- (void)nextItem;
- (void)jumpToItemAtIndex:(NSInteger)item;
- (void)advanceToTime:(float)timeToGo;
- (SoundCloudTrack *)currentItem;
- (void)getNextSongs;
- (void)toggleRepeatMode;
- (void)reset;
- (void)switchToFavorites;
- (void)switchToStream;
@end
