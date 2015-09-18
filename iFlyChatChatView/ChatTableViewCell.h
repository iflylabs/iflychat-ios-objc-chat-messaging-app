//
//  ChatTableViewCell.h
//  test
//
//  Created by Prateek Grover on 06/04/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AuthorType) {
    iFlyChatBubbleTableViewCellAuthorTypeSender = 0,
    iFlyChatBubbleTableViewCellAuthorTypeReceiver
};

@interface ChatTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *chatUserImage;
@property (strong, nonatomic) UILabel *chatNameLabel;
@property (strong, nonatomic) UILabel *chatTimeLabel;
@property (strong, nonatomic) UILabel *chatMessageLabel;
@property (nonatomic, assign) AuthorType authorType;

@end
