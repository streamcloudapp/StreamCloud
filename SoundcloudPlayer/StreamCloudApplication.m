//
//  StreamCloudApplication.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 16.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "StreamCloudApplication.h"

@implementation StreamCloudApplication

- (void)sendEvent:(NSEvent *)event
{
	if ([event type] == NSKeyDown)
	{
		NSString *str = [event characters];
		if([str characterAtIndex:0] == 0x20) // spacebar
		{
			[super sendAction:@selector(spaceBarPressed:) to:nil from:self];
		}
          else if ([str characterAtIndex:0] == 0xF703) // right Arrow
        {
            [super sendAction:@selector(rightKeyPressed:) to:nil from:self];
        } else if ([str characterAtIndex:0] == 0xF702) // left Arrow
        {
            [super sendAction:@selector(leftKeyPressed:) to:nil from:self];
        }
        else                            // added this
			[super sendEvent:event];	 //
        
    }
    else // and this
        [super sendEvent:event];
}

@end
