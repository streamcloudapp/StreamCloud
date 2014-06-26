//
//  MouseOverImageView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 26.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "MouseOverImageView.h"

@implementation MouseOverImageView

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
    
    // Drawing code here.
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverImageEntered" object:nil];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverImageExited" object:nil];
}

@end
