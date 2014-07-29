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
#import "TrackCellView.h"
//#import "AppleMediaKeyController.h"
#import "SoundCloudAPIClient.h"
//#import <HockeySDK/HockeySDK.h>
#import "AFNetworking.h"
#import "LastFm.h"
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"
#import "TrackCellForPlaylistItemView.h"

NSString *const PlayPauseShortcutPreferenceKey = @"PlayPauseShortcut";
NSString *const NextShortcutPreferenceKey = @"NextShortcut";
NSString *const PreviousShortcutPreferenceKey = @"PreviousShortcut";


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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlider) name:@"SharedAudioPlayerUpdatedTimePlayed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayingItem) name:@"SharedPlayerDidFinishObject" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNewSongs:) name:@"SoundCloudAPIClientDidLoadSongs" object:nil];
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewDidScroll:) name:NSViewBoundsDidChangeNotification object:clipView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToAuthenticate) name:@"SoundCloudAPIClientDidFailToAuthenticate" object:nil];
    
    INAppStoreWindow *aWindow = (INAppStoreWindow*)[self window];
    aWindow.titleBarHeight = 28.0;
    
    NSView *titleBarView = [(INAppStoreWindow *)self.window titleBarView];
    NSSize buttonSize = NSMakeSize(28, 28);
    NSRect titleViewFrame = NSMakeRect(NSMidX(titleBarView.bounds) - (buttonSize.width / 2.f), NSMidY(titleBarView.bounds) - (buttonSize.height / 2.f), buttonSize.width, buttonSize.height);
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:titleViewFrame];
    [imageView setImage:[StreamCloudStyles imageOfSoundCloudLogoWithFrame:NSMakeRect(0, 0, 40, 18)]];
    [imageView setAutoresizingMask:NSViewMinXMargin|NSViewMaxXMargin];
    [titleBarView addSubview:imageView];
    
    [self.tableView setDoubleAction:@selector(tableViewDoubleClick)];
    
    
    //Global Shortcuts
    // Shortcut view will follow and modify user preferences automatically
    self.playPauseShortcutView.associatedUserDefaultsKey = PlayPauseShortcutPreferenceKey;
    
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:PlayPauseShortcutPreferenceKey handler:^{
        [self playButtonAction:nil];
    }];
    
    NSLog(@"playpause value %@",[[NSUserDefaults standardUserDefaults] stringForKey:PlayPauseShortcutPreferenceKey]);
    
    self.nextShortcutView.associatedUserDefaultsKey = NextShortcutPreferenceKey;
    
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:NextShortcutPreferenceKey handler:^{
        [self nextButtonAction:nil];
    }];
    
    self.prevShortcutView.associatedUserDefaultsKey = PreviousShortcutPreferenceKey;
    
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:PreviousShortcutPreferenceKey handler:^{
        [self previousButtonAction:nil];
    }];
    
    //Notification for MagicKeys
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NotifiedAboutMagicKeys"]) {
        NSAlert *magicKeysAlert = [NSAlert alertWithMessageText:@"To enable support for meda keys you need to install the MagicKeys Preference Pane. Do you want to install it now?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"MagicKeys enables you to send the events from the media keys of your keyboard and headphones to any supported application and enables you to control which application starts when the play button is pressed. If you don't want to install just configure other hotkeys in the settings"];
        [magicKeysAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == 1) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.treasurebox.hu/magickeys.html"]];
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotifiedAboutMagicKeys"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
    
    if ([[SoundCloudAPIClient sharedClient] isLoggedIn]) {
        [[SoundCloudAPIClient sharedClient] getInitialStreamSongs];

    } else {
        [self didFailToAuthenticate];
    }
    
    
    [LastFm sharedInstance].apiKey = @"2473328884e701efe22e0491a9bbaeb6";
    [LastFm sharedInstance].apiSecret = @"8c197f07a45e251288815154a1569978";
    
//    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"749b642d520ae57bfe9101ce28da075c"];
//    [[BITHockeyManager sharedHockeyManager] startManager];
//    
//    AFHTTPRequestOperationManager *betaRequest = [AFHTTPRequestOperationManager manager];
//    [betaRequest setResponseSerializer:[AFPropertyListResponseSerializer serializer]];
//    [betaRequest.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/xml"]];
//    [betaRequest GET:@"http://streamcloud.zutrinken.com/streamcloud_beta.plist" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            if ([[responseObject objectForKey:@"beta_over"] boolValue]){
//                NSAlert *betaOverAlert = [[NSAlert alloc]init];
//                [betaOverAlert setMessageText:@"The BETA is over. Please get StreamCloud from the Mac AppStore"];
//                [betaOverAlert setAlertStyle:NSCriticalAlertStyle];
//                [betaOverAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
//                    exit(0);
//                }];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }];
//    
//    AFHTTPRequestOperationManager *updateRequest = [AFHTTPRequestOperationManager manager];
//    [updateRequest setResponseSerializer:[AFJSONResponseSerializer serializer]];
//    [updateRequest setRequestSerializer:[AFJSONRequestSerializer serializer]];
//    [updateRequest.requestSerializer setValue:@"b4fd6f9097c444e6ba32821c73b33b8d" forHTTPHeaderField:@"X-HockeyAppToken"];
//    [updateRequest GET:@"https://rink.hockeyapp.net/api/2/apps/749b642d520ae57bfe9101ce28da075c/app_versions" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            NSArray *appVersions = [responseObject objectForKey:@"app_versions"];
//            NSDictionary *newestVersion = [appVersions firstObject];
//            NSNumber *versionNumber = [newestVersion objectForKey:@"version"];
//            NSString *downloadURL = [newestVersion objectForKey:@"download_url"];
//            NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
//            NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
//            if (version.integerValue < versionNumber.integerValue) {
//                NSAlert *updateAlert = [[NSAlert alloc]init];
//                [updateAlert setMessageText:@"Their is a new BETA version available! Please update now!"];
//                [updateAlert setAlertStyle:NSCriticalAlertStyle];
//                [updateAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
//                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadURL]];
//                }];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error getting updates %@",error);
//    }];
//    

}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag){
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent;
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    
    BOOL handled = [SCSoundCloud handleRedirectURL:[NSURL URLWithString:url]];
    if (!handled) {
        NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
    } else {
        [self.tableView.enclosingScrollView setHidden:NO];
        [[SoundCloudAPIClient sharedClient] getInitialStreamSongs];
        if (!self.statusBarPlayerViewController){
            // Status Item
            self.statusBarPlayerViewController = [[StatusBarPlayerViewController alloc] initWithNibName:@"StatusBarPlayerViewController" bundle:nil];
            NSImage *normalImageForStatusBar = [NSImage imageNamed:@"menuBarIcon"];;
            NSImage *activeImageForStatusBar = [NSImage imageNamed:@"menuBarIcon_active"];
            self.statusItemPopup = [[AXStatusItemPopup alloc]initWithViewController:_statusBarPlayerViewController image:normalImageForStatusBar alternateImage:activeImageForStatusBar];
        }
    }
    
}


# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *itemForRow = [[SharedAudioPlayer sharedPlayer].itemsToShowInTableView objectAtIndex:row];
    NSDictionary *originDict = [itemForRow objectForKey:@"origin"];
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"MainColumn"]){
        if (![itemForRow objectForKey:@"playlist_track_is_from"]) {
            TrackCellView *viewforRow = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
            [viewforRow setRow:row];
            [viewforRow.artworkView setImage:[StreamCloudStyles imageOfSoundCloudLogoWithFrame:NSMakeRect(0, 0, 40, 18)]];
            BOOL useAvatar = YES;
            if ([[originDict objectForKey:@"artwork_url"] isKindOfClass:[NSString class]]) {
                if ([originDict objectForKey:@"artwork_url"] && ![[originDict objectForKey:@"artwork_url"]
                                                                  isEqualToString:@"<null>"]){
                    useAvatar = NO;
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFImageResponseSerializer serializer];
                    [manager GET:[originDict objectForKey:@"artwork_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [viewforRow.artworkView setImage:responseObject];
                        
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Failed to get image %@",error);
                    }];
                }
            }
            NSDictionary *userDict = [originDict objectForKey:@"user"];
            if ([[userDict objectForKey:@"avatar_url"] isKindOfClass:[NSString class]] && useAvatar) {
                if ([userDict objectForKey:@"avatar_url"] && ![[userDict objectForKey:@"avatar_url"] isEqualToString:@"<null>"]){
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFImageResponseSerializer serializer];
                    [manager GET:[userDict objectForKey:@"avatar_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [viewforRow.artworkView setImage:responseObject];
                        
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Failed to get image %@",error);
                    }];
                }
            }
            [viewforRow.titleLabel setStringValue:[originDict objectForKey:@"title"]];
            [viewforRow.artistLabel setStringValue:[userDict objectForKey:@"username"]];
            [viewforRow.durationLabel setStringValue:[self stringForSeconds:[[originDict objectForKey:@"duration"] longValue]/1000]];
            
            
            if (itemForRow == [SharedAudioPlayer sharedPlayer].currentItem && [SharedAudioPlayer sharedPlayer].audioPlayer.rate) {
                [viewforRow markAsPlaying:YES];
            } else {
                [viewforRow markAsPlaying:NO];
            }
            if ([[itemForRow objectForKey:@"type"] isEqualToString:@"playlist"]){
                NSDictionary *currentObject = [SharedAudioPlayer sharedPlayer].currentItem;
                if ([currentObject objectForKey:@"playlist_track_is_from"] == itemForRow &&  [SharedAudioPlayer sharedPlayer].audioPlayer.rate) {
                    [viewforRow markAsPlaying:YES];
                } else {
                    [viewforRow markAsPlaying:NO];
                }
            }
            return viewforRow;
        } else {
            TrackCellForPlaylistItemView *viewforRow = [tableView makeViewWithIdentifier:@"PlayListItemCell" owner:self];
            [viewforRow setRow:row];
            [viewforRow.artworkView setImage:[StreamCloudStyles imageOfSoundCloudLogoWithFrame:NSMakeRect(0, 0, 40, 18)]];
            BOOL useAvatar = YES;
            if ([[originDict objectForKey:@"artwork_url"] isKindOfClass:[NSString class]]) {
                if ([originDict objectForKey:@"artwork_url"] && ![[originDict objectForKey:@"artwork_url"]
                                                                  isEqualToString:@"<null>"]){
                    useAvatar = NO;
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFImageResponseSerializer serializer];
                    [manager GET:[originDict objectForKey:@"artwork_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [viewforRow.artworkView setImage:responseObject];
                        
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Failed to get image %@",error);
                    }];
                }
            }
            NSDictionary *userDict = [originDict objectForKey:@"user"];
            if ([[userDict objectForKey:@"avatar_url"] isKindOfClass:[NSString class]] && useAvatar) {
                if ([userDict objectForKey:@"avatar_url"] && ![[userDict objectForKey:@"avatar_url"] isEqualToString:@"<null>"]){
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFImageResponseSerializer serializer];
                    [manager GET:[userDict objectForKey:@"avatar_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [viewforRow.artworkView setImage:responseObject];
                        
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Failed to get image %@",error);
                    }];
                }
            }
            [viewforRow.titleLabel setStringValue:[originDict objectForKey:@"title"]];
            [viewforRow.artistLabel setStringValue:[userDict objectForKey:@"username"]];
            [viewforRow.durationLabel setStringValue:[self stringForSeconds:[[originDict objectForKey:@"duration"] longValue]/1000]];

            if (itemForRow == [SharedAudioPlayer sharedPlayer].currentItem && [SharedAudioPlayer sharedPlayer].audioPlayer.rate) {
                [viewforRow markAsPlaying:YES];
            } else {
                [viewforRow markAsPlaying:NO];
            }
            return viewforRow;
        }
    }
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSDictionary *itemForRow = [[SharedAudioPlayer sharedPlayer].itemsToShowInTableView objectAtIndex:row];
    if ([itemForRow objectForKey:@"playlist_track_is_from"]) {
        return 40;
    } else {
        return 80;
    }
}
# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[SharedAudioPlayer sharedPlayer] itemsToShowInTableView].count;
}

