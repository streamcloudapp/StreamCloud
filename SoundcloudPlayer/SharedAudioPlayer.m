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
#import "AFNetworking.h"
#import "LastFm.h"
#import <SoundCloudAPI/SCAPI.h>

@interface SharedAudioPlayer ()

@property (nonatomic) id audioPlayerCallback;
@property (nonatomic, strong) NSMutableArray *playlistsToLoad;
@end

@implementation SharedAudioPlayer

- (id)init {
    self = [super init];
    if (self){
        self.itemsToPlay = [NSMutableArray array];
        self.itemsToShowInTableView = [NSMutableArray array];
        self.positionInPlaylist = 0;
        [self setRepeatMode:RepeatModeNone];
        self.scrobbledItems = [NSMutableArray array];

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
        [self postNotificationForCurrentItem];
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
        [self jumpToItemAtIndex:self.positionInPlaylist+1];
    }
}

- (void)previousItem {
    if (CMTimeGetSeconds(self.audioPlayer.currentTime) > 5) {
        [self advanceToTime:0];
    } else {
        if (self.positionInPlaylist >= 1) {
            if (self.shuffleEnabled){
                [self jumpToItemAtIndex:[self.shuffledItemsToPlay indexOfObject:[self.itemsToPlay objectAtIndex:self.positionInPlaylist]]-1 startPlaying:self.audioPlayer.rate];
            } else {
                [self jumpToItemAtIndex:self.positionInPlaylist-1 startPlaying:self.audioPlayer.rate];
            }
        }
    }
}

- (void)jumpToItemAtIndex:(NSInteger)item {
    [self jumpToItemAtIndex:item startPlaying:YES];
}

