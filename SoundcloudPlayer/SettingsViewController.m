//
//  SettingsViewController.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 22.05.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "SettingsViewController.h"
#import "LastFm.h"
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"
#import "AppDelegate.h"



@implementation SettingsViewController

- (void)viewWillAppear {
    [self.useLastFMButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"useLastFM"]];
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMUserName"])
        [self.lastFMUserNameField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMUserName"]];
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"lastFMPassword"])
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
    
    self.playPauseShortcutView.associatedUserDefaultsKey = @"PlayPauseShortcut";
    
    self.nextShortcutView.associatedUserDefaultsKey = @"NextShortcut";

    self.prevShortcutView.associatedUserDefaultsKey = @"PreviousShortcut";
    
}

- (void)viewDidDisappear {
    [[NSUserDefaults standardUserDefaults] setInteger:self.useLastFMButton.state forKey:@"useLastFM"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastFMUserNameField.stringValue forKey:@"lastFMUserName"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastFMPasswordField.stringValue forKey:@"lastFMPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

@end
