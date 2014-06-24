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

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSSlider *playerTimeSlider;
@property (nonatomic, strong) IBOutlet NSTextField *timeToGoLabel;
@property (nonatomic, strong) IBOutlet NSTextField *timeGoneLabel;
@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) AXStatusItemPopup *statusItemPopup;
@property (nonatomic, strong) StatusBarPlayerViewController *statusBarPlayerViewController;
@end
