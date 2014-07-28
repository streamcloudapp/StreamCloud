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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
			[super sendAction:@selector(spaceBarPressed:) to:nil from:self];
# pragma clang diagnostic pop
		}
          else if ([str characterAtIndex:0] == 0xF703) // right Arrow
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [super sendAction:@selector(rightKeyPressed:) to:nil from:self];
# pragma clang diagnostic pop
        } else if ([str characterAtIndex:0] == 0xF702) // left Arrow
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [super sendAction:@selector(leftKeyPressed:) to:nil from:self];
# pragma clang diagnostic pop
        }
        else                            // added this
			[super sendEvent:event];	 //
        
    }
# pragma clang diagnostic pop
    else // and this
        [super sendEvent:event];
}

@end
