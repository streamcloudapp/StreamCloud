//
//  SettingsViewController.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 22.05.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcutView.h"

@interface SettingsViewController : NSViewController

@property (nonatomic, strong) IBOutlet NSTextField *lastFMUserNameField;
@property (nonatomic, strong) IBOutlet NSTextField *lastFMPasswordField;
@property (nonatomic, strong) IBOutlet NSButton *useLastFMButton;
@property (nonatomic, strong) IBOutlet NSTextField *lastFMConnectionStateField;
@property (nonatomic, strong) IBOutlet MASShortcutView *playPauseShortcutView;
@property (nonatomic, strong) IBOutlet MASShortcutView *prevShortcutView;
@property (nonatomic, strong) IBOutlet MASShortcutView *nextShortcutView;

@end
