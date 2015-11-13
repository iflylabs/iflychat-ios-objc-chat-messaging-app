//
//  ChatViewController.m
//  test
//
//  Created by iFlyLabs on 06/04/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "ContentView.h"
#import "DataClass.h"
#import "Utility.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import MobileCoreServices;
#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

@interface ChatViewController () <UITextViewDelegate,UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>

@property (nonatomic,strong) ChatTableViewCell *chatCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarUserLetterLabelHeight;
@property (nonatomic,strong) iFlyChatUser *messageUser;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarUserLetterLabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *navBarUserLetterLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarUserImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarUserImageViewWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImageHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImageWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatStatusHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *chatStatusView;

@property (weak, nonatomic) IBOutlet UILabel *chatStatus;


@property (strong, nonatomic) ContentView *handler;

@property (strong, nonatomic) iFlyChatOrderedDictionary *currentMessages;

@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgress;

@end

@implementation ChatViewController
{
    NSCache *userImageCache;
    dispatch_queue_t fetchImage;
    
    DataClass *dtclass;
    ApplicationData *appData;
    ApplicationSettings *appSettings;
    ChatCellSettings *chatCellSettings;
    
    NSString *USERID;
    NSString *USERNAME;
    NSString *ROOMID;
    NSString *ROOMNAME;
    
    BOOL imageAlreadySetFlag;
    
    BOOL receivedMessageGetImage;
    
    BOOL use_default_avatar;
    
    BOOL newMedia;
    
    UIImagePickerController *ipc;
    UIPopoverController *popover;
    UIImageView *ivImage;
    UIRefreshControl *loadMoreMessagesControl;
    
    dispatch_once_t setNavBarImage;
    dispatch_once_t getLatestThreadHistory;
}

@synthesize chatTable;
@synthesize sendButton;
@synthesize messageText;
@synthesize userImage;
@synthesize chatCell;
@synthesize messageUser;
@synthesize currentMessages;

