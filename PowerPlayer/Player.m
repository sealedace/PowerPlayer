//
//  Player.m
//  PowerPlayer
//
//  Created by 许  on 12-6-23.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "Player.h"
#import "FileManager.h"
#import "SDecoder.h"
#import "PublicDefinitions.h"
#import "PlayerManager.h"
#import "Song.h"
#import "MeterTable.h"
#import "MediaPlayer/MediaPlayer.h"

static UInt32 gBufferSizeBytes = 0x10000;
static void BufferCallback(void *inUserData, AudioQueueRef inAQ,
                           AudioQueueBufferRef buffer);


@interface Player ()
- (void) play:(NSURL *)path;
- (void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                       queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_0
- (void)didReceivedInterruptNotification:(NSNotification *)notification;
#endif
@end

@implementation Player
@synthesize isDecoding = m_bIsDecoding;
@synthesize delegate = m_delegte;
@synthesize audioFileID = m_audioFileID;
@synthesize isPausedByUser=m_bPauseByUser;

- (id)initWithSong:(Song *)song
{
    self = [super init];
    if (self)
    {
        for(int i=0; i<NUM_BUFFERS; i++)
        {
            AudioQueueEnqueueBuffer(m_queue, m_buffers[i], 0, nil);
        }
        m_bPauseByUser = NO;
        m_bIsDecoding = NO;
        m_playerStatus = Player_Stopped;
        m_totalTime = 0;
        m_delegte = nil;
        m_meterTable = [[MeterTable alloc] init];
        m_song = [song retain];

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_0
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedInterruptNotification:) name:AVAudioSessionInterruptionNotification object:nil];
#endif
    }
    return self;
}

- (void)dealloc
{
    free(m_channelLevels);
    AudioQueueDispose(m_queue, YES);
    [self stop];
    [m_song release];
    
    [m_meterTable release];
    [super dealloc];
}

#pragma mark -
#pragma mark Play Control

- (void)play
{
    if (m_playerStatus == Player_Playing)
    {
        return;
    }
    else if (m_playerStatus == Player_Paused)
    {
        m_playerStatus = Player_Playing;
        AudioQueueStart(m_queue, NULL);
        return;
    }
    
    m_channelLevels = malloc(2 * sizeof(AudioQueueLevelMeterState));
    m_playerStatus = Player_Playing;
    m_totalTime = 0;
    
    if ([m_song.file hasSuffix:@"mp3"])
    {
        m_bIsDecoding = NO;
        NSURL *url = [NSURL fileURLWithPath:m_song.file];
        [self performSelector:@selector(play:)
                   withObject:url
                   afterDelay:0.3];
    }
    else
    {
        m_decoder = [SDecoder decoderWithAudio:m_song];
        m_decoder.delegate = self;
        [m_decoder start];
        m_bIsDecoding = YES;
    }
}


- (void)pause
{
    if (m_playerStatus == Player_Paused)
    {
        return;
    }
    AudioQueuePause(m_queue);
    m_playerStatus = Player_Paused;
}

- (void)stop
{
    if (m_playerStatus == Player_Stopped)
    {
        return;
    }
    if (m_playerStatus == Player_Playing)
    {
        m_playerStatus = Player_Stopped;
        AudioQueueStop(m_queue, YES);
    }
        
    if (nil != m_decoder)
    {
        [m_decoder stop];
        m_decoder = nil;
    }
    
}

- (Song *)currentSong
{
    return m_song;
}

- (TPlayerStatus)status
{
    return m_playerStatus;
}

- (NSTimeInterval)currentTime
{
    NSTimeInterval interval = 0;
    AudioQueueTimelineRef timeline;
    OSStatus status = AudioQueueCreateTimeline(m_queue, &timeline);
    if (status == noErr)
    {
        AudioTimeStamp timeStamp;
        AudioQueueGetCurrentTime(m_queue, timeline, &timeStamp, NULL);
        interval = timeStamp.mSampleTime / m_dataFormat.mSampleRate;
    }

    return interval;
}

- (NSTimeInterval)totalTime
{
    return m_totalTime;
}

- (double)progress
{
    return ([self currentTime]/m_totalTime);
}

- (AudioDB)db
{
    AudioDB levelDB;
    levelDB.left = 0.;
    levelDB.right = 0.;
    UInt32 propertySize = m_dataFormat.mChannelsPerFrame * sizeof (AudioQueueLevelMeterState);

    AudioQueueGetProperty(m_queue, kAudioQueueProperty_CurrentLevelMeterDB, m_channelLevels, &propertySize);
    if (NULL == m_channelLevels)
    {
        return levelDB;
    }
    levelDB.left = [m_meterTable valueAt:(float)m_channelLevels[1].mAveragePower];
    levelDB.right = [m_meterTable valueAt:(float)m_channelLevels[0].mAveragePower];
    return levelDB;
}

