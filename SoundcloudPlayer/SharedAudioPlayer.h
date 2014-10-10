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
@property (nonatomic, strong) NSString *nextStreamPartURL;
@property (nonatomic) RepeatMode repeatMode;
@property (nonatomic) CurrentSourceType sourceType;
@property (nonatomic ,strong) NSMutableArray *scrobbledItems;

+ (SharedAudioPlayer *)sharedPlayer;
- (void)insertItemsFromResponse:(NSDictionary *)response;
- (void)insertFavoriteItemsFromResponse:(NSDictionary *)response;
- (void)togglePlayPause;
- (void)previousItem;
- (void)nextItem;
- (void)jumpToItemAtIndex:(NSInteger)item;
- (void)advanceToTime:(float)timeToGo;
- (NSDictionary *)currentItem;
- (void)getNextSongs;
- (void)toggleRepeatMode;
- (void)reset;
- (void)switchToFavorites;
- (void)switchToStream;
@end
