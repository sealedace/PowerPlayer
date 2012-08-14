//
//  SongDetailBar.m
//  PowerPlayer
//
//  Created by 许  on 12-7-5.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "SongDetailBar.h"
#import "PlayerManager.h"
#import "Player.h"
#import "Song.h"
#import "ThemeManager.h"
#import "PublicDefinitions.h"
#import "DynamicLabel.h"

#define IndentBeforeButton 30

@interface SongDetailBar()
- (void)songWillStart;
- (void)songPlaysEnd;

@end

@implementation SongDetailBar
@synthesize currentSong=m_currentSong;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        // Title
        m_labelTitle = [[DynamicLabel alloc] init];
        [m_labelTitle.label setTextAlignment:NSTextAlignmentCenter];
        [m_labelTitle.label setTextColor:[UIColor colorWithWhite:0.8 alpha:1]];
        [self addSubview:m_labelTitle];
        
        // Performer
        m_labelPerformer = [[DynamicLabel alloc] init];
        [m_labelPerformer.label setTextAlignment:NSTextAlignmentCenter];
        [m_labelPerformer.label setTextColor:[UIColor colorWithWhite:0.8 alpha:1]];
        [m_labelPerformer.label setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:m_labelPerformer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songWillStart)
                                                     name:PPNotification_SongWillBePlayed
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songWillStart)
                                                     name:PPNotification_SongsListDidSelect
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songPlaysEnd)
                                                     name:PPNotification_SongPlaysEnd
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songPlaysEnd)
                                                     name:PPNotification_PreviousButtonPressed
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songPlaysEnd)
                                                     name:PPNotification_NextButtonPressed
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect fatherFrame = [self frame];
    
    CGRect frameTitle = CGRectMake(0, 0, CGRectGetWidth(fatherFrame), 30);
    [m_labelTitle setFrame:frameTitle];
    
    CGRect framePerformer = CGRectMake(0, CGRectGetMaxY(frameTitle), CGRectGetWidth(fatherFrame), 20);
    [m_labelPerformer setFrame:framePerformer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_labelTitle release];
    [m_labelPerformer release];
    [m_currentSong release];
    [super dealloc];
}

- (void)setSongData:(Song *)data
{
    self.currentSong = data;
    [m_labelTitle setText:data.title];
    [m_labelPerformer setText:data.performer];
}

- (void)songWillStart
{
    [self setSongData:[[[PlayerManager sharedInstance] currentPlayer] currentSong]];
}

- (void)songPlaysEnd
{
    [m_labelTitle setText:@""];
    [m_labelPerformer setText:@""];
}

@end
