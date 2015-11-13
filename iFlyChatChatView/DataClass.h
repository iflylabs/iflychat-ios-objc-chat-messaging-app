//
//  DataClass.h
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 30/07/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationData.h"
#import "iFlyChatLibrary/iFlyChatLibrary.h"

@interface DataClass : NSObject

@property (nonatomic, assign) BOOL updatedUserList;

@property (nonatomic, assign) BOOL updatedRoomList;

+(DataClass *)getInstance;

-(void) initiFlyChatLibrary;

-(iFlyChatOrderedDictionary *)getUpdatedUserList;

-(iFlyChatOrderedDictionary *)getUpdatedRoomList;

-(void)sendMessageToUser:(iFlyChatMessage *)message;

-(void)sendMessageToRoom:(iFlyChatMessage *)message;

-(void)sendFileToUser:(iFlyChatMessage *)message;

-(void)sendFileToRoom:(iFlyChatMessage *)message;

-(void)getUserThreadHistoryWithCurrentUserId:(NSString *)currentUserId
                                   forUserId:(NSString *)forUserId
                                 forUserName:(NSString *)forUserName
                                   messageId:(NSString *)messageId;

-(void)getRoomThreadHistoryWithCurrentUserId:(NSString *)currentUserId
                                   forRoomId:(NSString *)forRoomId
                                 forRoomName:(NSString *)forRoomName
                                   messageId:(NSString *)messageId;

-(void) disconnect;

@end
