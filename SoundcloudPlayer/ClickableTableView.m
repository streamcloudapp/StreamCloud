//
//  ClickableTableView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 29.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ClickableTableView.h"

@implementation ClickableTableView

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if ([theEvent clickCount] == 1  ) {
        NSPoint selfPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
        NSInteger row = [self rowAtPoint:selfPoint];
        if (row>=0) [[self viewAtColumn:0 row:row makeIfNecessary:NO]
                     mouseDown:theEvent];
    }
}


@end
