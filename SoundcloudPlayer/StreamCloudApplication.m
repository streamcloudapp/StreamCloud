//
//  StreamCloudApplication.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 16.07.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "StreamCloudApplication.h"
#define SPSystemDefinedEventMediaKeys 8
#define NX_KEYTYPE_PLAY 16
#define NX_KEYTYPE_NEXT 17
#define NX_KEYTYPE_PREVIOUS 18
#define NX_KEYTYPE_FAST 19
#define NX_KEYTYPE_REWIND 20

@implementation StreamCloudApplication

- (void)sendEvent:(NSEvent *)event
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
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
        
    } else if ([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys) {
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
        BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
        int keyRepeat = (keyFlags & 0x1);
        if (keyIsPressed && keyRepeat == 0) {
            switch (keyCode) {
                case NX_KEYTYPE_PLAY:
                    [super sendAction:@selector(spaceBarPressed:) to:nil from:self];
                    break;
                case NX_KEYTYPE_NEXT:
                case NX_KEYTYPE_FAST:
                    [super sendAction:@selector(rightKeyPressed:) to:nil from:self];
                    break;
                case NX_KEYTYPE_PREVIOUS:
                case NX_KEYTYPE_REWIND:
                    [super sendAction:@selector(leftKeyPressed:) to:nil from:self];
                    break;
                default:
                    break;
            }
        }
    }
    else // and this
        [super sendEvent:event];
# pragma clang diagnostic pop
}

@end
