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
#import "NSImage+RoundedCorners.h"
#import "StreamCloudStyles.h"
#import "SoundCloudTrack.h"
#import "SoundCloudUser.h"

@implementation StatusBarPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){

    }
    return self;
}

- (void)awakeFromNib {
    [self.coverArtImageView setImage:[StreamCloudStyles imageOfSoundCloudLogoWithFrame:NSMakeRect(0, 0, 320, 320)]];
    [self.overlayImageView setImage:[StreamCloudStyles imageOfImageOverlayGradientViewWithFrame:NSMakeRect(0, 0, 320, 320)]];

    [self reloadImage];
}

- (void)reloadImage {
    SoundCloudTrack *currentObject = [SharedAudioPlayer sharedPlayer].currentItem;
    if (currentObject) {
        [self.trackLabel setStringValue:currentObject.title];
        BOOL useAvatar = YES;
        if (currentObject.artworkUrl){
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            useAvatar = NO;
            NSString *artworkURL = currentObject.artworkUrl.absoluteString;
            artworkURL = [artworkURL stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [manager GET:artworkURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.coverArtImageView setImage:[responseObject roundCornersImageCornerRadius:4]];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed to get image %@",error);
            }];
            
        }
        [self.artistLabel setStringValue:currentObject.user.username];
        if (useAvatar && currentObject.user.avatarUrl){
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            NSString *avatarURL = currentObject.user.avatarUrl.absoluteString;
            avatarURL = [avatarURL stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [manager GET:avatarURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.coverArtImageView setImage:[responseObject roundCornersImageCornerRadius:4]];
                
                
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