# pragma mark - NSTableView Click Handling

- (void)tableViewDoubleClick {
    NSInteger clickedRow = [self.tableView clickedRow];
    NSDictionary *clickedDict = [[[SharedAudioPlayer sharedPlayer] itemsToShowInTableView] objectAtIndex:clickedRow];
    if ([[clickedDict objectForKey:@"type"] isEqualToString:@"playlist"]){
        clickedDict = [[[SharedAudioPlayer sharedPlayer] itemsToShowInTableView] objectAtIndex:clickedRow+1];
    }
    
    NSInteger objectToPlay = [[[SharedAudioPlayer sharedPlayer] itemsToPlay] indexOfObject:clickedDict];
    [[SharedAudioPlayer sharedPlayer] jumpToItemAtIndex:objectToPlay];
    
}

# pragma mark - NSTableView Scroll Handling

-(void)tableViewDidScroll:(NSNotification *) notification
{
    NSScrollView *scrollView = [notification object];
    CGFloat currentPosition = CGRectGetMaxY([scrollView visibleRect]);
    CGFloat tableViewHeight = [self.tableView bounds].size.height - 100;
    
    //console.log("TableView Height: " + tableViewHeight);
    //console.log("Current Position: " + currentPosition);
    
    if ((currentPosition > tableViewHeight - 100) && !self.atBottom)
    {
        self.atBottom = YES;
        [[SharedAudioPlayer sharedPlayer] getNextSongs];
    } else if (currentPosition < tableViewHeight - 100) {
        self.atBottom = NO;
    }
}