#pragma mark -
#pragma mark Decode Delegate

- (void)decoderWillBeginDecode:(SDecoder *)decoder
{
    LOGS(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    m_backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    m_totalTime = (NSTimeInterval)[decoder totalTime];
    
    [self performSelector:@selector(play:)
               withObject:[NSURL URLWithString:[FileManager outputFile]]
               afterDelay:0.8];
}

- (void)decoderEncounteredError:(SDecoder *)decoder
{
    LOGS(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    m_bIsDecoding = NO;
    m_decoder = nil;
    m_playerStatus = Player_Stopped;
    if (nil != m_delegte && YES == [m_delegte respondsToSelector:@selector(playerDidPlayFinished:)])
    {
        [m_delegte playerDidPlayFinished:self];
    }
    [[UIApplication sharedApplication] endBackgroundTask:m_backgroundTaskIdentifier];
}

- (void)decoderDidFinishDecoding:(SDecoder *)decoder
{
    LOGS(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    m_bIsDecoding = NO;
    m_decoder = nil;
    AudioFileClose(m_audioFileID);
    AudioFileOpenURL((CFURLRef)[NSURL URLWithString:[FileManager outputFile]],
                     kAudioFileReadPermission, 0, &m_audioFileID);
    
    [[UIApplication sharedApplication] endBackgroundTask:m_backgroundTaskIdentifier];
}

#pragma mark -
#pragma mark AudioQueue
static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer)
{
    Player *player = (Player*)inUserData;
    if ([player status] == Player_Stopped)
    {
        AudioFileClose(player.audioFileID);
        return;
    }
    [player  audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

- (void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                       queueBuffer:(AudioQueueBufferRef)audioQueueBuffer
{
    OSStatus status;
    UInt32  numBytes;
    UInt32  numPackets = m_numPacketsToRead;
    status = AudioFileReadPackets(m_audioFileID, NO, &numBytes, m_packetDescs,
                                  m_packetIndex, &numPackets, audioQueueBuffer->mAudioData);
    if (numPackets > 0)
    {
        audioQueueBuffer->mAudioDataByteSize = numBytes;
        status = AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffer, (m_packetDescs?numPackets:0), m_packetDescs);
        m_packetIndex += numPackets;
        
        if (YES == m_bIsDecoding)
        {
            m_queueCompleteCount++;
            if (m_queueCompleteCount%(NUM_BUFFERS/2)==0)
            {
                // Re-open file to keep moving...
                NSLog(@"Re-open file");
                AudioFileClose(m_audioFileID);
                AudioFileOpenURL((CFURLRef)[NSURL URLWithString:[FileManager outputFile]],
                                 kAudioFileReadPermission, 0, &m_audioFileID);
            }
        }
    }
    else
    {
        m_queueCountDown--;
        AudioQueueFreeBuffer(audioQueue, audioQueueBuffer);
        if (0 == m_queueCountDown)
        {
            NSLog(@"Audio play ends.");
            AudioFileClose(m_audioFileID);
            m_playerStatus = Player_Stopped;
            if (nil != m_delegte && YES == [m_delegte respondsToSelector:@selector(playerDidPlayFinished:)])
            {
                [m_delegte playerDidPlayFinished:self];
            }
        }
    }
}

#pragma mark -
// Use AudioQueue for playing audio
-(void)play:(NSURL *)path
{
    if (nil == path)
    {
        return;
    }
    
    UInt32 size, maxPacketSize;
    char *cookie;
    
    // 1. Open output file
    OSStatus status;
    status = AudioFileOpenURL((CFURLRef)path, kAudioFileReadPermission, 0, &m_audioFileID);
    if (status != noErr)
    {
        // Error handling...
        LOGS(@"Open file failed.");
        return;
    }
    
    // 2. Get data format
    size = sizeof(m_dataFormat);
    AudioFileGetProperty(m_audioFileID, kAudioFilePropertyDataFormat, &size, &m_dataFormat);

    // 3. Creates a new audio queue for playing audio data
    AudioQueueNewOutput(&m_dataFormat, BufferCallback,
                        self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &m_queue);

    // 4. Calculate number of packets to read per second
    if (m_dataFormat.mBytesPerPacket == 0 || m_dataFormat.mFramesPerPacket == 0)
    {
        size = sizeof(maxPacketSize);
        AudioFileGetProperty(m_audioFileID,
                             kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
        if (maxPacketSize > gBufferSizeBytes)
        {
            maxPacketSize = gBufferSizeBytes;
        }

        m_numPacketsToRead = gBufferSizeBytes / maxPacketSize;
        m_packetDescs = malloc(sizeof(AudioStreamPacketDescription) * m_numPacketsToRead);
    }
    else
    {
        m_numPacketsToRead = gBufferSizeBytes / m_dataFormat.mBytesPerPacket;
        m_packetDescs = nil;
    }

    // 5. Enabling metering for the audio queue object
    UInt32 on = 1;
    status = AudioQueueSetProperty(m_queue, kAudioQueueProperty_EnableLevelMetering, &on, sizeof(on));
    
    // 6. Get Magic Cookie Size & set Magic cookie
    AudioFileGetPropertyInfo(m_audioFileID, kAudioFilePropertyMagicCookieData, &size, nil);
    if (size > 0)
    {
        cookie = malloc(sizeof(char) * size);
        AudioFileGetProperty(m_audioFileID, kAudioFilePropertyMagicCookieData, &size, cookie);
        AudioQueueSetProperty(m_queue, kAudioQueueProperty_MagicCookie, cookie, size);
        free(cookie);
    }

    // 7. Fill buffers before start to play
    m_packetIndex = 0;
    for (int i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueAllocateBuffer(m_queue, gBufferSizeBytes, &m_buffers[i]);

        if ([self readPacketsIntoBuffer:m_buffers[i]] == 0)
        {
            break;
        }
    }
    
    // 8. Initialize some variables
    m_queueCompleteCount = 0;
    m_queueCountDown = NUM_BUFFERS;

    // 9. set volume
    Float32 gain = 1.0;
    AudioQueueSetParameter(m_queue, kAudioQueueParam_Volume, gain);
    
    // 10. set artwork
    if ([MPNowPlayingInfoCenter class])
    {
        /* we're on iOS 5, so set up the now playing center */
        UIImage *imageCover = nil;
        AVURLAsset *avURLAsset = [AVURLAsset URLAssetWithURL:path
                                                     options:nil];
        for (NSString *format in [avURLAsset availableMetadataFormats])
        {
            for (AVMetadataItem *metadataItem in [avURLAsset metadataForFormat:format])
            {
                if ([metadataItem.commonKey isEqualToString:@"artwork"])
                {
                    imageCover = [[UIImage alloc] initWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                    break;
                }
            }
        }
        MPMediaItemArtwork *itemArtwork = nil;
        if (imageCover == nil)
        {
            itemArtwork = [[MPMediaItemArtwork alloc] init];
        }
        else
        {
            itemArtwork = [[MPMediaItemArtwork alloc] initWithImage:imageCover];
        }
        
        SAFE_RELEASE(imageCover);
        
        NSDictionary *currentlyPlayingTrackInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:m_song.title, itemArtwork, nil]
                                                                              forKeys:[NSArray arrayWithObjects:MPMediaItemPropertyTitle,MPMediaItemPropertyArtwork, nil]];
        [itemArtwork release];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = currentlyPlayingTrackInfo;
    }
    
    // 11. Start the audio queue
    [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_SongWillBePlayed
                                                        object:nil];
    
    AudioQueueStart(m_queue, nil);

    // 12. Enable play in background
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_0
    [audioSession setDelegate:self];
#endif
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer
{
    UInt32 numBytes, numPackets;
    
    // 从文件中接受包数据并保存到缓存(buffer)中
    numPackets = m_numPacketsToRead;
    
    AudioFileReadPackets(m_audioFileID, NO, &numBytes, m_packetDescs,
                         m_packetIndex, &numPackets, buffer->mAudioData);
    
    if (numPackets > 0)
    {
        buffer->mAudioDataByteSize = numBytes;
        AudioQueueEnqueueBuffer(m_queue, buffer,
                                (m_packetDescs ? numPackets : 0), m_packetDescs);
        m_packetIndex += numPackets;
    }
    return numPackets;
}

#pragma mark -
#pragma mark AVAudioSessionDelegate
- (void)beginInterruption
{
    if (m_playerStatus == Player_Playing)
    {
        [self pause];
    }
}

- (void)endInterruption
{
    if (m_playerStatus == Player_Paused)
    {
        if (NO == m_bPauseByUser)
        {
            [self play];
        }
    }
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_0
- (void)didReceivedInterruptNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *type = [userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    switch ([type integerValue])
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [self beginInterruption];
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
        {
            [self endInterruption];
            break;
        }
        default:
            break;
    }
}
#endif

@end
