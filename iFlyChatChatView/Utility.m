//
//  ColorPicker.m
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 01/10/15.
//  Copyright © 2015 iFlyLabs. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+(NSString *) getNameWithoutPrefix:(NSString *)userName
{
    NSString *guestPrefix = [[[ApplicationData getInstance].config getChatSettings] objectForKey:@"guestPrefix"];
    
    userName = [userName substringFromIndex:guestPrefix.length];
    
    if([userName length] == 0)
    {
        return guestPrefix;
    }
    
    return userName;
}

+(UIColor *) getColorFromNameWithoutPrefix:(NSString *)userName
{
    UIColor *bgColor;
    char cString;
    int sumOfCString=0;
    int i=0;
    
    for(i=0;i<[userName length];i++)
    {
        cString = [userName characterAtIndex:i];
        sumOfCString += (int)cString;
    }
    
    int modOfSum = sumOfCString%6;
    
    switch (modOfSum) {
        case 0:
            bgColor = [UIColor colorWithRed:(84.0f/255.0f) green:(171.0f/255.0f) blue:(214.0f/255.0f) alpha:1.0f];
            break;
            
        case 1:
            bgColor = [UIColor colorWithRed:(209.0f/255.0f) green:(172.0f/255.0f) blue:(146.0f/255.0f) alpha:1.0f];
            break;
            
        case 2:
            bgColor = [UIColor colorWithRed:(98.0f/255.0f) green:(197.0f/255.0f) blue:(168.0f/255.0f) alpha:1.0f];
            break;
            
        case 3:
            bgColor = [UIColor colorWithRed:(249.0f/255.0f) green:(188.0f/255.0f) blue:(95.0f/255.0f) alpha:1.0f];
            break;
            
        case 4:
            bgColor = [UIColor colorWithRed:(224.0f/255.0f) green:(105.0f/255.0f) blue:(99.0f/255.0f) alpha:1.0f];
            break;
            
        case 5:
            bgColor = [UIColor colorWithRed:(199.0f/255.0f) green:(168.0f/255.0f) blue:(225.0f/255.0f) alpha:1.0f];
            break;
            
        default:
            bgColor = [UIColor colorWithRed:(84.0f/255.0f) green:(171.0f/255.0f) blue:(214.0f/255.0f) alpha:1.0f];
            break;
    }
    
    return bgColor;
}

+(NSString *) getLetterFromNameWithoutPrefix:(NSString *)userName
{
    NSString *userLetter;
    
    userLetter = [userName substringToIndex:1];
    userLetter = [userLetter uppercaseString];
    
    return userLetter;
}

@end