-(void) viewDidLoad
{
    //Getting singleton instances of the required classes
    dtclass = [DataClass getInstance];
    appData = [ApplicationData getInstance];
    appSettings = [ApplicationSettings getInstance];
    chatCellSettings = [ChatCellSettings getInstance];
    
    /**
     *  Set settings for Application. They are available in ChatCellSettings class.
     */
    
    //[chatCellSettings setSenderBubbleColor:[UIColor colorWithRed:0 green:(122.0f/255.0f) blue:1.0f alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleColor:[UIColor colorWithRed:(223.0f/255.0f) green:(222.0f/255.0f) blue:(229.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setSenderBubbleNameTextColor:[UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleNameTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]];
    //[chatCellSettings setSenderBubbleMessageTextColor:[UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleMessageTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]];
    //[chatCellSettings setSenderBubbleTimeTextColor:[UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleTimeTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]];
    
    [chatCellSettings setSenderBubbleColorHex:@"007AFF"];
    [chatCellSettings setReceiverBubbleColorHex:@"DFDEE5"];
    [chatCellSettings setSenderBubbleNameTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleNameTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleMessageTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleMessageTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleTimeTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleTimeTextColorHex:@"000000"];
    
    [chatCellSettings setSenderBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:11]];
    [chatCellSettings setReceiverBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:14]];
    [chatCellSettings setSenderBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:14]];
    [chatCellSettings setReceiverBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:17]];
    [chatCellSettings setSenderBubbleFontWithSizeForTime:[UIFont systemFontOfSize:11]];
    [chatCellSettings setReceiverBubbleFontWithSizeForTime:[UIFont systemFontOfSize:14]];
    
    [chatCellSettings senderBubbleTailRequired:YES];
    [chatCellSettings receiverBubbleTailRequired:YES];
    
    //Setting the send button text. This is available in ApplicationSettings class
    [appSettings setSendButtonText:@"Send"];

    
    //Initializing the NSMutableDictionaries to save messages for user and room
    appData.userMessages = [[NSMutableDictionary alloc] init];
    appData.roomMessages = [[NSMutableDictionary alloc] init];
    currentMessages = [[iFlyChatOrderedDictionary alloc] init];
    
    receivedMessageGetImage = NO;
    
    use_default_avatar = NO;
    
    newMedia = NO;
    
    setNavBarImage = 0;
    getLatestThreadHistory = 0;
    
    
    /**
     *  Configure chat here. Keep the USERID and USERNAME empty and fill in ROOMID and ROOMNAME if you need to chat in a room and vice-versa
     */
    
    USERID = @"";
    ROOMID = @"0";
    USERNAME = @"";
    ROOMNAME = @"Public Chatroom";
    
    //Setting the title and image according what is selected above
    if(![USERID isEqualToString:@""])
    {
        self.navigationItem.title = USERNAME;
        
        //If the message dictionary is not set for this particular room then set it otherwise assign the already set message dictionary
        if([appData.userMessages objectForKey:USERID]==nil)
        {
            [appData.userMessages setObject:currentMessages forKey:USERID];
        }
        else
        {
            currentMessages = [appData.userMessages objectForKey:USERID];
        }
    }
    else
    {
        self.navigationItem.title = ROOMNAME;
        self.navBarUserImageView.image = [UIImage imageNamed:@"ChatRoom"];
        self.navBarUserImageView.backgroundColor = [Utility getColorFromNameWithoutPrefix:ROOMNAME];
        [self.navBarUserLetterLabel setHidden:YES];
        
        //If the message dictionary is not set for this particular room then set it otherwise assign the already set message dictionary
        if([appData.roomMessages objectForKey:ROOMID]==nil)
        {
            [appData.roomMessages setObject:currentMessages forKey:ROOMID];
        }
        else
        {
            currentMessages = [appData.roomMessages objectForKey:ROOMID];
        }
    }
    
    //Setting the flag that checks if the image on the navigation bar is set or not
    imageAlreadySetFlag=NO;
    
    //Setting the send button title
    [sendButton setTitle:[appSettings getSendButtonText] forState:UIControlStateNormal];
    
    [sendButton setEnabled:NO];
    
    self.messageText.delegate = self;
    
    self.chatStatusView.backgroundColor = [UIColor redColor];
    [self.chatStatus setText:@"Not Connected"];
    

    [[self chatTable] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //Registering custom Chat table view cell for both sending and receiving
    [[self chatTable] registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatSend"];

    [[self chatTable] registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatReceive"];
    
    loadMoreMessagesControl = [[UIRefreshControl alloc] init];
    [loadMoreMessagesControl addTarget:self
                                action:@selector(loadMoreMessages)
                      forControlEvents:UIControlEventValueChanged];

    [self.chatTable addSubview:loadMoreMessagesControl];
    
    //Instantiating custom view that adjusts itself to keyboard show/hide
    self.handler = [[ContentView alloc] initWithTextView:self.messageText ChatTextViewHeightConstraint:self.messageTextHeightConstraint contentView:self.contentView ContentViewHeightConstraint:self.contentViewHeightConstraint andContentViewBottomConstraint:self.contentViewBottomConstraint];
    
    //Setting the minimum and maximum number of lines for the textview vertical expansion
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:3];
    
    //Tap gesture on table view so that when someone taps on it, the keyboard is hidden
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.chatTable addGestureRecognizer:gestureRecognizer];
    
    userImageCache = [[NSCache alloc] init];
    
    fetchImage = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    
    [self.uploadProgress setHidden:YES];
    self.chatStatusView.backgroundColor = [UIColor yellowColor];
    [self.chatStatus setText:@"Authenticating and retrieving session key..."];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatConnect:) name:@"iFlyChat.onChatConnect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDisconnect) name:@"iFlyChat.onChatDisconnect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageFromRoom:) name:@"iFlyChat.onMessagefromRoom" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageFromUser:) name:@"iFlyChat.onMessagefromUser" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserImage) name:@"onUpdatedGlobalList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSessionKey:) name:@"iFlyChat.onGetSessionKey" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotUserThreadHistory:) name:@"iFlyChat.onUserThreadHistory" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotRoomThreadHistory:) name:@"iFlyChat.onRoomThreadHistory" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotEmptyThreadHistory:) name:@"iFlyChat.onEmptyThreadHistory" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUploadProgress:) name:@"iFlyChat.onUploadProgress" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

}

-(void)textViewDidChange:(UITextView *)textView
{
    //Resizing the textview according to the text
    [self.handler resizeTextViewWithAnimation:NO];
    
    //Enable and disable send button based on whether there is any text in textview or not
    if([messageText.text length]==0)
    {
        [sendButton setEnabled:NO];
    }
    else
    {
        [sendButton setEnabled:YES];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    //Initialise chat only if chat state from iFlyChatLibrary is not open
    if(![appData.service.getChatState isEqualToString:@"open"])
    {
        [dtclass initiFlyChatLibrary];
    }
    else
    {
        dispatch_once(&getLatestThreadHistory, ^{
            self.chatStatusView.backgroundColor = [UIColor greenColor];
            [self.chatStatus setText:@"Connected"];
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 self.chatStatusHeight.constant = 2;
                                 [self.chatStatusView.superview layoutIfNeeded];
                             }
                             completion:nil];
            
            self.chatStatus.text = @"";
            
            if(![USERID isEqualToString:@""])
            {
                [dtclass getUserThreadHistoryWithCurrentUserId:appData.loggedUser.getId forUserId:USERID forUserName:USERNAME messageId:@""];
            }
            else
            {
                [dtclass getRoomThreadHistoryWithCurrentUserId:appData.loggedUser.getId forRoomId:ROOMID forRoomName:ROOMNAME messageId:@""];
            }
            
        });
        [self setUserImage];
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //Disconnect chat when the view disappears
    //[dtclass disconnect];
}

