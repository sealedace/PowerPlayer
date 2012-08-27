//
//  StatusBar.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-9.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "StatusBar.h"
#import "PublicDefinitions.h"
#import "ProgressView.h"
#import "DynamicLabel.h"
#import "PlayerManager.h"
#import "Player.h"
#import "Song.h"

static StatusBar *instance = nil;
#define kStatusBarHeight 20.f
#define IsIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IsIPhoneEmulationMode (!IsIPad && \
MAX([UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height) > 480.f)

@interface StatusBar()
- (void)updateSong;
- (void)songsListWillShow;
- (void)songsListWillHide;
@end

@implementation StatusBar

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setBackgroundColor:[UIColor blackColor]];
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        
		// only use height of 20px even is status bar is doubled
		statusBarFrame.size.height = statusBarFrame.size.height == 2*kStatusBarHeight ? kStatusBarHeight : statusBarFrame.size.height;
		// if we are on the iPad but in iPhone-Mode (non-universal-app) correct the width
		if(IsIPhoneEmulationMode) 
        {
			statusBarFrame.size.width = 320.f;
		}
        
		// Place the window on the correct level and position
        self.windowLevel = UIWindowLevelStatusBar+1.f;
        self.frame = statusBarFrame;
		self.hidden = NO;
        
        CGRect frame1 = CGRectMake(0,
                                   0,
                                   CGRectGetWidth(statusBarFrame),
                                   CGRectGetHeight(statusBarFrame));
        
        m_dynamicProgress = [[ProgressView alloc] initWithFrame:frame1
                                                           mode:PlayerWorkStatusPlaySong];
        m_dynamicProgress.alpha = 1.0f;
        [self addSubview:m_dynamicProgress];
        
        m_labelTitle = [[DynamicLabel alloc] initWithFrame:frame1];
        [m_labelTitle.label setTextColor:[UIColor whiteColor]];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
        [m_labelTitle.label setTextAlignment:NSTextAlignmentCenter];
#else
        [m_labelTitle.label setTextAlignment:UITextAlignmentCenter];
#endif
        m_labelTitle.alpha = 1.0f;
        [self addSubview:m_labelTitle];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songsListWillShow)
                                                     name:PPNotification_SongsListWillShow
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songsListWillHide)
                                                     name:PPNotification_SongsListWillHide
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateSong)
                                                     name:PPNotification_SongWillBePlayed
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateSong)
                                                     name:PPNotification_SongPlaysEnd
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateSong)
                                                     name:PPNotification_SongsListDidSelect
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [m_dynamicProgress release];
    [m_labelTitle release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

+ (StatusBar *)sharedStatusBar
{
    if (nil == instance)
    {
        instance = [[StatusBar alloc] init];
    }
    return instance;
}

- (void)updateSong
{
    Song *theSong = [[[PlayerManager sharedInstance] currentPlayer] currentSong];
    if (nil != theSong)
    {
        [m_labelTitle setText:theSong.title];
    }
    else
    {
        [m_labelTitle setText:@""];
    }
}

- (void)songsListWillShow
{
    [self updateSong];
    [UIView animateWithDuration:0.3
                     animations:^{
                         m_dynamicProgress.alpha = 1.0f;
                         m_labelTitle.alpha = 1.0f;
                         [self setBackgroundColor:[UIColor blackColor]];
                     }];
}

- (void)songsListWillHide
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         m_dynamicProgress.alpha = 0.0f;
                         m_labelTitle.alpha = 0.0f;
                         [self setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.7]];
                     }];
}

@end
