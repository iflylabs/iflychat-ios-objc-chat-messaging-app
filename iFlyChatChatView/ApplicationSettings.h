//
//  ApplicationSettings.h
//  iFlyChatChatView
//
//  Created by iFlyLabs on 15/09/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ApplicationSettings : NSObject

+(ApplicationSettings *)getInstance;

-(void) setSendButtonText:(NSString *)sendText;
-(NSString *)getSendButtonText;

@end