- (void) dismissKeyboard
{
    [self.messageText resignFirstResponder];
}

-(void) detectOrientation
{
    //Change the height and width of the navigation bar image according to the orientation of the device
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
    {
        if(self.userImageWidth.constant!=25)
        {
            self.userImageHeight.constant = 25;
            self.userImageWidth.constant = 25;
            self.userImage.layer.cornerRadius = 12.5;
        }
    }
    else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        if(self.userImageWidth.constant!=35)
        {
            self.userImageHeight.constant = 35;
            self.userImageWidth.constant = 35;
            self.userImage.layer.cornerRadius = 17.5;
        }
    }
}

-(void) chatConnect:(NSNotification *)notification
{
    //When the chat is connected, save the logged in user's information in a variable
    NSDictionary *dict = [notification object];
    appData.loggedUser = [dict objectForKey:@"iFlyChatCurrentUser"];
    
    self.chatStatusView.backgroundColor = [UIColor greenColor];
    [self.chatStatus setText:@"Connected"];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.chatStatusHeight.constant = 2;
                         [self.chatStatusView.superview layoutIfNeeded];
                     }
                     completion:nil];
    
    self.chatStatus.text = @"";
    
    if(![USERID isEqualToString:@""])
    {
        [dtclass getUserThreadHistoryWithCurrentUserId:appData.loggedUser.getId forUserId:USERID forUserName:USERNAME messageId:@""];
    }
    else
    {
        [dtclass getRoomThreadHistoryWithCurrentUserId:appData.loggedUser.getId forRoomId:ROOMID forRoomName:ROOMNAME messageId:@""];
    }
    
    [self setUserImage];
}

-(void) gotSessionKey:(NSNotification *)notification
{
    //After getting the session key, save the session key as well so that it can be used again later
    appData.sessionKey = [notification object];
    [self.chatStatus setText:@"Connecting to iFlyChat servers..."];
}

-(void) gotUserThreadHistory:(NSNotification *)notification
{
    NSDictionary *result = [notification object];
    
    if([[result objectForKey:@"forUserId"] isEqualToString:USERID])
    {
        [loadMoreMessagesControl endRefreshing];
        iFlyChatOrderedDictionary *threadHistory = [result objectForKey:@"threadHistory"];
        [threadHistory addObjectsFromOrderedDictionary:currentMessages];
        currentMessages = threadHistory;
        //iFlyChatOrderedDictionary *saveMessages = [[iFlyChatOrderedDictionary alloc] init];
        //saveMessages = currentMessages;
        //currentMessages = threadHistory;
        //[currentMessages addObjectsFromOrderedDictionary:saveMessages];
        [self.chatTable reloadData];
        NSLog(@"Got thread history");
    }
    
}

-(void) gotRoomThreadHistory:(NSNotification *)notification
{
    NSDictionary *result = [notification object];
    
    if([[result objectForKey:@"forRoomId"] isEqualToString:ROOMID])
    {
        [loadMoreMessagesControl endRefreshing];
        iFlyChatOrderedDictionary *threadHistory = [result objectForKey:@"threadHistory"];
        [threadHistory addObjectsFromOrderedDictionary:currentMessages];
        currentMessages = threadHistory;
        //iFlyChatOrderedDictionary *saveMessages = [[iFlyChatOrderedDictionary alloc] init];
        //saveMessages = currentMessages;
        //currentMessages = threadHistory;
        //[currentMessages addObjectsFromOrderedDictionary:saveMessages];
        [self.chatTable reloadData];
        NSLog(@"Got thread history");
    }
}

-(void) gotEmptyThreadHistory:(NSNotification *)notification
{
    NSString *forId = [notification object];
    
    if([forId length] != 0)
    {
        if([forId isEqualToString:[USERID length] != 0 ? USERID : ROOMID ])
        {
            [loadMoreMessagesControl endRefreshing];
        }
        else
        {
            NSLog(@"Something wrong happened");
        }
    }
    else
    {
        [loadMoreMessagesControl endRefreshing];
    }
}

