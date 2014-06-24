//
//  SharedAudioPlayer.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 21.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@interface SharedAudioPlayer : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVQueuePlayer *audioPlayer;
@property (nonatomic, strong) NSMutableArray *itemsToPlay;
@property (nonatomic) NSInteger positionInPlaylist;

+ (SharedAudioPlayer *)sharedPlayer;
- (void)insertItemsFromResponse:(NSDictionary *)response;
- (void)togglePlayPause;
- (void)previousItem;
- (void)nextItem;
- (void)jumpToItemAtIndex:(NSInteger)item;
- (void)advanceToTime:(CMTime)time;
- (NSDictionary *)currentItem;
@end
