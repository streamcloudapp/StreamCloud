//
//  AppDelegate.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 20.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "AppDelegate.h"
#import <SoundCloudAPI/SCAPI.h>
#import "SharedAudioPlayer.h"
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    [SCSoundCloud  setClientID:@"909c2edcdbd7b312b48a04a3f1e6b40c"
                        secret:@"bb9505cbb4c3f56e7926025e51a6371e"
                   redirectURL:[NSURL URLWithString:@"streamcloud://soundcloud/callback"]];
    
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleURLEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    SCAccount *account = [SCSoundCloud account];
    if (!account) {
        [self login];
    } else {
        [self getAccountInfo];
    }
}

- (void)getAccountInfo {
    SCAccount *account = [SCSoundCloud account];
    
   [SCRequest performMethod:SCRequestMethodGET
                           onResource:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/me/activities/tracks/affiliated"]]
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
                          }
                      }];
}

- (void)login {
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        // Load the URL in a web view or open it in an external browser
        [[NSWorkspace sharedWorkspace] openURL:preparedURL];
    }];

}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent;
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    
    BOOL handled = [SCSoundCloud handleRedirectURL:[NSURL URLWithString:url]];
    if (!handled) {
        NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
    } else {
        [self getAccountInfo];
    }
    
}

# pragma mark - IBActions

- (IBAction)playButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] togglePlayPause];
}

- (IBAction)nextButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] nextItem];
}

@end