-(void) loadMoreMessages
{
    if([currentMessages count] != 0)
    {
        iFlyChatMessage *msg = [currentMessages objectAtIndex:0];
        
        if([USERID length] != 0)
        {
            [dtclass getUserThreadHistoryWithCurrentUserId:appData.loggedUser.getId forUserId:USERID forUserName:USERNAME messageId:msg.getMessageId];
        }
        else
        {
            [dtclass getRoomThreadHistoryWithCurrentUserId:appData.loggedUser.getId forRoomId:ROOMID forRoomName:ROOMNAME messageId:msg.getMessageId];
        }
    }
    else
    {
        [loadMoreMessagesControl endRefreshing];
    }
}

-(void) onUploadProgress:(NSNotification *)notification
{
    NSDictionary *result = [notification object];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //UILabel *uploadProgressLabel = [self.view viewWithTag:[[[result objectForKey:@"message_id"] substringFromIndex:10] integerValue]];
        
        //[uploadProgressLabel setText:[[result objectForKey:@"uploadProgress"] stringValue]];
        if(self.uploadProgress.hidden)
        {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 self.chatStatusHeight.constant = 49;
                                 [self.chatStatusView.superview layoutIfNeeded];
                             }
                             completion:nil];
            [self.uploadProgress setHidden:NO];
            [self.chatStatusView setBackgroundColor:[UIColor whiteColor]];
            [self.chatStatus setHidden:NO];
            [self.chatStatus setText:@"Uploading"];
            self.uploadProgress.progress = [[result objectForKey:@"uploadProgress"] floatValue];
        }
        else
        {
            self.uploadProgress.progress = [[result objectForKey:@"uploadProgress"] floatValue];
            if(self.uploadProgress.progress == 1.0f)
            {
                [self.uploadProgress setHidden:YES];
                [self.chatStatus setHidden:YES];
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     self.chatStatusHeight.constant = 2;
                                     [self.chatStatusView.superview layoutIfNeeded];
                                 }
                                 completion:nil];
            }
        }
    });
}



-(void) chatDisconnect
{
    self.chatStatus.text = @"Not connected";
    self.chatStatusHeight.constant = 49;
}

-(void) setUserImage
{
    //If image is not set already
    if(!imageAlreadySetFlag)
    {
        //If you are talking to a user and not a room
        if(![USERID isEqualToString:@""])
        {
            //If avatar url is not empty
            NSString *avatarUrl = [[appData.userList objectForKey:USERID] getAvatarUrl];
            if([avatarUrl length]!=0 && [avatarUrl rangeOfString:@"default_avatar"].location == NSNotFound && [avatarUrl rangeOfString:@"gravatar"].location == NSNotFound)
            {
                //Download and set the image
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http:",[[appData.userList objectForKey:USERID] getAvatarUrl]]];
                NSData *data = [[NSData alloc ] initWithContentsOfURL:url];
                
                UIImage *img = [UIImage imageWithData:data];
                self.navBarUserImageView.image = img;
                [self.navBarUserLetterLabel setHidden:YES];
                self.navBarUserImageView.backgroundColor = [UIColor whiteColor];
                imageAlreadySetFlag=YES;
            }
            else
            {
                if([self checkRegisteredUser:USERID] && use_default_avatar)
                {
                    [self.navBarUserLetterLabel setHidden:YES];
                    [self setDefaultAvatarWithBackgroundColor:USERNAME userImageView:self.navBarUserImageView];
                }
                else if([self checkRegisteredUser:USERID] && !use_default_avatar)
                {
                    [self setLetterAvatarWithBackgroundColor:USERNAME userImageView:self.navBarUserImageView userLetterLabel:self.navBarUserLetterLabel];
                }
                else if([self checkRegisteredUser:USERID] && use_default_avatar)
                {
                    [self.navBarUserLetterLabel setHidden:YES];
                    [self setDefaultAvatarWithBackgroundColor:[Utility getNameWithoutPrefix:USERNAME] userImageView:self.navBarUserImageView];
                }
                else
                {
                    [self setLetterAvatarWithBackgroundColor:[Utility getNameWithoutPrefix:USERNAME] userImageView:self.navBarUserImageView userLetterLabel:self.navBarUserLetterLabel];
                }
                imageAlreadySetFlag = NO;
            }
        }
        else
        {
            imageAlreadySetFlag=YES;
        }
    }
}

