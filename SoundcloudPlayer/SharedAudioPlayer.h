//
//  SharedAudioPlayer.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 21.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@interface SharedAudioPlayer : NSObject <AVAudioPlayerDelegate>

+ (SharedAudioPlayer *)sharedPlayer;
- (void)insertItemsFromResponse:(NSDictionary *)response;
- (void)togglePlayPause;
- (void)nextItem;
@end
