//
//  SoundCloudAPIClient.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 25.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "SoundCloudAPIClient.h"
#import <SoundCloudAPI/SCAPI.h>
#import "SharedAudioPlayer.h"
#import "SoundCloudItem.h"

@implementation SoundCloudAPIClient

- (id)init {
    self = [super init];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStream) name:SCSoundCloudAccountDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToAuthenticate) name:SCSoundCloudDidFailToRequestAccessNotification object:nil];
    }
    return self;
}

+ (SoundCloudAPIClient *)sharedClient {
    static dispatch_once_t once;
    static SoundCloudAPIClient* sharedClient;
    dispatch_once(&once, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

- (void)login {
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        // Load the URL in a web view or open it in an external browser
        [[NSWorkspace sharedWorkspace] openURL:preparedURL];
    }];
}


- (void)logout {
    [SCSoundCloud removeAccess];
    [self didFailToAuthenticate];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)didFailToAuthenticate {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidFailToAuthenticate" object:nil];
    [[SharedAudioPlayer sharedPlayer] reset];
}
- (BOOL)isLoggedIn {
    SCAccount *account = [SCSoundCloud account];
    if (!account) {
        return NO;
    } else {
        return YES;
    }
}

- (void)reloadStream {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[SharedAudioPlayer sharedPlayer] reset];
    [self getInitialStreamSongs];
    [self getInitialFavoriteSongs];
}

- (void)getInitialStreamSongs {
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:@"https://api-v2.soundcloud.com/stream?limit=25"]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                 } else {
                     NSLog(@"Got data, yeah");
                     NSError *error;
                     id objectFromData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                     if (!error){
                         NSArray *itemsFromResponse = [SoundCloudItem soundCloudItemsFromResponse:objectFromData];
                         [[SharedAudioPlayer sharedPlayer] insertStreamItems:itemsFromResponse];
                     }
                 }
             }];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me"]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                 } else {
                     NSLog(@"Got data, yeah");
                     NSError *error;
                     id objectFromData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                     if (!error){
                         if ([objectFromData isKindOfClass:[NSDictionary class]]){
                             NSNumber *userId = [objectFromData objectForKey:@"id"];
                             [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"scUserId"];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                         }
                     }
                 }
             }];

}


- (void)getStreamSongsWithURL:(NSString *)url {
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                 } else {
                     NSLog(@"Got data, yeah");
                     NSError *error;
                     id objectFromData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                     if (!error){
                         if ([objectFromData isKindOfClass:[NSDictionary class]]) {
                             NSArray *itemsToInsert = [SoundCloudItem soundCloudItemsFromResponse:objectFromData];
                             [[SharedAudioPlayer sharedPlayer]insertStreamItems:itemsToInsert];
                         }
                     }
                 }
             }];

}

- (void)getInitialFavoriteSongs {
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:[NSString stringWithFormat:@"https://api-v2.soundcloud.com/users/%@/track_likes?limit=12&offset=0&linked_partitioning=1",[[NSUserDefaults standardUserDefaults] objectForKey:@"scUserId"]]]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                 } else {
                     NSLog(@"Got data, yeah");
                     NSError *error;
                     id objectFromData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                     if (!error){
                         if ([objectFromData isKindOfClass:[NSDictionary class]]) {
                             NSArray *itemsToInsert = [SoundCloudItem soundCloudItemsFromResponse:objectFromData];
                             [[SharedAudioPlayer sharedPlayer]insertFavoriteItems:itemsToInsert];
                             
                         }
                     }
                 }
             }];

}

- (void)getFavoriteSongsWithURL:(NSString *)url {
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                 } else {
                     NSLog(@"Got data, yeah");
                     NSError *error;
                     id objectFromData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                     if (!error){
                         if ([objectFromData isKindOfClass:[NSDictionary class]]) {
                             NSArray *itemsToInsert = [SoundCloudItem soundCloudItemsFromResponse:objectFromData];
                             [[SharedAudioPlayer sharedPlayer]insertFavoriteItems:itemsToInsert];
                         }
                     }
                 }
             }];
}

@end
