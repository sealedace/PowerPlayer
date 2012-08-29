//
//  PlayerManager.m
//  PowerPlayer
//
//  Created by 许  on 12-6-27.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "PlayerManager.h"
#import "PublicDefinitions.h"
#import "Player.h"
#import "FileManager.h"
#import "Song.h"

static PlayerManager *instance = nil;

@interface PlayerManager()
- (void)shuffle;
@end

@implementation PlayerManager

+ (PlayerManager *)sharedInstance
{
    if (nil == instance)
    {
        instance = [[PlayerManager alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        m_player = nil;
        m_playMode = PlayMode_Shuffle;
        m_currentIndex = 0;
        m_bIsLoop = YES;
        // 
        NSInteger iTotal = [[[FileManager sharedInstance] allSongs] count];
        m_arrayOrder = [[NSMutableArray alloc] initWithCapacity:iTotal];
        for (NSUInteger i=0; i<iTotal; i++)
        {
            [m_arrayOrder addObject:[NSNumber numberWithInt:i]];
        }
        
        m_arrayDisplayOrder = [[NSMutableArray alloc] initWithCapacity:iTotal];
        for (NSUInteger i=0; i<iTotal; i++)
        {
            [m_arrayDisplayOrder addObject:[NSNumber numberWithInt:i]];
        }
        [self reorder];
    }
    return self;
}

- (void)dealloc
{
    SAFE_RELEASE(m_player);
    SAFE_RELEASE(m_arrayOrder);
    SAFE_RELEASE(m_arrayDisplayOrder);
    [super dealloc];
}

#pragma -
- (void)playAudioAtFileIndex:(NSInteger)index
{
    Song *songToPlay = [self songAtIndex:index];
    Player *player = [self currentPlayer];
    if (nil == player)
    {
        [self playAudio:songToPlay];
        return;
    }

    Song *currentSong = [player currentSong];
    if (currentSong == songToPlay)
    {
        return;
    }
    else
    {
        [self playAudio:songToPlay];
    }
}

- (void)playAudio:(Song *)song
{
    [self stop];
    
    if (nil == m_player)
    {
        m_player = [[Player alloc] initWithSong:song];
        m_currentIndex = song.pIndex;
        [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_SongsListDidSelect
                                                            object:nil];
        m_player.delegate = self;
        [m_player play];
    }
}

- (void)setPlayMode:(TPlayMode)mode
{
    m_playMode = mode;
    if (mode == PlayMode_Shuffle)
    {
        [self shuffle];
    }
}

- (void)setLoop:(BOOL)bLoop
{
    m_bIsLoop = bLoop;
}

- (Player *)currentPlayer
{
    return m_player;
}

- (Song *)songAtIndex:(NSUInteger)index
{
    return [[[FileManager sharedInstance] allSongs] objectAtIndex:[[m_arrayOrder objectAtIndex:index] integerValue]];
}

- (Song *)songAtListIndex:(NSUInteger)index
{
    return [[[FileManager sharedInstance] allSongs] objectAtIndex:[[m_arrayDisplayOrder objectAtIndex:index] integerValue]];
}

- (void)shuffle
{
    for (NSInteger i=([m_arrayOrder count]-1); i>=0; i--)
    {
        int index = arc4random() % (i+1);//(int)(i*1.0*rand()/RAND_MAX);
        [m_arrayOrder exchangeObjectAtIndex:i withObjectAtIndex:index];
    }
    
    for (NSUInteger i=0;i<[m_arrayOrder count]; i++)
    {
        Song *oneSong = [self songAtIndex:i];
        oneSong.pIndex = i;
    }
}

- (void)reorder
{
    if (m_playMode == PlayMode_Shuffle)
    {
        // do shuffle
        [self shuffle];
    }
}

- (void)stop
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_PlayerStopped
                                                        object:nil];
    SAFE_RELEASE(m_player);
}

- (void)previous
{
    if (NO == m_bIsLoop
        && m_currentIndex == 0)
    {
        return;
    }
    
    if (m_currentIndex == 0)
    {
        m_currentIndex = [m_arrayOrder count];
    }
    
    [self stop];

    m_currentIndex--;
    [self playAudioAtFileIndex:m_currentIndex];
}

- (void)next
{
    NSInteger total = [m_arrayOrder count];
    if (NO == m_bIsLoop 
        && m_currentIndex >= (total-1))
    {
        return;
    }
    
    if (m_currentIndex == (total-1))
    {
        m_currentIndex = -1;
    }

    [self stop];
    
    m_currentIndex++;
    [self playAudioAtFileIndex:m_currentIndex];
}

#pragma mark -
#pragma mark PlayerDelegate
- (void)playerDidPlayFinished:(Player *)player
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_SongPlaysEnd
                                                        object:nil];
    [self stop];
    [self next];
}


@end
