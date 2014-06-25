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

@implementation SoundCloudAPIClient

- (id)init {
    self = [super init];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTracks) name:SCSoundCloudAccountDidChangeNotification object:nil];
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

- (void)reloadTracks {
    [[SharedAudioPlayer sharedPlayer] reset];
    [self getInitialStreamSongs];
}

- (void)getInitialStreamSongs {
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/activities/tracks/affiliated"]
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
                             [[SharedAudioPlayer sharedPlayer]insertItemsFromResponse:objectFromData];
                         }
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:nil];
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
                             [[SharedAudioPlayer sharedPlayer]insertItemsFromResponse:objectFromData];
                         }
                     }
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCloudAPIClientDidLoadSongs" object:nil];
                 }
             }];

}

@end
