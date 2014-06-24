//
//  StatusBarPlayerViewController.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusBarPlayerViewController : NSViewController

@property (nonatomic ,strong) IBOutlet NSImageView *coverArtImageView;
@property (nonatomic, strong) IBOutlet NSTextField *artistLabel;
@property (nonatomic, strong) IBOutlet NSTextField *trackLabel;
@property (nonatomic, strong) IBOutlet NSImageView *overlayImageView;
- (IBAction)playPauseButtonAction:(id)sender;
- (IBAction)nextButtonAction:(id)sender;
- (IBAction)previousButtonAction:(id)sender;
- (IBAction)shuffleButtonAction:(id)sender;
- (IBAction)repeatButtonAction:(id)sender;
- (void)reloadImage;
@end
