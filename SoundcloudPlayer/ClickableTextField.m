//
//  ClickableTextField.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 29.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ClickableTextField.h"

@interface ClickableTextField ()

@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation ClickableTextField

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.urlToOpen){
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_urlToOpen]];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if (self.urlToOpen) {
        [[NSCursor pointingHandCursor] set];
        NSMutableAttributedString *str = [[self attributedStringValue] mutableCopy];
        
        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
        
        [self setAttributedStringValue:str];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    if (self.urlToOpen) {
        [[NSCursor arrowCursor] set];
        NSMutableAttributedString *str = [[self attributedStringValue] mutableCopy];
        
        [str removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, str.length)];
        
        [self setAttributedStringValue:str];
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self removeTrackingArea:_trackingArea];
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow) owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

@end
