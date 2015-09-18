//
//  DataClass.m
//  iFlyChatGlobalListView
//
//  Created by Prateek Grover on 30/07/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import "DataClass.h"

@implementation DataClass

ApplicationData *appData;

@synthesize updatedRoomList;
@synthesize updatedUserList;

//Singleton instance
static DataClass *instance = nil;


+(DataClass *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        appData = [ApplicationData getInstance];
        
        //Registering for notification for global list update from iFlyChatLibrary
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(updateGlobalList:) name:@"iFlyChat.onGlobalListUpdate" object:nil];
        
    });
    
    return instance;
}

//Intialisation of chat
-(void) initiFlyChatLibrary
{
    //iFlyChatUserSession object with username, password and session key (if available)

    appData.session = [[iFlyChatUserSession alloc] initIFlyChatUserSessionwithUserName:@"userName" userPassword:@"userPassword" userSessionKey:@""];
    
    //iFlyChatConfig object with server host, auth URL, SSL connection boolean and iFlyChatUserSession object. These are the basic configuration parameters used to connect to iFlyChat's servers
    
    appData.config = [[iFlyChatConfig alloc] initIFlyChatConfigwithServerHost:@"serverhost.com" authUrl:@"http://example.com/auth/url" isHttps:NO userSession:appData.session];
    
    //If auto reconnection is required, set it to "YES"
    
    [appData.config setAutoReconnect:YES];
    
    //iFlyChatUserAuthService object that check and gets the new session key if not available or if the one provided is invalid or expired
    
    appData.authService = [[iFlyChatUserAuthService alloc] initIFlyChatUserAuthServiceWithConfig:appData.config userSession:appData.session];
    
    //iFlyChatService object that performs most of the operations
    if(appData.service != nil)
    {
        if([[appData.service getChatState] isEqualToString:@"closed"])
        {
            [appData.service connectChat];
        }
    }
    else
    {
        appData.service = [[iFlyChatService alloc] initIFlyChatServicewithConfig:appData.config session:appData.session userAuthService:appData.authService];
        
        //Asking iFlyChatService object to initiate connection
        
        [appData.service connectChat];
    }
}

//This method is called when "iFlyChat.onGlobalListUpdate" notification is received
-(void) updateGlobalList:(NSNotification *)notif
{
    //Taking out the iFlyChatRoster object from the notification
    iFlyChatRoster *updatedRoster = [notif object];
    
    //Getting the userList from the roster object
    appData.userList = [updatedRoster getUserList];
    
    //setting the boolean so as to indicate whether the userlist is updated or not
    self.updatedUserList = YES;
    
    appData.roomList = [updatedRoster getRoomList];
    self.updatedRoomList = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onUpdatedGlobalList" object:nil];
}

-(iFlyChatOrderedDictionary *)getUpdatedUserList
{
    self.updatedUserList = NO;

    return appData.userList;
}

-(iFlyChatOrderedDictionary *)getUpdatedRoomList
{
    self.updatedRoomList = NO;

    return appData.roomList;
}

-(void) setUpdatedUserListBool:(BOOL)updatedUserListBool
{
    self.updatedUserList = updatedUserListBool;
}

-(void) setUpdatedRoomListBool:(BOOL)updatedRoomListBool
{
    self.updatedRoomList = updatedRoomListBool;
}

-(void)sendMessageToUser:(iFlyChatMessage *)message
{
    [appData.service sendMessagetoUser:message];
}

-(void)sendMessageToRoom:(iFlyChatMessage *)message
{
    [appData.service sendMessagetoRoom:message];
}


-(void) disconnect
{
    [appData.service disconnectChat];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
