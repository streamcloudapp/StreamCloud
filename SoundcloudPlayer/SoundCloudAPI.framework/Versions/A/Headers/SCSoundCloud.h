/*
 * Copyright 2010, 2011 nxtbgthng for SoundCloud Ltd.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * For more information and documentation refer to
 * http://soundcloud.com/api
 * 
 */

#import <Foundation/Foundation.h>

#pragma mark Notifications

extern NSString * const SCSoundCloudAccountDidChangeNotification;
extern NSString * const SCSoundCloudDidFailToRequestAccessNotification;


#pragma mark Handler

typedef void(^SCPreparedAuthorizationURLHandler)(NSURL *preparedURL);


#pragma mark -

@class SCAccount;

@interface SCSoundCloud : NSObject

#pragma mark Accessors

+ (SCAccount *)account;


#pragma mark Manage Accounts

+ (void)requestAccessWithPreparedAuthorizationURLHandler:(SCPreparedAuthorizationURLHandler)aPreparedAuthorizationURLHandler;
+ (void)removeAccess;


#pragma mark Configuration

+ (void)setClientID:(NSString *)aClientID
             secret:(NSString *)aSecret
        redirectURL:(NSURL *)aRedirectURL;

#pragma mark OAuth2 Flow

+ (BOOL)handleRedirectURL:(NSURL *)URL;

@end
