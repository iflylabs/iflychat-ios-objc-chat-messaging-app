//
//  ViewController.m
//  iFlyChatChatView
//
//  Created by iFlyLabs on 08/09/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController
{
    ApplicationData *appData;
}

-(void) viewDidLoad
{
    //Getting singleton instance of ApplicationData
    appData = [ApplicationData getInstance];
}

-(void) viewWillAppear:(BOOL)animated
{
    //Adding observers for required notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatConnect:) name:@"iFlyChat.onChatConnect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSessionKey:) name:@"iFlyChat.onGetSessionKey" object:nil];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) chatConnect:(NSNotification *)notification
{
    //Assigning the loggedUser data to the loggedUser variable in application data
    NSDictionary *dict = [notification object];
    appData.loggedUser = [dict objectForKey:@"iFlyChatCurrentUser"];
}

-(void) gotSessionKey:(NSNotification *)notification
{
    //Assigning session key
    appData.sessionKey = [notification object];
}

-(IBAction)connectChat:(id)sender
{
    //On pressing connect chat, push ChatViewController to the navigation controller
    ChatViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    [[self navigationController] pushViewController:cvc animated:YES];
}



@end
