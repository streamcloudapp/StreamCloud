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
#import "SoundCloudItem.h"
#import "SoundCloudTrack.h"
#import "SoundCloudPlaylist.h"
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
        self.streamItemsToShowInTableView = [NSMutableArray array];
        self.favoriteItemsToShowInTableView = [NSMutableArray array];
        self.positionInPlaylist = 0;
        [self setRepeatMode:RepeatModeNone];
        self.scrobbledItems = [NSMutableArray array];
        self.playlistsToLoad = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToLoadTracksForPlaylists:) name:@"SoundCloudPlaylistFailedToLoadTracks" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadPlaylistTracks:) name:@"SoundCloudPlaylistTracksLoaded" object:nil];

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
        if (CMTimeGetSeconds(self.audioPlayer.currentItem.currentTime) <= 3)
            [self postNotificationForCurrentItem];
    }
}


- (void)nextItem {
    if (self.shuffleEnabled) {
        SoundCloudTrack *currentShuffledItem = [self.shuffledItemsToPlay objectAtIndex:self.positionInPlaylist];
        if (currentShuffledItem) {
            if (self.sourceType == CurrentSourceTypeStream){
                [self jumpToItemAtIndex:[self.streamItemsToShowInTableView indexOfObject:currentShuffledItem]startPlaying:YES resetShuffle:NO];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            }else {
                [self jumpToItemAtIndex:[self.streamItemsToShowInTableView indexOfObject:currentShuffledItem]startPlaying:YES resetShuffle:NO];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            }
        }
    } else {
        if (self.positionInPlaylist == self.itemsToPlay.count-1 && self.repeatMode == RepeatModeAll) {
            [self jumpToItemAtIndex:0];
        } else if (self.positionInPlaylist != self.itemsToPlay.count-1)
            [self jumpToItemAtIndex:self.positionInPlaylist+1];
    }
}

- (void)previousItem {
    [self advanceToTime:0];
    if (CMTimeGetSeconds(self.audioPlayer.currentTime) < 5) {
        if (self.positionInPlaylist >= 1) {
            if (self.shuffleEnabled){
                if (self.sourceType == CurrentSourceTypeStream) {
                    [self jumpToItemAtIndex:[self.shuffledItemsToPlay indexOfObject:[self.streamItemsToShowInTableView objectAtIndex:self.positionInPlaylist]]-1 startPlaying:self.audioPlayer.rate];
                } else {
                    [self jumpToItemAtIndex:[self.shuffledItemsToPlay indexOfObject:[self.favoriteItemsToShowInTableView objectAtIndex:self.positionInPlaylist]]-1 startPlaying:self.audioPlayer.rate];
                }
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
    [self jumpToItemAtIndex:item startPlaying:start resetShuffle:YES];
}

- (void)jumpToItemAtIndex:(NSInteger)item startPlaying:(BOOL)start resetShuffle:(BOOL)resetShuffle{

    [self.audioPlayer pause];
    [self.audioPlayer cancelPendingPrerolls];
    int32_t timeScale = self.audioPlayer.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(0, timeScale);
    [self.audioPlayer seekToTime:time];
    [self.audioPlayer removeAllItems];
    
    NSInteger i = item;
    BOOL done = NO;
    while(!done){
        if (self.sourceType == CurrentSourceTypeStream) {
            if (i < self.streamItemsToShowInTableView.count &&[[self.streamItemsToShowInTableView objectAtIndex:i] isKindOfClass:[SoundCloudTrack class]]) {
                SoundCloudTrack *itemInList = [self.streamItemsToShowInTableView objectAtIndex:i];
                if ([self.audioPlayer canInsertItem:itemInList.playerItem afterItem:nil])
                    [self.audioPlayer insertItem:itemInList.playerItem afterItem:nil];
                i++;
                if ( i > item+3)
                    done = YES;
            } else if (i < self.streamItemsToShowInTableView.count) {
                i++;
            } else {
                done = YES;
            }
        } else {
            if (i < self.favoriteItemsToShowInTableView.count && [[self.favoriteItemsToShowInTableView objectAtIndex:i] isKindOfClass:[SoundCloudTrack class]]) {
                SoundCloudTrack *itemInList = [self.favoriteItemsToShowInTableView objectAtIndex:i];
                if ([self.audioPlayer canInsertItem:itemInList.playerItem afterItem:nil])
                    [self.audioPlayer insertItem:itemInList.playerItem afterItem:nil];
                i++;
                if ( i > item+3)
                    done = YES;
            } else if (i < self.favoriteItemsToShowInTableView.count) {
                i++;
            } else {
                done = YES;
            }
        }
    }
    self.positionInPlaylist = item;
    if (start)
        [self.audioPlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
    if (start){
        [self postNotificationForCurrentItem];
    }
    if (resetShuffle)
        [self setShuffleEnabled:_shuffleEnabled];
    if (start && _shuffleEnabled){
        [self setShuffleEnabled:_shuffleEnabled];
    }
}

- (void)advanceToTime:(float)timeToGo {
    int32_t timeScale = self.audioPlayer.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(timeToGo, timeScale);
    [self.audioPlayer seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"Finished %@",finished ? @"NO" : @"YES");
    }];
}

- (SoundCloudTrack *)currentItem {
    if (self.sourceType == CurrentSourceTypeStream) {
        AVPlayerItem *currentPlayerItem = self.audioPlayer.currentItem;
        NSArray *tracksOnlyArray = [self.streamItemsToShowInTableView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[SoundCloudTrack class]]];
        NSArray *tracksForCurrentItem = [tracksOnlyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"playerItem == %@",currentPlayerItem]];
        return [tracksForCurrentItem firstObject];
    } else if (self.sourceType == CurrentSourceTypeFavorites) {
        NSArray *tracksOnlyArray = [self.favoriteItemsToShowInTableView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[SoundCloudTrack class]]];
        NSArray *tracksForCurrentItem = [tracksOnlyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"playerItem == %@",self.audioPlayer.currentItem]];
        return [tracksForCurrentItem firstObject];
    }
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
        if (self.sourceType == CurrentSourceTypeStream)
            self.shuffledItemsToPlay = [NSMutableArray arrayWithArray:self.streamItemsToShowInTableView];
        else if (self.sourceType == CurrentSourceTypeFavorites)
            self.shuffledItemsToPlay = [NSMutableArray arrayWithArray:self.favoriteItemsToShowInTableView];
        NSUInteger count = [self.shuffledItemsToPlay count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            NSUInteger nElements = count - i;
            NSUInteger n = (arc4random() % nElements) + i;
            [self.shuffledItemsToPlay exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        self.positionInPlaylist = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayShuffleStarted" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayShuffleEnded" object:nil];
    }
}

