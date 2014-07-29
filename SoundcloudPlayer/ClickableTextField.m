//
//  ClickableTextField.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 29.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ClickableTextField.h"

@implementation ClickableTextField

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.urlToOpen){
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_urlToOpen]];
    }
}

@end
