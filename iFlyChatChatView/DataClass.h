//
//  DataClass.h
//  iFlyChatGlobalListView
//
//  Created by Prateek Grover on 30/07/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
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

-(void) disconnect;

@end
