//
//  WhiteBackgroundView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 25.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "WhiteBackgroundView.h"

@implementation WhiteBackgroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