-(void) messageFromRoom:(NSNotification *)notification
{
    //If we are chatting in a room then go ahead
    if(![ROOMID isEqualToString:@""])
    {
        iFlyChatMessage *msg = [notification object];
        
        //If the message that is received here is sent to the room I am currently chatting in then go ahead
        if([ROOMID isEqualToString:msg.getToId])
        {
            //If the message sender is not me or if the message sender is myself and I have not yet updated the message in my dictionary and view then go ahead
            if(![msg.getFromId isEqualToString:appData.loggedUser.getId] || ([msg.getFromId isEqualToString:appData.loggedUser.getId] && [currentMessages objectForKey:msg.getMessageId]==nil))
            {
                [self updateTableView:msg];
            }
        }
    }
}

-(void) messageFromUser:(NSNotification *)notification
{
    //Same as rooms comments
    if(![USERID isEqualToString:@""])
    {
        iFlyChatMessage *msg = [notification object];
        
        if([USERID isEqualToString:msg.getToId] || [USERID isEqualToString:msg.getFromId])
        {
            if(![msg.getFromId isEqualToString:appData.loggedUser.getId] || ([msg.getFromId isEqualToString:appData.loggedUser.getId] && [currentMessages objectForKey:msg.getMessageId]==nil))
            {
                [self updateTableView:msg];
            }
        }
    }
    
}

-(void) updateTableView:(iFlyChatMessage *)msg
{
    //Check which are the visible paths and how many messages are there. If the user is on last message then if a message is received, scroll the table view. If the user is not on the last message and a message is received then do not scroll the table view.
    NSArray *paths = [self.chatTable indexPathsForVisibleRows];
    
    long lastVisibleRow;
    long messageLastRow;
    
    if(paths.count == 0)
    {
        lastVisibleRow = 0;
        messageLastRow = 0;
    }
    else
    {
        NSIndexPath *lastVisibleRowIndexPath = [paths objectAtIndex:(paths.count - 1)];
        lastVisibleRow = lastVisibleRowIndexPath.row;
        messageLastRow = currentMessages.count - 1;
    }
    
    //Update the table view
    [self.chatTable beginUpdates];
    
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:currentMessages.count inSection:0];
    
    //Insert the newly received message in the dictionary
    [currentMessages insertObject:msg forKey:msg.getMessageId atIndex:currentMessages.count];
    
    [self.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1, nil] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.chatTable endUpdates];
    
    if (lastVisibleRow == messageLastRow)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.chatTable numberOfRowsInSection:0]-1 inSection:0];
        [self.chatTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}

