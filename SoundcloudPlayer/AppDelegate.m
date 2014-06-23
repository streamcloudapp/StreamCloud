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
#import "INAppStoreWindow.h"
#import "StreamCloudStyles.h"
#import "AFNetworking.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlider) name:@"SharedAudioPlayerUpdatedTimePlayed" object:nil];
    INAppStoreWindow *aWindow = (INAppStoreWindow*)[self window];
    aWindow.titleBarHeight = 28.0;
    
    NSView *titleBarView = [(INAppStoreWindow *)self.window titleBarView];
    NSSize buttonSize = NSMakeSize(28, 28);
    NSRect titleViewFrame = NSMakeRect(NSMidX(titleBarView.bounds) - (buttonSize.width / 2.f), NSMidY(titleBarView.bounds) - (buttonSize.height / 2.f), buttonSize.width, buttonSize.height);
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:titleViewFrame];
    [imageView setImage:[StreamCloudStyles imageOfSoundCloudLogoWithFrame:NSMakeRect(0, 0, 40, 18)]];
    [titleBarView addSubview:imageView];
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
                              [self.tableView reloadData];
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

# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *itemForRow = [[SharedAudioPlayer sharedPlayer].itemsToPlay objectAtIndex:row];
    NSDictionary *originDict = [itemForRow objectForKey:@"origin"];
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"MainColumn"]){
        NSTableCellView *viewforRow = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        [viewforRow.imageView setImage:[StreamCloudStyles imageOfSoundCloudLogoWithFrame:NSMakeRect(0, 0, 40, 18)]];
        if ([[originDict objectForKey:@"artwork_url"] isKindOfClass:[NSString class]]) {
            if ([originDict objectForKey:@"artwork_url"] && ![[originDict objectForKey:@"artwork_url"] isEqualToString:@"<null>"]){
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer = [AFImageResponseSerializer serializer];
                [manager GET:[originDict objectForKey:@"artwork_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [viewforRow.imageView setImage:responseObject];
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Failed to get image %@",error);
                }];
            }
        }
        [viewforRow.textField setStringValue:[originDict objectForKey:@"title"]];
        
        return viewforRow;
    }
    return nil;
}

# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[SharedAudioPlayer sharedPlayer] itemsToPlay].count;
}

# pragma mark - Update UI 

- (void)updateSlider {
    float timeGone = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentTime);
    float durationOfItem = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentItem.duration);
    //float timeToGo = durationOfItem - timeGone;
    [self.timeToGoLabel setStringValue:[self stringForSeconds:durationOfItem]];
    [self.timeGoneLabel setStringValue:[self stringForSeconds:timeGone]];
    [self.playerTimeSlider setDoubleValue:(timeGone/durationOfItem)*100];
}

# pragma mark - IBActions

- (IBAction)playButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] togglePlayPause];
}

- (IBAction)nextButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] nextItem];
}

- (IBAction)sliderUpdate:(id)sender {
    float durationOfItem = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentItem.duration);
    double newValue = self.playerTimeSlider.doubleValue;
    int newTime = (newValue/100)*durationOfItem;
    NSLog(@"Seeking to time %d",newTime);
    [[SharedAudioPlayer sharedPlayer] advanceToTime:CMTimeMake(newTime, NSEC_PER_SEC)];
}

# pragma mark - Helpers

- (NSString *)stringForSeconds:(NSUInteger)elapsedSeconds {
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds / 60) % 60;
    NSUInteger s = elapsedSeconds % 60;
    
    if (h > 0) {
        NSString *formattedTime = [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
        return formattedTime;
    } else {
        NSString *formattedTime = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)m, (unsigned long)s];
        return formattedTime;
    }
}

@end
