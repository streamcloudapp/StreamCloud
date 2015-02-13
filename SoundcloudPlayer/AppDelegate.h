//
//  AppDelegate.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 20.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AXStatusItemPopup.h"
#import "StatusBarPlayerViewController.h"
#import "ProgressSliderView.h"
#import "MASShortcutView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate,NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet ProgressSliderView *playerTimeSlider;
@property (nonatomic, strong) IBOutlet NSTextField *timeToGoLabel;
@property (nonatomic, strong) IBOutlet NSTextField *timeGoneLabel;
@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSSlider *playerVolumeSlider;
@property (nonatomic, strong) IBOutlet NSPopover *volumePopover;
@property (nonatomic, strong) IBOutlet NSButton *volumeButton;
@property (nonatomic, strong) AXStatusItemPopup *statusItemPopup;
@property (nonatomic, strong) StatusBarPlayerViewController *statusBarPlayerViewController;
@property (nonatomic) BOOL atBottom;
@property (nonatomic, strong) IBOutlet NSPanel *aboutPanel;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *switchStreamLikesSegmentedControl;
@property (nonatomic) NSInteger currentlySelectedStream;

@property (nonatomic, strong) IBOutlet NSPanel *settingsPanel;
@property (nonatomic, strong) IBOutlet NSTextField *lastFMUserNameField;
@property (nonatomic, strong) IBOutlet NSTextField *lastFMPasswordField;
@property (nonatomic, strong) IBOutlet NSButton *useLastFMButton;
@property (nonatomic, strong) IBOutlet NSTextField *lastFMConnectionStateField;
@property (nonatomic, strong) IBOutlet MASShortcutView *playPauseShortcutView;
@property (nonatomic, strong) IBOutlet MASShortcutView *prevShortcutView;
@property (nonatomic, strong) IBOutlet MASShortcutView *nextShortcutView;

@property (nonatomic, strong) IBOutlet NSMenuItem *trackNameDockMenuItem;

@property (nonatomic, strong) IBOutlet NSTextField *loginTextField;
@property (nonatomic, strong) IBOutlet NSButton *loginButton;

@end