# pragma mark - Update UI 

- (void)updateSlider {
    float timeGone = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentTime);
    float durationOfItem = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentItem.duration);
    //float timeToGo = durationOfItem - timeGone;
    [self.timeToGoLabel setStringValue:[self stringForSeconds:durationOfItem]];
    [self.timeGoneLabel setStringValue:[self stringForSeconds:timeGone]];
    if (!self.playerTimeSlider.clicked)
        [self.playerTimeSlider setDoubleValue:(timeGone/durationOfItem)*100];
}

- (void)updatePlayingItem {
    
    [self.statusBarPlayerViewController reloadImage];
    
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        [rowView setBackgroundColor:[NSColor whiteColor]];
        TrackCellView *cellForRow = [rowView viewAtColumn:0];
        [cellForRow markAsPlaying:NO];
    }];
    NSDictionary *currentItem = [SharedAudioPlayer sharedPlayer].currentItem;
    NSUInteger rowForItem = [[SharedAudioPlayer sharedPlayer].itemsToShowInTableView indexOfObject:currentItem];
    NSLog(@"Now playing song in row %lu",(unsigned long)rowForItem);
    NSTableRowView *rowView = [self.tableView rowViewAtRow:rowForItem makeIfNecessary:NO];
    [rowView setBackgroundColor:[StreamCloudStyles grayLight]];
    TrackCellView *cellForRow = [self.tableView viewAtColumn:0 row:rowForItem makeIfNecessary:NO];
    if (cellForRow){
        [cellForRow markAsPlaying:YES];
    }
    if ([currentItem objectForKey:@"playlist_track_is_from"]) {
        NSDictionary *fromPlaylistDict = [currentItem objectForKey:@"playlist_track_is_from"];
        NSUInteger rowForPlaylist = [[SharedAudioPlayer sharedPlayer].itemsToShowInTableView indexOfObject:fromPlaylistDict];
        NSLog(@"Marking playlist row %lu",(unsigned long)rowForPlaylist);
        NSTableRowView *playlistRowView = [self.tableView rowViewAtRow:rowForPlaylist makeIfNecessary:NO];
        [playlistRowView setBackgroundColor:[StreamCloudStyles grayLight]];
        TrackCellView *cellForPlaylistRow = [self.tableView viewAtColumn:0 row:rowForPlaylist makeIfNecessary:NO];
        if (cellForPlaylistRow){
            [cellForPlaylistRow markAsPlaying:YES];
        }

    }
    [self.tableView scrollRowToVisible:rowForItem];
}

- (void)didGetNewSongs:(NSNotification *)notification {
    [self.tableView reloadData];
    if (!self.statusItemPopup){
        // Status Item
        self.statusBarPlayerViewController = [[StatusBarPlayerViewController alloc] initWithNibName:@"StatusBarPlayerViewController" bundle:nil];
        NSImage *normalImageForStatusBar = [NSImage imageNamed:@"menuBarIcon"];;
        NSImage *activeImageForStatusBar = [NSImage imageNamed:@"menuBarIcon_active"];
        self.statusItemPopup = [[AXStatusItemPopup alloc]initWithViewController:_statusBarPlayerViewController image:normalImageForStatusBar alternateImage:activeImageForStatusBar];
    }
}

- (void)didFailToAuthenticate {
    [self.tableView.enclosingScrollView setHidden:YES];
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItemPopup.statusItem];
    self.statusItemPopup = nil;
    self.statusBarPlayerViewController = nil;
}

# pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"Close");
    [[NSUserDefaults standardUserDefaults] setInteger:self.useLastFMButton.state forKey:@"useLastFM"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastFMUserNameField.stringValue forKey:@"lastFMUserName"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastFMPasswordField.stringValue forKey:@"lastFMPassword"];
    
}

# pragma mark - Hotkeys

- (void)spaceBarPressed:(NSEvent *)event {
    [self playButtonAction:nil];
}

- (void)leftKeyPressed:(NSEvent *)event {
    [self previousButtonAction:nil];
}

- (void)rightKeyPressed:(NSEvent *)event {
    [self nextButtonAction:nil];
}

# pragma mark - IBActions

- (IBAction)playButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] togglePlayPause];
}

- (IBAction)previousButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] previousItem];
}

- (IBAction)nextButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] nextItem];
}

- (IBAction)shuffleButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] setShuffleEnabled:![SharedAudioPlayer sharedPlayer].shuffleEnabled];
}