- (void)jumpToItemAtIndex:(NSInteger)item startPlaying:(BOOL)start{
    [self.audioPlayer pause];
    [self.audioPlayer removeAllItems];
    
    for (NSInteger i = item; i < self.itemsToPlay.count && i < item+3; i++){
        NSDictionary *itemInList = [self.itemsToPlay objectAtIndex:i];
        [self.audioPlayer insertItem:[self itemForDict:itemInList] afterItem:nil];
    }
    self.positionInPlaylist = item;
    if (start)
        [self.audioPlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
    if (start){
        [self postNotificationForCurrentItem];
    }
}

- (void)advanceToTime:(float)timeToGo {
    int32_t timeScale = self.audioPlayer.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(timeToGo, timeScale);
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
            [self setRepeatMode:RepeatModeAll];
            break;
        case RepeatModeTrack:
            [self setRepeatMode:RepeatModeNone];
            break;
        case RepeatModeAll:
            [self setRepeatMode:RepeatModeTrack];
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

# pragma mark - Posting user notifications

- (void)postNotificationForCurrentItem {
    NSDictionary *currentItem = [self currentItem];
    NSDictionary *originDict = [currentItem objectForKey:@"origin"];
    NSDictionary *userDict = [originDict objectForKey:@"user"];
    NSString *title = [originDict objectForKey:@"title"];
    NSString *name = [userDict objectForKey:@"username"];
    BOOL useAvatar = YES;
    if ([[originDict objectForKey:@"artwork_url"] isKindOfClass:[NSString class]]) {
        if ([originDict objectForKey:@"artwork_url"] && ![[originDict objectForKey:@"artwork_url"]
                                                          isEqualToString:@"<null>"]){
            useAvatar = NO;
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            [manager GET:[originDict objectForKey:@"artwork_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSUserNotificationCenter *defaultCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
                NSUserNotification *nowPlayingNotification = [[NSUserNotification alloc]init];
                [defaultCenter setDelegate:self];
                [nowPlayingNotification setTitle:name];
                [nowPlayingNotification setInformativeText:title];
                [nowPlayingNotification setHasActionButton:NO];
                if ([nowPlayingNotification respondsToSelector:@selector(setContentImage:)]) {
                    [nowPlayingNotification setContentImage:responseObject];
                }
                [defaultCenter deliverNotification:nowPlayingNotification];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSUserNotificationCenter *defaultCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
                NSUserNotification *nowPlayingNotification = [[NSUserNotification alloc]init];
                [defaultCenter setDelegate:self];
                [nowPlayingNotification setTitle:name];
                [nowPlayingNotification setInformativeText:title];
                [nowPlayingNotification setHasActionButton:NO];
                [defaultCenter deliverNotification:nowPlayingNotification];
            }];
        }
    }
    if ([[userDict objectForKey:@"avatar_url"] isKindOfClass:[NSString class]] && useAvatar) {
        if ([userDict objectForKey:@"avatar_url"] && ![[userDict objectForKey:@"avatar_url"] isEqualToString:@"<null>"]){
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            [manager GET:[userDict objectForKey:@"avatar_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSUserNotificationCenter *defaultCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
                NSUserNotification *nowPlayingNotification = [[NSUserNotification alloc]init];
                [defaultCenter setDelegate:self];
                [nowPlayingNotification setTitle:name];
                [nowPlayingNotification setInformativeText:title];
                [nowPlayingNotification setHasActionButton:NO];
                if ([nowPlayingNotification respondsToSelector:@selector(setContentImage:)]) {
                    [nowPlayingNotification setContentImage:responseObject];
                }
                [defaultCenter deliverNotification:nowPlayingNotification];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSUserNotificationCenter *defaultCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
                NSUserNotification *nowPlayingNotification = [[NSUserNotification alloc]init];
                [defaultCenter setDelegate:self];
                [nowPlayingNotification setTitle:name];
                [nowPlayingNotification setInformativeText:title];
                [nowPlayingNotification setHasActionButton:NO];
                [defaultCenter deliverNotification:nowPlayingNotification];
            }];
        }
    }
}

# pragma mark - NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

# pragma mark - Inserting new items

- (void)insertItemsFromResponse:(NSDictionary *)response {
    NSArray *collectionItems = [response objectForKey:@"collection"];
    self.playlistsToLoad = nil;
    self.playlistsToLoad = [NSMutableArray array];
    self.nextStreamPartURL = [response objectForKey:@"next_href"];
    if (!_audioPlayer){
        NSMutableArray *itemsToPlay = [NSMutableArray array];
        for (NSDictionary *dict in collectionItems){
            AVPlayerItem *itemToPlay = [self itemForDict:dict];
            if (itemToPlay){
                [self.itemsToPlay addObject:dict];
                [self.itemsToShowInTableView addObject:dict];
                if (itemsToPlay.count < 3) {
                    [itemsToPlay addObject:itemToPlay];
                }
            } else {
                NSDictionary *objectToInjectAfter = [self.itemsToPlay lastObject];
                if (objectToInjectAfter) {
                    [_playlistsToLoad addObject:@{@"playlist":dict,@"afterObject":objectToInjectAfter}];
                } else {
                    [_playlistsToLoad addObject:@{@"playlist":dict}];
                }
            }
        }
        self.audioPlayer = [AVQueuePlayer queuePlayerWithItems:itemsToPlay];
        [self.audioPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        self.audioPlayerCallback = [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
            if (!isnan(CMTimeGetSeconds(time))) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedAudioPlayerUpdatedTimePlayed" object:[NSNumber numberWithFloat:CMTimeGetSeconds(time)]];
                float seconds = CMTimeGetSeconds(time);
                NSDictionary *currentItem = [[SharedAudioPlayer sharedPlayer] currentItem];
                NSDictionary *originItem = [currentItem objectForKey:@"origin"];
                NSNumber *duration = [originItem objectForKey:@"duration"];
                BOOL doScrobble = [[NSUserDefaults standardUserDefaults] boolForKey:@"useLastFM"];
                if ((seconds > 240 || seconds > (duration.floatValue/1000)*0.3) && ![[SharedAudioPlayer sharedPlayer].scrobbledItems containsObject:currentItem] && doScrobble) {
                    NSLog(@"Scrobble!");
                    [[LastFm sharedInstance] setUsername:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMUserName"]];
                    [[LastFm sharedInstance] setSession:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMSessionKey"]];
                    NSDictionary *userDict = [originItem objectForKey:@"user"];
                    [[LastFm sharedInstance] sendScrobbledTrack:[originItem objectForKey:@"title"] byArtist:[userDict objectForKey:@"username"] onAlbum:nil withDuration:duration.doubleValue/1000 atTimestamp:[[NSDate date] timeIntervalSince1970] successHandler:^(NSDictionary *result) {
                        NSLog(@"Success %@",result);
                    } failureHandler:^(NSError *error) {
                        NSLog(@"Error scrobbling %@",error);
                    }];
                    [[SharedAudioPlayer sharedPlayer].scrobbledItems addObject:currentItem];
                }
            }
        }];
        
        [self.audioPlayer setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    } else {
        for (NSDictionary *dict in collectionItems){
            AVPlayerItem *itemToPlay = [self itemForDict:dict];
            if (itemToPlay) {
                [self.itemsToPlay addObject:dict];
                [self.itemsToShowInTableView addObject:dict];
                if (self.audioPlayer.items.count < 3) {
                    [self.audioPlayer insertItem:itemToPlay afterItem:nil];
                }
            } else {
                NSDictionary *objectToInjectAfter = [self.itemsToPlay lastObject];
                if (objectToInjectAfter) {
                    [_playlistsToLoad addObject:@{@"playlist":dict,@"afterObject":objectToInjectAfter}];
                } else {
                    [_playlistsToLoad addObject:@{@"playlist":dict}];
                }            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [self setShuffleEnabled:_shuffleEnabled];
    [self loadPlaylistsFromArray:_playlistsToLoad];
}


- (void)rebuildAudioPlayList {
    
    if (!self.audioPlayer.rate){
        [self.audioPlayer removeAllItems];
        
        for (NSDictionary *item in [self.itemsToPlay objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]){
            [self.audioPlayer insertItem:[self itemForDict:item] afterItem:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
        [self setShuffleEnabled:_shuffleEnabled];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:nil];
    } else {
        for (int i = 1; i < self.audioPlayer.items.count; i++){
            [self.audioPlayer removeItem:[self.audioPlayer.items objectAtIndex:i]];
        }
        for (NSInteger i = self.positionInPlaylist+1; i < self.itemsToPlay.count && i < self.positionInPlaylist+4; i++) {
            NSDictionary *dictToInsert = [self.itemsToPlay objectAtIndex:i];
            [self.audioPlayer insertItem:[self itemForDict:dictToInsert] afterItem:nil];
        }
    }
}

- (void)loadNextTrackInPlayer {
    NSDictionary *currentItem = [self currentItem];
    if (self.shuffleEnabled){
        NSInteger indexOfCurrentItem = [self.shuffledItemsToPlay indexOfObject:currentItem];
        if (indexOfCurrentItem < self.shuffledItemsToPlay.count + 2) {
            NSDictionary *nextItem = [self.shuffledItemsToPlay objectAtIndex:indexOfCurrentItem+1];
            [self.audioPlayer insertItem:[self itemForDict:nextItem] afterItem:nil];
        }
    } else {
        NSInteger indexOfCurrentItem = [self.itemsToPlay indexOfObject:currentItem];
        if (indexOfCurrentItem < self.itemsToPlay.count + 2) {
            NSDictionary *nextItem = [self.itemsToPlay objectAtIndex:indexOfCurrentItem+1];
            [self.audioPlayer insertItem:[self itemForDict:nextItem] afterItem:nil];
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


- (void)jumpedToNextItem {
    if (self.shuffleEnabled){
        if (_positionInPlaylist <= self.itemsToPlay.count) {
            self.positionInPlaylist = [self.itemsToPlay indexOfObject:[self.shuffledItemsToPlay objectAtIndex:_positionInPlaylist+1]];
            [self jumpToItemAtIndex: _positionInPlaylist];
        }
    } else {
        self.positionInPlaylist++;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
    if (self.positionInPlaylist == self.itemsToPlay.count-2) {
        [self getNextSongs];
    }
    if (self.audioPlayer.items.count >= 2) {
        AVPlayerItem *nextItem = [[self.audioPlayer items] objectAtIndex:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nextItem];
    }
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    [self.scrobbledItems removeObject:self.currentItem];
    switch (self.repeatMode) {
        case RepeatModeTrack: {
            [self jumpToItemAtIndex:self.positionInPlaylist];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            break;
        }
        case RepeatModeAll: {
            if (self.positionInPlaylist < self.itemsToPlay.count-1) {
                self.positionInPlaylist++;
            } else {
                [self jumpToItemAtIndex:0];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            break;
        }
        default: {
            if (self.shuffleEnabled){
                if (_positionInPlaylist <= self.itemsToPlay.count) {
                    self.positionInPlaylist = [self.itemsToPlay indexOfObject:[self.shuffledItemsToPlay objectAtIndex:_positionInPlaylist+1]];
                    [self jumpToItemAtIndex: _positionInPlaylist];
                }
            } else if (self.audioPlayer.items.count > 1) {
                
                self.positionInPlaylist++;
            } else {
                [self.audioPlayer pause];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            if (self.positionInPlaylist == self.itemsToPlay.count-1) {
                [self getNextSongs];
            }
            break;
        }
    }
    [self loadNextTrackInPlayer];
    if (self.audioPlayer.items.count >= 2) {
        AVPlayerItem *nextItem = [[self.audioPlayer items] objectAtIndex:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nextItem];
    }
}

- (void)getNextSongs {
    if (self.nextStreamPartURL){
        [[SoundCloudAPIClient sharedClient] getStreamSongsWithURL:self.nextStreamPartURL];
    }
}


# pragma mark - Creating AVPlayerItems

- (AVPlayerItem *)itemForDict:(NSDictionary *)dict {
    if ([dict[@"type"] isEqualToString:@"track"] && [dict[@"origin"][@"streamable"] boolValue] && [dict[@"origin"][@"state"] isEqualToString:@"finished"] && [dict[@"origin"][@"sharing"] isEqualToString:@"public"]) {
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

# pragma mark - Getting tracks of playlists

- (void)loadPlaylistsFromArray:(NSArray *)playlists{
    
    for (NSDictionary *playlistContainerDict in playlists) {
        NSDictionary *playlistDict = [playlistContainerDict objectForKey:@"playlist"];
        NSDictionary *objectToInsertAfter = [playlistContainerDict objectForKey:@"afterObject"];
        if ([playlistDict[@"type"] isEqualToString:@"playlist"] && [playlistDict[@"origin"][@"duration"] doubleValue]){
            SCAccount *account = [SCSoundCloud account];
            NSURL *trackURI = [NSURL URLWithString:playlistDict[@"origin"][@"tracks_uri"]];
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:trackURI
                     usingParameters:nil
                         withAccount:account
              sendingProgressHandler:nil
                     responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                         // Handle the response
                         if (error) {
                             NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                         } else {
                             NSLog(@"Got playlist");
                             NSError *error;
                             id objectFromData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                             if (!error){
                                 if ([objectFromData isKindOfClass:[NSArray class]]) {
                                     if (!objectToInsertAfter){
                                         [self.itemsToShowInTableView insertObject:playlistDict atIndex:0];
                                     } else {
                                         [self.itemsToShowInTableView insertObject:playlistDict atIndex:[self.itemsToShowInTableView indexOfObject:objectToInsertAfter]+1];
                                     }
                                     NSMutableArray *playlistCache = [NSMutableArray array];
                                     for (NSDictionary *trackDict in objectFromData) {
                                         if ([[trackDict objectForKey:@"streamable"] boolValue] && [[trackDict objectForKey:@"state"] isEqualToString:@"finished"]  && [trackDict[@"sharing"] isEqualToString:@"public"]) {
                                             NSDictionary *containeredTrack = @{@"type":@"track",@"playlist_track_is_from":playlistDict,@"origin":trackDict};
                                             [playlistCache addObject:containeredTrack];
                                         }
                                     }
                                     if (!objectToInsertAfter){
                                         [self.itemsToPlay insertObjects:playlistCache atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, playlistCache.count)]];
                                         [self.itemsToShowInTableView insertObjects:playlistCache atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, playlistCache.count)]];
                                     } else {
                                         [self.itemsToPlay insertObjects:playlistCache atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.itemsToPlay indexOfObject:objectToInsertAfter]+1, playlistCache.count)]];
                                         [self.itemsToShowInTableView insertObjects:playlistCache atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.itemsToShowInTableView indexOfObject:objectToInsertAfter]+2, playlistCache.count)]];
                                     }
                                     if (self.playlistsToLoad.count == 1) {
                                         [self rebuildAudioPlayList];
                                     }
                                     [self.playlistsToLoad removeObject:playlistContainerDict];
                                 }
                             }
                         }
                     }];
        } else {
            NSLog(@"Could not load dict %@",playlistDict);
        }
    }
}

@end
