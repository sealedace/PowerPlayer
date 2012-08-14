//
//  Player.h
//  PowerPlayer
//
//  Created by 许  on 12-6-23.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#import <AVFoundation/AVFoundation.h>
#import "DecodeDelegate.h"
#import "PlayerDelegate.h"

#define NUM_BUFFERS 4

typedef enum _playerStatus
{
    Player_Playing,
    Player_Paused,
    Player_Stopped,
}TPlayerStatus;

typedef struct AudioDB
{
    double left;
    double right;
}AudioDB;

@class Song,MeterTable;

@interface Player : NSObject
<DecodeDelegate, AVAudioSessionDelegate>
{
    Song *m_song;
    
    AudioFileID m_audioFileID;
    
    AudioStreamBasicDescription m_dataFormat;
    
    AudioQueueRef m_queue;
    
    SInt64 m_packetIndex;
    
    UInt32 m_numPacketsToRead;
    
    UInt32 m_bufferByteSize;
    
    AudioStreamPacketDescription *m_packetDescs;
    
    AudioQueueBufferRef m_buffers[NUM_BUFFERS];
    
    NSInteger m_queueCompleteCount;
    NSInteger m_queueCountDown;
    
    UIBackgroundTaskIdentifier m_backgroundTaskIdentifier;
    
    TPlayerStatus m_playerStatus;
    
    BOOL m_bPauseByUser;
    
    SDecoder *m_decoder;
    
    NSTimeInterval m_totalTime;
    
    id <PlayerDelegate> delegate;
    
    MeterTable *m_meterTable;
    
    AudioQueueLevelMeterState *m_channelLevels;
}

@property (nonatomic, assign) BOOL isDecoding;
@property (nonatomic, assign) id <PlayerDelegate> delegate;
@property (readonly) AudioFileID audioFileID;
@property (nonatomic, assign) BOOL isPausedByUser;

- (id)initWithSong:(Song *)song;
- (Song *)currentSong;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)totalTime;
- (double)progress;
- (AudioDB)db;

- (void)play;
- (void)pause;
- (void)stop;
- (TPlayerStatus)status;

@end
