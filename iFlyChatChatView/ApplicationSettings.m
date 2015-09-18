//
//  ApplicationSettings.m
//  iFlyChatChatView
//
//  Created by iFlyLabs on 15/09/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import "ApplicationSettings.h"



@implementation ApplicationSettings

NSString *sendButtonText;


//Singleton instance
static ApplicationSettings *instance = nil;


+(ApplicationSettings *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        sendButtonText = @"Send";
    });
    
    return instance;
}


-(void) setSendButtonText:(NSString *)sendText
{
    sendButtonText = sendText;
}


-(NSString *)getSendButtonText
{
    return sendButtonText;
}


@end