- (IBAction)uploadFile:(id)sender
{
    [self dismissKeyboard];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select your file to send"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take photo/video", @"Photo/Video Library", @"Select file", nil];
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        ipc = [[UIImagePickerController alloc] init];
        ipc.delegate = self;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            ipc.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie,(NSString *) kUTTypeImage, nil];
            [self presentViewController:ipc animated:YES completion:NULL];
            newMedia = YES;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Camera Available." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
        }
    }
    else if(buttonIndex == 1)
    {
        ipc= [[UIImagePickerController alloc] init];
        ipc.delegate = self;
        ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        ipc.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie,(NSString *) kUTTypeImage, nil];
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            [self presentViewController:ipc animated:YES completion:nil];
            newMedia = NO;
        }
        else
        {
            popover=[[UIPopoverController alloc]initWithContentViewController:ipc];
            [popover presentPopoverFromRect:actionSheet.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else if(buttonIndex == 2)
    {
        UIDocumentPickerViewController *importMenu = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.composite-content"] inMode:UIDocumentPickerModeImport];
        
        
        importMenu.delegate = self;
        
        [self presentViewController:importMenu animated:YES completion:nil];
    }
    
    NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
}

-(void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    [self createMessageObjectForFileUpload:url];
}

-(void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        [popover dismissPopoverAnimated:YES];
    }
    
    if(!newMedia)
    {
        
        if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage])
        {
            [self createMessageObjectForFileUpload:[info objectForKey:UIImagePickerControllerReferenceURL]];
        }
        else if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie])
        {
            [self createMessageObjectForFileUpload:[info objectForKey:UIImagePickerControllerMediaURL]];
        }
    }
    else
    {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage])
        {
            
            CGImageRef image = [[info objectForKey:UIImagePickerControllerOriginalImage] CGImage];
            [library writeImageToSavedPhotosAlbum:image
                                      orientation:ALAssetOrientationUp
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      if(error == nil)
                                      {
                                          NSLog(@"%@",assetURL);
                                          [self createMessageObjectForFileUpload:assetURL];
                                      }
                                      else
                                      {
                                          NSLog(@"%@",error);
                                      }
                                  }];
        }
        else if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie])
        {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoUrl])
            {
                
                [library writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error)
                    {
                        NSLog(@"error");
                    }
                    else
                    {
                        NSLog(@"video assetUrl is %@", assetURL);
                        [self createMessageObjectForFileUpload:assetURL];
                    }
                }];
            }
            else
            {
                NSLog(@"videoAtPath is not compatible with photos Album.");
            }
        }
        
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) createMessageObjectForFileUpload:(NSURL *)fileUrl
{
    iFlyChatMessage *sendMessage;
    
    //Make iFlyChatMessage objects according to where/with whom the user is chatting
    if(![USERID isEqualToString:@""])
    {
        sendMessage = [[iFlyChatMessage alloc] initIFlyChatMessageObjectwithMessage:[fileUrl absoluteString] fromName:appData.loggedUser.getName toName:USERNAME fromId:appData.loggedUser.getId toId:USERID message_id:@"" color:@"#222222" fromProfileUrl:appData.loggedUser.getProfileUrl fromAvatarUrl:appData.loggedUser.getAvatarUrl fromRole:appData.loggedUser.getRole time:@"" type:@"user"];
        [dtclass sendFileToUser:sendMessage];
        
    }
    else
    {
        sendMessage = [[iFlyChatMessage alloc] initIFlyChatMessageObjectwithMessage:[fileUrl absoluteString] fromName:appData.loggedUser.getName toName:ROOMNAME fromId:appData.loggedUser.getId toId:ROOMID message_id:@"" color:@"#222222" fromProfileUrl:appData.loggedUser.getProfileUrl fromAvatarUrl:appData.loggedUser.getAvatarUrl fromRole:appData.loggedUser.getRole time:@"" type:@"room"];
        [dtclass sendFileToRoom:sendMessage];
    }
    
    if(self.uploadProgress.hidden)
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.chatStatusHeight.constant = 49;
                             [self.chatStatusView.superview layoutIfNeeded];
                         }
                         completion:nil];
        [self.uploadProgress setHidden:NO];
        [self.chatStatusView setBackgroundColor:[UIColor whiteColor]];
        [self.chatStatus setHidden:NO];
        [self.chatStatus setText:@"Uploading"];
        self.uploadProgress.progress = 0.0f;
    }
}