- (IBAction)sliderUpdate:(id)sender {
    float durationOfItem = CMTimeGetSeconds([SharedAudioPlayer sharedPlayer].audioPlayer.currentItem.duration);
    double newValue = self.playerTimeSlider.doubleValue;
    float newTime = (newValue/100)*durationOfItem;
    NSLog(@"Seeking to time %f.0",newTime);
    [[SharedAudioPlayer sharedPlayer] advanceToTime:newTime];
}

- (IBAction)volumeSliderUpdate:(id)sender {
    [[SharedAudioPlayer sharedPlayer].audioPlayer setVolume:self.playerVolumeSlider.doubleValue/100];
    [self.volumeButton.cell setEnabled:NO];
    [self.volumeButton.cell setEnabled:YES];
}

- (IBAction)volumeButtonAction:(id)sender {
    [self.playerVolumeSlider setDoubleValue:[SharedAudioPlayer sharedPlayer].audioPlayer.volume*100];
    if (self.volumePopover.isShown){
        [self.volumePopover close];
    } else {
        [self.volumePopover showRelativeToRect:self.volumeButton.bounds ofView:self.volumeButton preferredEdge:NSMaxYEdge];
    }
}

- (IBAction)repeatButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] toggleRepeatMode];
}

- (IBAction)loginButtonAction:(id)sender {
    [[SoundCloudAPIClient sharedClient] login];
}

- (IBAction)logoutMenuAction:(id)sender {
    [[SoundCloudAPIClient sharedClient] logout];
}

- (IBAction)reloadMenuAction:(id)sender {
    [[SoundCloudAPIClient sharedClient] reloadTracks];
}

- (IBAction)showAboutMenuAction:(id)sender {
    [self.aboutPanel makeKeyAndOrderFront:sender];
}

- (IBAction)showSettingsMenuAction:(id)sender {
    [self.settingsPanel makeKeyAndOrderFront:sender];
    NSLog(@"Open");
    [self.useLastFMButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"useLastFM"]];
    [self.lastFMUserNameField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMUserName"]];
    [self.lastFMPasswordField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMPassword"]];
    if (self.useLastFMButton.state > 0){
        [self.useLastFMButton.cell setTitle:NSLocalizedString(@"Scrobbling", nil)];
    } else {
        [self.useLastFMButton.cell setTitle:NSLocalizedString(@"Not Scrobbling", nil)];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMSessionKey"]){
        [self.lastFMConnectionStateField setStringValue:NSLocalizedString(@"Connected", nil)];
    } else {
        [self.lastFMConnectionStateField setStringValue:NSLocalizedString(@"Not connected", nil)];
    }
}

- (IBAction)scrobbleStateSwitchAction:(id)sender {
    if (self.useLastFMButton.state == 0) {
        [self.lastFMConnectionStateField setStringValue:NSLocalizedString(@"Not connected", nil)];
        [self.useLastFMButton.cell setTitle:NSLocalizedString(@"Not Scrobbling", nil)];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastFMSessionKey"];
    } else {
        [[LastFm sharedInstance] getSessionForUser:self.lastFMUserNameField.stringValue password:self.lastFMPasswordField.stringValue successHandler:^(NSDictionary *result) {
            NSLog(@"Got LastFM Session");
            NSString *lastFMSessionKey = [result objectForKey:@"key"];
            if (lastFMSessionKey){
                [[NSUserDefaults standardUserDefaults] setObject:lastFMSessionKey forKey:@"lastFMSessionKey"];
                [self.lastFMConnectionStateField setStringValue:NSLocalizedString(@"Connected", nil)];
                [self.useLastFMButton.cell setTitle:NSLocalizedString(@"Scrobbling", nil)];
            } else {
                [self.lastFMConnectionStateField setStringValue:NSLocalizedString(@"Not connected", nil)];
                [self.useLastFMButton.cell setTitle:NSLocalizedString(@"Not Scrobbling", nil)];
                [self showAlertForLastFMFailure];
            }
        } failureHandler:^(NSError *error) {
            NSLog(@"No LastFM Session");
            [self.lastFMConnectionStateField setStringValue:NSLocalizedString(@"Not connected", nil)];
            [self.useLastFMButton.cell setTitle:NSLocalizedString(@"Not Scrobbling", nil)];
            [self showAlertForLastFMFailure];
        }];
    }
}

- (IBAction)lastFMUserPasswordFieldAction:(id)sender {

}

- (void)showAlertForLastFMFailure {
    NSAlert *lastFMAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"Could not get access to Last.FM!", nil) defaultButton:NSLocalizedString(@"Damn!", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:@"Maybe you entered a wrong username or password?"];
    [lastFMAlert runModal];
}

- (IBAction)openWebsiteFromHelpMenuAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://streamcloud.cc"]];
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
