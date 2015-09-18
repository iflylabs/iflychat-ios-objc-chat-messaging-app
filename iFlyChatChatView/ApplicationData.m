//
//  ApplicationData.m
//  iFlyChatChatView
//
//  Created by Prateek Grover on 15/09/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import "ApplicationData.h"

@implementation ApplicationData

@synthesize session;
@synthesize config;
@synthesize authService;
@synthesize service;
@synthesize userList;
@synthesize roomList;
@synthesize loggedUser;
@synthesize sessionKey;
@synthesize userMessages;
@synthesize roomMessages;

//Singleton instance
static ApplicationData *instance = nil;


+(ApplicationData *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
