//
//  TrackCellForPlaylistItemView.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 28.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrackCellView.h"
#import "SeperatorView.h"
#import "UpperShadowView.h"
#import "LowerShadowView.h"

@interface TrackCellForPlaylistItemView : TrackCellView

@property (nonatomic, strong) IBOutlet SeperatorView *seperatorView;
@property (nonatomic, strong) IBOutlet UpperShadowView *upperShadowView;
@property (nonatomic, strong) IBOutlet LowerShadowView *lowerShadowView;

@end
