//
//  ProgressView.m
//  PowerPlayer
//
//  Created by 许  on 12-7-16.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "ProgressView.h"
#import "PlayerManager.h"
#import "Player.h"
#import "PublicDefinitions.h"

@interface ProgressView ()
- (void)songWillStart;
- (void)songPlaysEnd;
- (void)willBeginDecode;
- (void)decodeEnds;

- (void)updateProgress;
@end

@implementation ProgressView

- (id)initWithFrame:(CGRect)frame mode:(PlayerWorkStatus)mode
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        m_subRunLoop = NULL;
        m_progress = 0.f;
        
        m_TMode = mode;
        
        if (m_TMode == PlayerWorkStatusPlaySong)
        {
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
        else if (m_TMode == PlayerWorkStatusDecodeSong)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(willBeginDecode)
                                                         name:PPNotification_WillBeginDecoding
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(decodeEnds)
                                                         name:PPNotification_FinishDecodingASong
                                                       object:nil];
        }
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [[UIColor colorWithRed:0.6
                     green:.8
                      blue:.2
                     alpha:1] set];
    
    CGRect rectToFill = CGRectMake(0, 0, CGRectGetWidth(rect)*m_progress, CGRectGetHeight(rect));
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

- (void)createTimer
{
    @autoreleasepool
    {
        if (NULL == m_subRunLoop)
        {
            m_subRunLoop = CFRunLoopGetCurrent();
            CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self
                                                               selector:@selector(updateProgress)];
            [timer addToRunLoop:[NSRunLoop currentRunLoop]
                        forMode:NSRunLoopCommonModes];
//            [NSTimer scheduledTimerWithTimeInterval:(m_TMode==PlayerWorkStatusPlaySong?(1.0/4):(1.0/30))
//                                             target:self
//                                           selector:@selector(updateProgress)
//                                           userInfo:nil
//                                            repeats:YES];
            CFRunLoopRun();
        }
    }
}

- (void)songWillStart
{
    m_progress = 0;
    [self performSelectorInBackground:@selector(createTimer)
                           withObject:nil];
}

- (void)songPlaysEnd
{
    m_progress = 0;
    [self setNeedsDisplay];
    if (NULL != m_subRunLoop)
    {
        CFRunLoopStop(m_subRunLoop);
        m_subRunLoop = NULL;
    }
}

- (void)willBeginDecode
{
    m_progress = 0;
    
    [self performSelectorInBackground:@selector(createTimer)
                           withObject:nil];
}

- (void)decodeEnds
{
    if (NULL != m_subRunLoop)
    {
        CFRunLoopStop(m_subRunLoop);
        m_subRunLoop = NULL;
    }
}

- (void)updateProgress
{
    if (m_TMode == PlayerWorkStatusPlaySong)
    {
        Player *player = [[PlayerManager sharedInstance] currentPlayer];
        [self updatePlayTimeLine:[player currentTime] totalTime:[player totalTime]];
    }
}

- (void)updatePlayTimeLine:(NSTimeInterval)time totalTime:(NSTimeInterval)totalTime
{
    if (time < FLT_EPSILON || totalTime < FLT_EPSILON)
    {
        m_progress = 0;
    }
    else if (time > totalTime)
    {
        m_progress = 0;
    }
    else
    {
        m_progress = 1.0 * time / totalTime;
    }
    
    [self setNeedsDisplay];
}



@end
