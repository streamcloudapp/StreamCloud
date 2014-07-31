//
//  StatusBarPlayerViewController.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 24.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import "StatusBarPlayerViewController.h"
#import "SharedAudioPlayer.h"
#import "AFNetworking.h"
#import "StreamCloudStyles.h"

@implementation StatusBarPlayerViewController

- (void)awakeFromNib {
    [self.coverArtImageView setImage:[StreamCloudStyles imageOfSoundCloudLogoWithFrame:NSMakeRect(0, 0, 320, 320)]];
    [self.overlayImageView setImage:[StreamCloudStyles imageOfImageOverlayGradientViewWithFrame:NSMakeRect(0, 0, 320, 320)]];
    [self reloadImage];
}

- (void)reloadImage {
    NSDictionary *currentObject = [SharedAudioPlayer sharedPlayer].currentItem;
    NSDictionary *originDict = [currentObject objectForKey:@"track"];
    [self.trackLabel setStringValue:[originDict objectForKey:@"title"]];
    BOOL useAvatar = YES;
    if ([[originDict objectForKey:@"artwork_url"] isKindOfClass:[NSString class]]) {
        if ([originDict objectForKey:@"artwork_url"] && ![[originDict objectForKey:@"artwork_url"]
                                                          isEqualToString:@"<null>"]){
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            useAvatar = NO;
            NSString *artworkURL = [originDict objectForKey:@"artwork_url"];
            artworkURL = [artworkURL stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [manager GET:artworkURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.coverArtImageView setImage:responseObject];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed to get image %@",error);
            }];
        }
    }
    NSDictionary *userDict = [originDict objectForKey:@"user"];
    [self.artistLabel setStringValue:[userDict objectForKey:@"username"]];
    if ([[userDict objectForKey:@"avatar_url"] isKindOfClass:[NSString class]] && useAvatar) {
        if ([userDict objectForKey:@"avatar_url"] && ![[userDict objectForKey:@"avatar_url"] isEqualToString:@"<null>"]){
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            NSString *avatarURL = [userDict objectForKey:@"avatar_url"];
            avatarURL = [avatarURL stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [manager GET:avatarURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.coverArtImageView setImage:responseObject];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed to get image %@",error);
            }];
        }
    }

}

# pragma mark - IBActions

- (IBAction)playPauseButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] togglePlayPause];
}
- (IBAction)nextButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] nextItem];
}
- (IBAction)previousButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] previousItem];
}
- (IBAction)shuffleButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] setShuffleEnabled:![SharedAudioPlayer sharedPlayer].shuffleEnabled];
}
- (IBAction)repeatButtonAction:(id)sender {
    [[SharedAudioPlayer sharedPlayer] toggleRepeatMode];
}

@end
