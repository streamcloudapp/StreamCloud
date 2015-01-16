//
//  IsRepostedLabelView.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 16.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "IsRepostedLabelView.h"
#import "StreamCloudStyles.h"

@implementation IsRepostedLabelView

- (void)drawRect:(NSRect)dirtyRect {
    [StreamCloudStyles drawTrackIsRepostWithFrame:NSMakeRect(0.5, 1.5, 9, 9)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.reposterName drawInRect:NSMakeRect(13, -0.5, CGRectGetWidth(self.frame)-CGRectGetHeight(self.frame)-4, 15) withAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue" size:10],NSForegroundColorAttributeName:[StreamCloudStyles grayMediumLight],NSParagraphStyleAttributeName:paragraphStyle}];
    
}

- (void)setReposterName:(NSString *)reposterName {
    _reposterName = reposterName;
    [self setNeedsDisplay:YES];
}

@end