- (void)setRepeatMode:(RepeatMode)repeatMode {
    _repeatMode = repeatMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SharedAudioPlayerChangedRepeatMode" object:nil];
}

- (void)switchToFavorites {
    self.sourceType = CurrentSourceTypeFavorites;
    self.itemsToPlay = nil;
    self.itemsToPlay = [NSMutableArray arrayWithCapacity:self.favoriteItemsToShowInTableView.count];
    for (NSDictionary *item in self.favoriteItemsToShowInTableView) {
        [self.itemsToPlay addObject:item];
    }
}

- (void)switchToStream {
    self.sourceType = CurrentSourceTypeStream;
    self.itemsToPlay = nil;
}

- (void)reset {
    [self.audioPlayer pause];
    [self.audioPlayer cancelPendingPrerolls];
    int32_t timeScale = self.audioPlayer.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(0, timeScale);
    [self.audioPlayer seekToTime:time];
    [self.audioPlayer removeAllItems];
    [self.audioPlayer removeObserver:self forKeyPath:@"rate"];
    [self.itemsToPlay removeAllObjects];
    [self.shuffledItemsToPlay removeAllObjects];
    [self.streamItemsToShowInTableView removeAllObjects];
    [self.favoriteItemsToShowInTableView removeAllObjects];
    self.positionInPlaylist = 0;
    self.audioPlayer = nil;
    self.shuffledItemsToPlay = nil;
    self.itemsToPlay = nil;
    self.shuffledItemsToPlay = [NSMutableArray array];
    self.itemsToPlay = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:nil];
}

# pragma mark - Posting user notifications

