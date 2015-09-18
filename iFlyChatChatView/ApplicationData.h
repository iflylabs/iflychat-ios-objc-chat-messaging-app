//
//  ApplicationData.h
//  iFlyChatChatView
//
//  Created by iFlyLabs on 15/09/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iFlyChatLibrary/iFlyChatLibrary.h"

@interface ApplicationData : NSObject

+(ApplicationData *)getInstance;

@property (strong, nonatomic) iFlyChatConfig *config;
@property (strong, nonatomic) iFlyChatUserSession *session;
@property (strong, nonatomic) iFlyChatService *service;
@property (strong, nonatomic) iFlyChatUserAuthService *authService;
@property (strong, nonatomic) iFlyChatUser *loggedUser;
@property (strong, nonatomic) NSString *sessionKey;
@property (strong, nonatomic) iFlyChatOrderedDictionary *userList;
@property (strong, nonatomic) iFlyChatOrderedDictionary *roomList;
@property (strong, nonatomic) NSMutableDictionary *userMessages;
@property (strong, nonatomic) NSMutableDictionary *roomMessages;

@end
