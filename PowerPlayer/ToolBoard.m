//
//  ToolBoard.m
//  PowerPlayer
//
//  Created by sealedace on 12-8-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "ToolBoard.h"
#import "PlayerManager.h"

#define ButtonIndent 10

@interface ToolBoard ()
- (void)loopButtonPressed:(id)sender;
- (void)shuffleButtonPressed:(id)sender;
@end

@implementation ToolBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        m_loopButton = [[LoopButton alloc] initWithFrame:CGRectZero];
        [self addSubview:m_loopButton];

        m_shuffleButton = [[ShuffleButton alloc] initWithFrame:CGRectZero];
        [self addSubview:m_shuffleButton];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rectBounds = [self bounds];
    
    CGRect rectLoopButton = CGRectMake(ButtonIndent,
                                       (CGRectGetHeight(rectBounds)-CGRectGetHeight([m_loopButton frame]))/2,
                                       CGRectGetWidth([m_loopButton frame]),
                                       CGRectGetHeight([m_loopButton frame]));
    [m_loopButton setFrame:rectLoopButton];
    
    CGRect rectShuffleButton = CGRectMake(CGRectGetWidth(rectBounds)-ButtonIndent-CGRectGetWidth([m_shuffleButton frame]),
                                          (CGRectGetHeight(rectBounds)-CGRectGetHeight([m_shuffleButton frame]))/2,
                                          CGRectGetWidth([m_shuffleButton frame]),
                                          CGRectGetHeight([m_shuffleButton frame]));
    [m_shuffleButton setFrame:rectShuffleButton];
}

- (void)dealloc
{
    [m_loopButton release];
    [m_shuffleButton release];
    [super dealloc];
}

- (void)loopButtonPressed:(LoopButton*)button
{
    switch (button.loopMode)
    {
        case LoopMode_All:
        {
            [[PlayerManager sharedInstance] setLoop:YES];
            break;
        }
        case LoopMode_None:
        {
            [[PlayerManager sharedInstance] setLoop:NO];
            break;
        }
        case LoopMode_Single:
        {
            [[PlayerManager sharedInstance] setPlayMode:PlayMode_Single];
            [[PlayerManager sharedInstance] setLoop:YES];
            break;
        }
        default:
            break;
    }
}

- (void)shuffleButtonPressed:(ShuffleButton*)button
{
    if (button.isShuffle)
    {
        [[PlayerManager sharedInstance] setPlayMode:PlayMode_Shuffle];
    }
    else
    {
        [[PlayerManager sharedInstance] setPlayMode:PlayMode_Normal];
    }
}

@end
