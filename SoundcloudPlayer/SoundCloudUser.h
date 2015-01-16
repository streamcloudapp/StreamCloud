//
//  SoundCloudUser.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundCloudUser : NSObject

@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSString *permalink;
@property (nonatomic, strong) NSURL *permalinkUrl;
@property (nonatomic ,strong) NSURL *userUri;
@property (nonatomic, strong) NSString *username;

+ (SoundCloudUser *)userForDict:(NSDictionary *)dict;

@end
