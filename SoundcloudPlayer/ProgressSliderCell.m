//
//  ProgressSliderCell.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 26.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "ProgressSliderCell.h"
#import "StreamCloudStyles.h"
@implementation ProgressSliderCell

- (void)drawKnob:(NSRect)knobRect {
    [StreamCloudStyles drawProgressSliderKnobWithFrame:knobRect];
}

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped {
    [StreamCloudStyles drawProgressSliderTrackWithFrame:aRect];
    
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawInteriorWithFrame:cellFrame inView:controlView];
    NSRect trackRect = NSMakeRect(3, 6, controlView.frame.size.width-6,7);
    [StreamCloudStyles drawProgressSliderTrackWithFrame:trackRect];
    if (self.doubleValue > 0) {
        NSRect leftRect = NSMakeRect(3.5, -0.5, ((controlView.frame.size.width-7)*(self.doubleValue/100)), 20);
        [StreamCloudStyles drawProgressSliderProgressWithFrame:NSIntegralRect(leftRect)];
    } else {
        NSRect leftRect = NSMakeRect(3.5, -0.5, 2, 20);
        [StreamCloudStyles drawProgressSliderProgressWithFrame:NSIntegralRect(leftRect)];
    }
    [self drawKnob];
}

@end
