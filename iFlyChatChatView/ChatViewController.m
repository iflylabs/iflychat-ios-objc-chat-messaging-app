//
//  ChatViewController.m
//  test
//
//  Created by Prateek Grover on 06/04/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "ContentView.h"
#import "DataClass.h"
#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

@interface ChatViewController () <UITextViewDelegate>

@property (nonatomic,strong) ChatTableViewCell *chatCell;
@property (nonatomic,strong) iFlyChatUser *messageUser;

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
        self.userImage.image = [UIImage imageNamed:@"defaultUser.png"];
        
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
        self.userImage.image = [UIImage imageNamed:@"defaultRoom.png"];
        
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

    //Instantiating custom view that adjusts itself to keyboard show/hide
    self.handler = [[ContentView alloc] initWithTextView:self.messageText ChatTextViewHeightConstraint:self.messageTextHeightConstraint contentView:self.contentView ContentViewHeightConstraint:self.contentViewHeightConstraint andContentViewBottomConstraint:self.contentViewBottomConstraint];
    
    //Setting the minimum and maximum number of lines for the textview vertical expansion
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:3];
    
    //Tap gesture on table view so that when someone taps on it, the keyboard is hidden
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.chatTable addGestureRecognizer:gestureRecognizer];
    
    userImageCache = [[NSCache alloc] init];
    
    fetchImage = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    
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
        self.chatStatusView.backgroundColor = [UIColor greenColor];
        [self.chatStatus setText:@"Connected"];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.chatStatusHeight.constant = 2;
                             [self.chatStatusView.superview layoutIfNeeded];
                         }
                         completion:nil];
        
        self.chatStatus.text = @"";
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
    [dtclass disconnect];
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
}

-(void) gotSessionKey:(NSNotification *)notification
{
    //After getting the session key, save the session key as well so that it can be used again later
    appData.sessionKey = [notification object];
    [self.chatStatus setText:@"Connecting to iFlyChat servers..."];
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
            if([[[appData.userList objectForKey:USERID] getAvatarUrl] length]!=0)
            {
                //Download and set the image
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http:",[[appData.userList objectForKey:USERID] getAvatarUrl]]];
                NSData *data = [[NSData alloc ] initWithContentsOfURL:url];
        
                UIImage *img = [UIImage imageWithData:data];
                self.userImage.image = img;
            }
        }
        imageAlreadySetFlag=YES;
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
    NSIndexPath *lastVisibleRowIndexPath = [paths objectAtIndex:(paths.count - 1)];
    long lastVisibleRow = lastVisibleRowIndexPath.row;
    long messageLastRow = currentMessages.count - 1;
    
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
        
        NSTimeInterval epochMessageDateTime = [message.getTime doubleValue];
        
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
            
            if([[appData.loggedUser getAvatarUrl] length]!=0)
            {
                dispatch_async(fetchImage, ^{
                    
                    
                    [self loadImagesWithURL:[NSString stringWithFormat:@"%@%@",@"http:",appData.loggedUser.getAvatarUrl IndexPath:indexPath userId:appData.loggedUser.getId];
                    
                });
            }
            
            
            chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser.png"];
        }
        else
        {
            chatCell.chatUserImage.image = [userImageCache objectForKey:appData.loggedUser.getId];
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
        
        NSTimeInterval epochMessageDateTime = [message.getTime doubleValue];
        
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
        
        if([appData.userList objectForKey:message.getFromId] != nil)
        {
            messageUser = [appData.userList objectForKey:message.getFromId];
            
            if([userImageCache objectForKey:messageUser.getId] == nil)
            {
                
                if([[messageUser getAvatarUrl] length]!=0)
                {
                    dispatch_async(fetchImage, ^{
                        
                        
                        [self loadImagesWithURL:[NSString stringWithFormat:@"%@%@",@"http:",messageUser.getAvatarUrl IndexPath:indexPath userId:messageUser.getId];
                        
                    });
                }
                
                
                chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser.png"];
            }
            else
            {
                chatCell.chatUserImage.image = [userImageCache objectForKey:messageUser.getId];
            }
        }
        chatCell.authorType = iFlyChatBubbleTableViewCellAuthorTypeReceiver;
    }
    
    return chatCell;
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

-(void) loadImagesWithURL:(NSString *)imageURL IndexPath:(NSIndexPath *)indexPath userId:(NSString *)userId
{
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [[NSData alloc ] initWithContentsOfURL:url];
    
    UIImage *img = [UIImage imageWithData:data];
    
    //Caching the downloaded image
    [userImageCache setObject:img forKey:userId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Setting the image in the view
        ChatTableViewCell *cell = (ChatTableViewCell *)[self.chatTable cellForRowAtIndexPath:indexPath];
        cell.chatUserImage.image = img;
        
    });
}
@end
