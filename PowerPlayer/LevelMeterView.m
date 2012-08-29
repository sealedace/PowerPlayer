//
//  LevelMeterView.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-11.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "LevelMeterView.h"
#import "PublicDefinitions.h"
#import "Player.h"
#import "PlayerManager.h"

@interface LevelMeterView()
- (void)songWillStart;
- (void)songPlaysEnd;
- (void)updateLevel;

@end

@implementation LevelMeterView
@synthesize position=m_position;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        m_level = 0.;
        m_subRunLoop = NULL;
//        m_meterColor = [[UIColor alloc] initWithRed:0.6
//                                              green:0.8
//                                               blue:0.2
//                                              alpha:1];
        
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


- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGFloat levelHeight = m_level * CGRectGetHeight(rect);
    CGRect rectToFill = CGRectMake(CGRectGetMinX(rect),
                                   CGRectGetMinY(rect)+CGRectGetHeight(rect)-levelHeight,
                                   CGRectGetWidth(rect),
                                   levelHeight);
    [[UIColor colorWithRed:m_level
                     green:m_level/2
                      blue:m_level/2
                     alpha:1] set];
    CGContextFillRect(context, rectToFill);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (NULL != m_subRunLoop)
    {
        CFRunLoopStop(m_subRunLoop);
    }

    [super dealloc];
}

- (void)updateLevel
{
    Player *player = [[PlayerManager sharedInstance] currentPlayer];
    if (nil == player)
    {
        m_level = 0.;
    }
    else if (player.status == Player_Stopped)
    {
        m_level = 0.;
    }
    else
    {
        m_level = (m_position==LevelMeter_Left?[player db].left:[player db].right);
    }

    [self setNeedsDisplay];
}

- (void)createTimer
{
    @autoreleasepool 
    {
        if (NULL == m_subRunLoop)
        {
            m_subRunLoop = CFRunLoopGetCurrent();
            CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self
                                                               selector:@selector(updateLevel)];
            [timer addToRunLoop:[NSRunLoop currentRunLoop]
                        forMode:NSRunLoopCommonModes];
//            [NSTimer scheduledTimerWithTimeInterval:(1.0/30)
//                                             target:self
//                                           selector:@selector(updateLevel) 
//                                           userInfo:nil
//                                            repeats:YES];
            CFRunLoopRun();
        }
    }
}

- (void)songWillStart
{
    m_level = 0;
    
    [self performSelectorInBackground:@selector(createTimer)
                           withObject:nil];
}

- (void)songPlaysEnd
{
    if (NULL != m_subRunLoop)
    {
        CFRunLoopStop(m_subRunLoop);
        m_subRunLoop = NULL;
    }
    
    m_level = 0;
    [self updateLevel];
}

@end
