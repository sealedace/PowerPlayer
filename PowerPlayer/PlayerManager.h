//
//  PlayerManager.h
//  PowerPlayer
//
//  Created by 许  on 12-6-27.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerDelegate.h"

@class Player, Song;

typedef enum _PlayMode
{
    PlayMode_Normal,
    PlayMode_Shuffle,
    PlayMode_Single
}TPlayMode;

@interface PlayerManager : NSObject
<PlayerDelegate>
{
    Player *m_player;
    BOOL m_bIsLoop;
    TPlayMode m_playMode;
    
    NSMutableArray *m_arrayOrder; // order for playing control
    NSMutableArray *m_arrayDisplayOrder; // order for display the song list
    
    NSInteger m_currentIndex;
}

+ (PlayerManager *)sharedInstance;
- (Song *)songAtIndex:(NSUInteger)index;
- (Song *)songAtListIndex:(NSUInteger)index;
- (void)setPlayMode:(TPlayMode)mode;
- (void)setLoop:(BOOL)bLoop;
- (void)playAudio:(Song *)song;
- (void)playAudioAtFileIndex:(NSInteger)index;
- (Player *)currentPlayer;
- (void)reorder;
- (void)stop;
- (void)previous;
- (void)next;

@end
