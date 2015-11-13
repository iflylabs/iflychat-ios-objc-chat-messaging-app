//
//  ColorPicker.h
//  iFlyChatGlobalListView
//
//  Created by iFlyLabs on 01/10/15.
//  Copyright © 2015 iFlyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ApplicationData.h"

@interface Utility : NSObject

+(NSString *) getNameWithoutPrefix:(NSString *)userName;

+(UIColor *) getColorFromNameWithoutPrefix:(NSString *)userName;

+(NSString *) getLetterFromNameWithoutPrefix:(NSString *)userName;

@end
