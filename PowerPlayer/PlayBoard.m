//
//  PlayBoard.m
//  PowerPlayer
//
//  Created by 许  on 12-7-16.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "PlayBoard.h"
#import "PlayPauseButtonView.h"
#import "PlayNextButtonView.h"
#import "PlayPreviousButtonView.h"
#import "Player.h"
#import "PlayerManager.h"
#import "PublicDefinitions.h"


#define PlayButtonSize 60
#define PlayNextButtonSize 40
@interface PlayBoard()
- (void)playButtonPressed;
- (void)previousButtonPressed;
- (void)nextButtonPressed;
- (void)songWillStart;
- (void)songPlaysEnd;
@end

@implementation PlayBoard
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        // Play Button
        CGRect rectPlayButton = CGRectMake((CGRectGetWidth(frame)-PlayButtonSize)/2,
                                           (CGRectGetHeight(frame)-PlayButtonSize),
                                           PlayButtonSize,
                                           PlayButtonSize);
        m_playPauseButton = [[PlayPauseButtonView alloc] initWithFrame:rectPlayButton];
        m_playPauseButton.target = self;
        [self addSubview:m_playPauseButton];
        
        CGRect rectPlayPreviousButton = CGRectMake(20, CGRectGetMinY(rectPlayButton)+20, PlayNextButtonSize, PlayNextButtonSize);
        m_playPreviousButton = [[PlayPreviousButtonView alloc] initWithFrame:rectPlayPreviousButton];
        m_playPreviousButton.target = self;
        [self addSubview:m_playPreviousButton];
        
        CGRect rectPlayNextButton = CGRectMake(CGRectGetWidth(frame)-20-PlayNextButtonSize, CGRectGetMinY(rectPlayPreviousButton), PlayNextButtonSize, PlayNextButtonSize);
        
        m_playNextButton = [[PlayNextButtonView alloc] initWithFrame:rectPlayNextButton];
        m_playNextButton.target = self;
        [self addSubview:m_playNextButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songWillStart)
                                                     name:PPNotification_SongWillBePlayed
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songPlaysEnd)
                                                     name:PPNotification_SongPlaysEnd
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songPlaysEnd)
                                                     name:PPNotification_PlayerStopped
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect mainFrame = [self frame];
    CGRect rectPlayButton = CGRectMake((CGRectGetWidth(mainFrame)-PlayButtonSize)/2,
                                       (CGRectGetHeight(mainFrame)-PlayButtonSize),
                                       PlayButtonSize,
                                       PlayButtonSize);
    [m_playPauseButton setFrame:rectPlayButton];
    
    CGRect rectPlayPreviousButton = CGRectMake(70, CGRectGetMinY(rectPlayButton)+10, PlayNextButtonSize, PlayNextButtonSize);
    [m_playPreviousButton setFrame:rectPlayPreviousButton];
    
    CGRect rectPlayNextButton = CGRectMake(CGRectGetWidth(mainFrame)-CGRectGetMinX(rectPlayPreviousButton)-PlayNextButtonSize, CGRectGetMinY(rectPlayPreviousButton), PlayNextButtonSize, PlayNextButtonSize);
    [m_playNextButton setFrame:rectPlayNextButton];
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_playPauseButton release];
    [m_playNextButton release];
    [m_playPreviousButton release];
    [super dealloc];
}

- (void)buttonPressed:(UIView *)button
{
    if (button == m_playPauseButton)
    {
        [self playButtonPressed];
    }
    else if (button == m_playPreviousButton)
    {
        [self previousButtonPressed];
    }
    else if (button == m_playNextButton)
    {
        [self nextButtonPressed];
    }
}

- (void)playButtonPressed
{
    Player *player = [[PlayerManager sharedInstance] currentPlayer];
    if (nil == player)
    {
        // Start with song at index 0
        [[PlayerManager sharedInstance] playAudioAtFileIndex:0];
        [m_playPauseButton setIsPlayShape:NO];
        return;
    }

    if (Player_Paused == [player status])
    {
        [m_playPauseButton setIsPlayShape:NO];
        player.isPausedByUser = NO;
        [player play];
    }
    else if (Player_Playing == [player status])
    {
        [m_playPauseButton setIsPlayShape:YES];
        player.isPausedByUser = YES;
        [player pause];
    }
}

- (void)previousButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_PreviousButtonPressed
                                                        object:nil];
    [[PlayerManager sharedInstance] previous];
}

- (void)nextButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_NextButtonPressed
                                                        object:nil];
    [[PlayerManager sharedInstance] next];
}

- (void)songWillStart
{
    [m_playPauseButton setIsPlayShape:NO];
}

- (void)songPlaysEnd
{
    [m_playPauseButton setIsPlayShape:YES];
}

@end