- (void)postNotificationForCurrentItem {
    SoundCloudTrack *currentItem = [self currentItem];
    NSString *title = currentItem.title;
    NSString *name = currentItem.user.username;
    BOOL useAvatar = YES;
    if (currentItem.artworkUrl) {
        useAvatar = NO;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:currentItem.artworkUrl.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    else if (currentItem.user.avatarUrl) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:currentItem.user.avatarUrl.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

# pragma mark - NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

# pragma mark - Inserting new items


- (void)insertStreamItems:(NSArray *)items {
    SoundCloudItem *lastItem = [items lastObject];
    self.nextStreamPartURL = lastItem.nextHref;
    if (!_audioPlayer){
        NSMutableArray *itemsToPlay = [NSMutableArray array];
        for (SoundCloudItem *item in items){
            if (item.type == SoundCloudItemTypeTrack || item.type == SoundCloudItemTypeTrackRepost) {
                SoundCloudTrack *trackForItem = item.item;
                if (trackForItem.playerItem) {
                    [self.streamItemsToShowInTableView addObject:trackForItem];
                    if (itemsToPlay.count < 3) {
                        [itemsToPlay addObject:trackForItem.playerItem];
                    }
                }
            } else if (item.type == SoundCloudItemTypePlaylist || item.type == SoundCloudItemTypePlaylistRepost){
                SoundCloudPlaylist *playlistForItem = item.item;
                if (playlistForItem.streamable) {
                    [self.streamItemsToShowInTableView addObject:playlistForItem];
                    for (SoundCloudTrack *playlistTrack in playlistForItem.tracks) {
                        [self.streamItemsToShowInTableView addObject:playlistTrack];
                        if (itemsToPlay.count < 3) {
                            [itemsToPlay addObject:playlistTrack.playerItem];
                        }
                    }
                }
            }
        }
        self.audioPlayer = [AVQueuePlayer queuePlayerWithItems:itemsToPlay];
        [self.audioPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        self.audioPlayerCallback = [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
            if (!isnan(CMTimeGetSeconds(time))) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedAudioPlayerUpdatedTimePlayed" object:[NSNumber numberWithFloat:CMTimeGetSeconds(time)]];
                float seconds = CMTimeGetSeconds(time);
                SoundCloudTrack *currentItem = [[SharedAudioPlayer sharedPlayer] currentItem];
                BOOL doScrobble = [[NSUserDefaults standardUserDefaults] boolForKey:@"useLastFM"];
                if (doScrobble && (seconds > 240 || seconds > currentItem.duration*0.3) && ![[SharedAudioPlayer sharedPlayer].scrobbledItems containsObject:currentItem]) {
                    NSLog(@"Scrobble!");
                    [[LastFm sharedInstance] setUsername:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMUserName"]];
                    [[LastFm sharedInstance] setSession:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMSessionKey"]];
                    [[LastFm sharedInstance] sendScrobbledTrack:currentItem.title byArtist:currentItem.user.username onAlbum:nil withDuration:currentItem.duration atTimestamp:[[NSDate date] timeIntervalSince1970] successHandler:^(NSDictionary *result) {
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
        for (SoundCloudItem *item in items){
            if (item.type == SoundCloudItemTypeTrack || item.type == SoundCloudItemTypeTrackRepost) {
                SoundCloudTrack *trackForItem = item.item;
                if (trackForItem.playerItem) {
                    [self.streamItemsToShowInTableView addObject:trackForItem];
                    if (self.itemsToPlay.count < 3) {
                        [self.itemsToPlay addObject:trackForItem.playerItem];
                    }
                }
            } else if (item.type == SoundCloudItemTypePlaylist || item.type == SoundCloudItemTypePlaylistRepost){
                SoundCloudPlaylist *playlistForItem = item.item;
                if (playlistForItem.streamable) {
                    [self.streamItemsToShowInTableView addObject:playlistForItem];
                    for (SoundCloudTrack *playlistTrack in playlistForItem.tracks) {
                        [self.streamItemsToShowInTableView addObject:playlistTrack];
                        if (self.itemsToPlay.count < 3) {
                            [self.itemsToPlay addObject:playlistTrack.playerItem];
                        }
                    }
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [self setShuffleEnabled:_shuffleEnabled];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:@{@"type": @"stream", @"count":@(items.count)}];
}

- (void)insertFavoriteItems:(NSArray *)items {

    for (SoundCloudItem *item in items){
        if (item.type == SoundCloudItemTypeTrack || item.type == SoundCloudItemTypeTrackRepost) {
            SoundCloudTrack *trackFromItem = item.item;
            [self.favoriteItemsToShowInTableView addObject:trackFromItem];
        } else if (item.type == SoundCloudItemTypePlaylist || item.type == SoundCloudItemTypePlaylistRepost) {
            SoundCloudPlaylist *playlistFromItem = item.item;
            [self.favoriteItemsToShowInTableView addObject:playlistFromItem];
            for (SoundCloudTrack *playlistTrack in playlistFromItem.tracks){
                [self.favoriteItemsToShowInTableView addObject:playlistTrack];
            }
        }
    }
    
    if (self.sourceType == CurrentSourceTypeFavorites){
        [self switchToFavorites];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [self setShuffleEnabled:_shuffleEnabled];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:@{@"type": @"favorites", @"count":@(items.count)}];

}

- (void)rebuildAudioPlayList {
    
    if (!self.audioPlayer.rate){
        [self.audioPlayer removeAllItems];
        
        for (NSDictionary *item in [self.itemsToPlay objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]){
            [self.audioPlayer insertItem:[self itemForDict:item] afterItem:nil];
        }
    } else {
        for (int i = 1; i < self.audioPlayer.items.count; i++){
            [self.audioPlayer removeItem:[self.audioPlayer.items objectAtIndex:i]];
        }
        for (NSInteger i = self.positionInPlaylist+1; i < self.itemsToPlay.count && i < self.positionInPlaylist+4; i++) {
            NSDictionary *dictToInsert = [self.itemsToPlay objectAtIndex:i];
            [self.audioPlayer insertItem:[self itemForDict:dictToInsert] afterItem:nil];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [self setShuffleEnabled:_shuffleEnabled];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:nil];
}

- (void)loadNextTrackInPlayer {
    SoundCloudTrack *currentItem = [self currentItem];
    if (self.shuffleEnabled){
        NSInteger indexOfCurrentItem = [self.shuffledItemsToPlay indexOfObject:currentItem];
        if (indexOfCurrentItem < (self.shuffledItemsToPlay.count + 2)) {
            SoundCloudTrack *nextItem = [self.shuffledItemsToPlay objectAtIndex:indexOfCurrentItem+1];
            if ([nextItem respondsToSelector:@selector(playerItem)]) {
                if ([self.audioPlayer canInsertItem:nextItem.playerItem afterItem:nil])
                    [self.audioPlayer insertItem:nextItem.playerItem afterItem:nil];
            }
        }
    } else {
        if (self.sourceType == CurrentSourceTypeStream){
            NSInteger indexOfCurrentItem = [self.streamItemsToShowInTableView indexOfObject:currentItem];
            if (indexOfCurrentItem < self.streamItemsToShowInTableView.count - 2) {
                SoundCloudTrack *nextItem = [self.streamItemsToShowInTableView objectAtIndex:indexOfCurrentItem+1];
                if ([nextItem respondsToSelector:@selector(playerItem)]) {
                    if ([self.audioPlayer canInsertItem:nextItem.playerItem afterItem:nil])
                        [self.audioPlayer insertItem:nextItem.playerItem afterItem:nil];
                }
            }
        } else if (self.sourceType == CurrentSourceTypeFavorites){
            NSInteger indexOfCurrentItem = [self.favoriteItemsToShowInTableView indexOfObject:currentItem];
            if (indexOfCurrentItem < self.favoriteItemsToShowInTableView.count - 2) {
                SoundCloudTrack *nextItem = [self.favoriteItemsToShowInTableView objectAtIndex:indexOfCurrentItem+1];
                if ([nextItem respondsToSelector:@selector(playerItem)]) {
                    if ([self.audioPlayer canInsertItem:nextItem.playerItem afterItem:nil])
                        [self.audioPlayer insertItem:nextItem.playerItem afterItem:nil];
                }
            }
        }
    }
}

- (void)failedToLoadTracksForPlaylists:(NSNotification *)notification {
    SoundCloudPlaylist *playlistTracksLoadedFor = notification.object;
    [self.streamItemsToShowInTableView removeObject:playlistTracksLoadedFor];
    [self.favoriteItemsToShowInTableView removeObject:playlistTracksLoadedFor];
}

- (void)didLoadPlaylistTracks:(NSNotification *)notification {
    NSArray *playlistsInStream = [self.streamItemsToShowInTableView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[SoundCloudPlaylist class]]];
    NSArray *emptyPlaylistsInStream = [playlistsInStream filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tracks == nil"]];
    if (emptyPlaylistsInStream.count == 0 && playlistsInStream.count > 0){
        NSLog(@"Got all playlists");
        for (SoundCloudPlaylist *playlist in playlistsInStream){
            SoundCloudTrack *firstTrack = playlist.tracks.firstObject;
            if (firstTrack && ![self.streamItemsToShowInTableView containsObject:firstTrack]){
                NSUInteger indexOfPlaylist = [self.streamItemsToShowInTableView indexOfObject:playlist];
                [self.streamItemsToShowInTableView insertObjects:playlist.tracks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexOfPlaylist+1, playlist.tracks.count)]];
            }
        }
    }
    NSArray *playlistsInFavorites = [self.favoriteItemsToShowInTableView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[SoundCloudPlaylist class]]];
    NSArray *emptyPlaylistsInFavorites = [playlistsInFavorites filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tracks == nil"]];
    if (emptyPlaylistsInFavorites.count == 0 && playlistsInFavorites.count > 0){
        NSLog(@"Got all playlists");
        for (SoundCloudPlaylist *playlist in playlistsInFavorites){
            SoundCloudTrack *firstTrack = playlist.tracks.firstObject;
            if (firstTrack && ![self.favoriteItemsToShowInTableView containsObject:firstTrack]){
                NSUInteger indexOfPlaylist = [self.favoriteItemsToShowInTableView indexOfObject:playlist];
                [self.favoriteItemsToShowInTableView insertObjects:playlist.tracks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexOfPlaylist+1, playlist.tracks.count)]];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:nil];
    
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
    if (self.shuffleEnabled && self.repeatMode != RepeatModeTrack){
        if (_positionInPlaylist <= self.itemsToPlay.count) {
            self.positionInPlaylist = [self.itemsToPlay indexOfObject:[self.shuffledItemsToPlay objectAtIndex:_positionInPlaylist+1]];
            [self jumpToItemAtIndex: _positionInPlaylist startPlaying:YES resetShuffle:NO];
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
            [self.audioPlayer pause];
            NSInteger indexOfFinishedItem = NSNotFound;
            AVPlayerItem *itemFromNotification = notification.object;
            if (self.sourceType == CurrentSourceTypeStream){
                NSArray *tracksOnlyArray = [self.streamItemsToShowInTableView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[SoundCloudTrack class]]];
                NSArray *tracksForCurrentItem = [tracksOnlyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"playerItem == %@",itemFromNotification]];
                SoundCloudTrack *finishedTrack = [tracksForCurrentItem firstObject];
                indexOfFinishedItem = [self.streamItemsToShowInTableView indexOfObject:finishedTrack];
            } else if (self.sourceType == CurrentSourceTypeFavorites){
                NSArray *tracksOnlyArray = [self.favoriteItemsToShowInTableView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[SoundCloudTrack class]]];
                NSArray *tracksForCurrentItem = [tracksOnlyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"playerItem == %@",itemFromNotification]];
                SoundCloudTrack *finishedTrack = [tracksForCurrentItem firstObject];
                indexOfFinishedItem = [self.favoriteItemsToShowInTableView indexOfObject:finishedTrack];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (indexOfFinishedItem != NSNotFound)
                    [self jumpToItemAtIndex:indexOfFinishedItem];
                
            });
            break;
        }
        case RepeatModeAll: {
            NSInteger itemCount = self.sourceType == CurrentSourceTypeStream ? self.streamItemsToShowInTableView.count : self.favoriteItemsToShowInTableView.count;
            if (self.shuffleEnabled)
                itemCount = self.shuffledItemsToPlay.count;
            if (self.positionInPlaylist < itemCount-1) {
                self.positionInPlaylist++;
            } else {
                [self jumpToItemAtIndex:0];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
            break;
        }
        default: {
            if (self.shuffleEnabled){
                if (_positionInPlaylist < self.shuffledItemsToPlay.count-1) {
                    if (self.sourceType == CurrentSourceTypeStream) {
                        self.positionInPlaylist = [self.streamItemsToShowInTableView indexOfObject:[self.shuffledItemsToPlay objectAtIndex:_positionInPlaylist+1]];
                    } else if (self.sourceType == CurrentSourceTypeFavorites){
                        self.positionInPlaylist = [self.favoriteItemsToShowInTableView indexOfObject:[self.shuffledItemsToPlay objectAtIndex:_positionInPlaylist+1]];
                    }
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
    [self postNotificationForCurrentItem];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SharedPlayerDidFinishObject" object:nil];
    });
}

- (void)getNextSongs {
    if (self.nextStreamPartURL){
        [[SoundCloudAPIClient sharedClient] getStreamSongsWithURL:self.nextStreamPartURL.absoluteString];
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

@end
