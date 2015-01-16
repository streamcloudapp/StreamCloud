//
//  SoundCloudUser.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "SoundCloudUser.h"

@implementation SoundCloudUser

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self){
        if ([[dict objectForKey:@"avatar_url"] isKindOfClass:[NSString class]])
            self.avatarUrl = [NSURL URLWithString:[dict objectForKey:@"avatar_url"]];
        self.identifier = [dict objectForKey:@"id"];
        self.kind = [dict objectForKey:@"kind"];
        self.lastModified = [NSDate date];
        self.permalink = [dict objectForKey:@"permalink"];
        if ([[dict objectForKey:@"permalink_url"] isKindOfClass:[NSString class]])
            self.permalinkUrl = [NSURL URLWithString:[dict objectForKey:@"permalink_url"]];
        if ([[dict objectForKey:@"uri"] isKindOfClass:[NSString class]])
            self.userUri = [NSURL URLWithString:[dict objectForKey:@"uri"]];
        self.username = [dict objectForKey:@"username"];
    }
    return self;
}


+ (SoundCloudUser *)userForDict:(NSDictionary *)dict {
    SoundCloudUser *userToReturn = [[SoundCloudUser alloc]initWithDict:dict];
    return userToReturn;
}
@end