- (IBAction)send
{
    iFlyChatMessage *sendMessage;
    
    //Make iFlyChatMessage objects according to where/with whom the user is chatting
    if(![USERID isEqualToString:@""])
    {
        sendMessage = [[iFlyChatMessage alloc] initIFlyChatMessageObjectwithMessage:self.messageText.text fromName:appData.loggedUser.getName toName:USERNAME fromId:appData.loggedUser.getId toId:USERID message_id:@"" color:@"#ffffff" fromProfileUrl:@"" fromAvatarUrl:appData.loggedUser.getAvatarUrl fromRole:@"" time:@"gb" type:@"user"];
        [dtclass sendMessageToUser:sendMessage];
        
    }
    else
    {
        sendMessage = [[iFlyChatMessage alloc] initIFlyChatMessageObjectwithMessage:self.messageText.text fromName:appData.loggedUser.getName toName:ROOMNAME fromId:appData.loggedUser.getId toId:ROOMID message_id:@"" color:@"#ffffff" fromProfileUrl:@"" fromAvatarUrl:appData.loggedUser.getAvatarUrl fromRole:@"" time:@"gb" type:@"room"];
        [dtclass sendMessageToRoom:sendMessage];
    }

    [self.messageText setText:@""];
    [self textViewDidChange:self.messageText];
    
    [self.chatTable beginUpdates];
    
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:currentMessages.count inSection:0];
        
    [currentMessages insertObject:sendMessage forKey:sendMessage.getMessageId atIndex:currentMessages.count];
    
    [self.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1, nil] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.chatTable endUpdates];
    
    //Always scroll the chat table when the user sends the message
    if([self.chatTable numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.chatTable numberOfRowsInSection:0]-1 inSection:0];
        [self.chatTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    iFlyChatMessage *message = [currentMessages objectAtIndex:indexPath.row];
    
    if([appData.loggedUser.getId isEqualToString:message.getFromId])
    {
        chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chatSend"];
        
        chatCell.chatMessageLabel.text = message.getMessage;

        chatCell.chatNameLabel.text = message.getFromName;
        
        
        /*
         *  epoch time to nsdate
         *  Show date only when the date is not current date otherwise show only time
         */
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"dd/MM"];
        
        NSTimeInterval epochMessageDateTime;
        
        if([message.getTime length] > 10)
        {
            epochMessageDateTime = [[message.getTime substringToIndex:[message.getTime length] - 3] doubleValue];
        }
        else
        {
            epochMessageDateTime = [message.getTime doubleValue];
        }
        NSDate *messageDateTime = [[NSDate alloc] initWithTimeIntervalSince1970:epochMessageDateTime];
        
        NSDate *currentDateTime = [NSDate date];
        
        if([[dateFormatter stringFromDate:currentDateTime] isEqualToString:[dateFormatter stringFromDate:messageDateTime]])
        {
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"dd/MM HH:mm"];
        }
        
        chatCell.chatTimeLabel.text = [dateFormatter stringFromDate:messageDateTime];
        
        //Asynchronously downloading images after checking if they are available in cache
        if([userImageCache objectForKey:appData.loggedUser.getId] == nil)
        {
            [self setChatImage:chatCell.chatUserImage userLetterLabel:chatCell.chatUserLetterLabel userId:appData.loggedUser.getId userName:appData.loggedUser.getName userAvatarUrl:appData.loggedUser.getAvatarUrl];
        }
        else
        {
            chatCell.chatUserImage.image = [userImageCache objectForKey:appData.loggedUser.getId];
            chatCell.chatUserImage.backgroundColor = [UIColor whiteColor];
            [chatCell.chatUserLetterLabel setHidden:YES];
        }
        chatCell.authorType = iFlyChatBubbleTableViewCellAuthorTypeSender;
    }
    else
    {
        chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        
        chatCell.chatMessageLabel.text = message.getMessage;
        chatCell.chatNameLabel.text = message.getFromName;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        
        [dateFormatter setDateFormat:@"dd/MM"];
        
        NSTimeInterval epochMessageDateTime;
        
        if([message.getTime length] > 10)
        {
            epochMessageDateTime = [[message.getTime substringToIndex:[message.getTime length] - 3] doubleValue];
        }
        else
        {
            epochMessageDateTime = [message.getTime doubleValue];
        }
        
        NSDate *messageDateTime = [[NSDate alloc] initWithTimeIntervalSince1970:epochMessageDateTime];
        
        
        NSDate *currentDateTime = [NSDate date];
        
        if([[dateFormatter stringFromDate:currentDateTime] isEqualToString:[dateFormatter stringFromDate:messageDateTime]])
        {
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"dd/MM HH:mm"];
        }

        chatCell.chatTimeLabel.text = [dateFormatter stringFromDate:messageDateTime];
        
        receivedMessageGetImage=YES;
        
        if ([userImageCache objectForKey:message.getFromId] == nil)
        {
            [self setChatImage:chatCell.chatUserImage userLetterLabel:chatCell.chatUserLetterLabel userId:message.getFromId userName:message.getFromName userAvatarUrl:message.getFromAvatarUrl];
        }
        else
        {
            chatCell.chatUserImage.image = [userImageCache objectForKey:message.getFromId];
            chatCell.chatUserImage.backgroundColor = [UIColor whiteColor];
            [chatCell.chatUserLetterLabel setHidden:YES];
        }
        chatCell.authorType = iFlyChatBubbleTableViewCellAuthorTypeReceiver;
    }
    
    return chatCell;
}

-(BOOL) checkRegisteredUser:(NSString *)userId
{
    if([userId rangeOfString:@"0-"].location != NSNotFound)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void) setDefaultAvatarWithBackgroundColor:(NSString *)userNameWithoutPrefix userImageView:(UIImageView *)userImageView
{
    userImageView.backgroundColor = [Utility getColorFromNameWithoutPrefix:userNameWithoutPrefix];
    userImageView.image = [UIImage imageNamed:@"MaleUser"];
}

