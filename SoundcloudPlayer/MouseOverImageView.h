//
//  MouseOverImageView.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 26.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MouseOverImageView : NSImageView

@property (nonatomic) NSInteger row;
@property (nonatomic) NSDictionary *objectToPlay;
@property (nonatomic) BOOL showLargePlayPauseView;
@property (nonatomic) BOOL playing;
@end