-(void) setLetterAvatarWithBackgroundColor:(NSString *)userNameWithoutPrefix userImageView:(UIImageView *)userImageView userLetterLabel:(UILabel *)userLetterLabel
{
    if([[Utility getLetterFromNameWithoutPrefix:userNameWithoutPrefix] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound)
    {
        [userLetterLabel setHidden:YES];
        [self setDefaultAvatarWithBackgroundColor:userNameWithoutPrefix userImageView:userImageView];
    }
    else
    {
        userImageView.backgroundColor = [Utility getColorFromNameWithoutPrefix:userNameWithoutPrefix];
        userLetterLabel.text = [Utility getLetterFromNameWithoutPrefix:userNameWithoutPrefix];
        [userLetterLabel setHidden:NO];
        userImageView.image = nil;
    }
}

-(void) setChatImage:(UIImageView *)userImageView userLetterLabel:(UILabel *)userLetterLabel userId:(NSString *)userId userName:(NSString *)userName userAvatarUrl:(NSString *)userAvatarUrl
{
    if([self checkRegisteredUser:userId])
    {
        if(userAvatarUrl.length != 0)
        {
            if([userAvatarUrl rangeOfString:@"default_avatar"].location != NSNotFound || [userAvatarUrl rangeOfString:@"gravatar"].location != NSNotFound )
            {
                if(use_default_avatar)
                {
                    //A registered user with no image set and we have to use only default image, no letter image
                    [self setDefaultAvatarWithBackgroundColor:userName userImageView: userImageView];
                    [userLetterLabel setHidden:YES];
                }
                else
                {
                    //A registered user with no image set and we are allowed to use letter image
                    [self setLetterAvatarWithBackgroundColor:userName userImageView: userImageView userLetterLabel: userLetterLabel];
                }
            }
            else
            {
                //A registered user with image set so use URL image
                dispatch_async(fetchImage, ^{
                    //Downloading images asynchronously
                    [self loadImagesWithURL:[NSString stringWithFormat:@"%@%@",@"http:",userAvatarUrl] userImageView:userImageView userId:userId];
                });
                
                [userLetterLabel setHidden:YES];
                userImageView.backgroundColor = [UIColor whiteColor];
            }
        }
        else if(use_default_avatar)
        {
            //A registered user with no URL for avatar and we have to use default image, no letter image
            [self setDefaultAvatarWithBackgroundColor:userName userImageView: userImageView];
            [userLetterLabel setHidden:YES];
        }
        else
        {
            //A registered user with no URL for avatar and we are allowed to use letter image
            [self setLetterAvatarWithBackgroundColor:userName userImageView: userImageView userLetterLabel: userLetterLabel];
        }
    }
    else
    {
        if(use_default_avatar)
        {
            //A guest user and we have to use default image, no letter image
            [self setDefaultAvatarWithBackgroundColor:[Utility getNameWithoutPrefix:userName] userImageView: userImageView];
            [userLetterLabel setHidden:YES];
        }
        else
        {
            //A guest user and we are allowed to use letter image
            [self setLetterAvatarWithBackgroundColor:[Utility getNameWithoutPrefix:userName] userImageView: userImageView userLetterLabel: userLetterLabel];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    iFlyChatMessage *message = [currentMessages objectAtIndex:indexPath.row];
    
    CGSize size;
    
    CGSize Namesize;
    CGSize Timesize;
    CGSize Messagesize;
    
    NSArray *fontArray = [[NSArray alloc] init];

    //Get the chal cell font settings. This is to correctly find out the height of each of the cell according to the text written in those cells which change according to their fonts and sizes.
    //If you want to keep the same font sizes for both sender and receiver cells then remove this code and manually enter the font name with size in Namesize, Messagesize and Timesize.
    if([message.getFromId isEqualToString:appData.loggedUser.getId])
    {
        fontArray = chatCellSettings.getSenderBubbleFontWithSize;
    }
    else
    {
        fontArray = chatCellSettings.getReceiverBubbleFontWithSize;
    }

    //Find the required cell height
    Namesize = [@"Name" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontArray[0]}
                                     context:nil].size;

    
    
    Messagesize = [message.getMessage boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:fontArray[1]}
                                                   context:nil].size;
    
    
    Timesize = [@"Time" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:fontArray[2]}
                                             context:nil].size;
    
    
    size.height = Messagesize.height + Namesize.height + Timesize.height + 48.0f;
        
    return size.height;
}

-(void) loadImagesWithURL:(NSString *)imageURL userImageView:(UIImageView *)userImageView userId:(NSString *)userId
{
    NSString *newURL =[imageURL stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
    NSURL *url = [NSURL URLWithString:newURL];
    NSData *data = [[NSData alloc ] initWithContentsOfURL:url];
    
    UIImage *img = [UIImage imageWithData:data];
    
    //Caching the downloaded image
    if(img != nil)
    {
        [userImageCache setObject:img forKey:userId];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Setting the image in the view
        userImageView.image = img;
        
    });
    
    if(!imageAlreadySetFlag && receivedMessageGetImage)
    {
        dispatch_once(&setNavBarImage, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navBarUserImageView.image = img;
                self.navBarUserImageView.backgroundColor = [UIColor whiteColor];
                [self.navBarUserLetterLabel setHidden:YES];
            });
            imageAlreadySetFlag=YES;
            receivedMessageGetImage=NO;
        });
    }
}
@end
