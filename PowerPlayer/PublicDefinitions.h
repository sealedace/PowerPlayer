//
//  PublicDefinitions.h
//  PowerPlayer
//
//  Created by 许  on 12-6-27.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

/* 日志打印控制开关  开->1  关->0 */
#define LOG_STATE 1         // 日志总开关控制
#define SERVICE_LOG_STATE 1 // 接口的日志控制

#if LOG_STATE
    #define LOGS(msg1, ...) NSLog(msg1, ##__VA_ARGS__)
    #if SERVICE_LOG_STATE
        #define SERVICE_LOG(msg1, ...) NSLog(msg1, ##__VA_ARGS__)
    #else
        #define SERVICE_LOG(msg1, ...)
    #endif
#else
    #define LOGS(msg1, ...)
    #define SERVICE_LOG(msg1, ...)
#endif

#pragma mark -
#pragma mark release函数宏
// 安全release函数宏
#define SAFE_RELEASE(object)\
{\
    if (nil != object)\
    {\
        [object release];\
        object = nil;\
    }\
}

// Decode notifications
#define PPNotification_WillBeginDecoding       @"WillBeginDecoding"
#define PPNotification_DecoderEncounteredError @"DecoderEncounteredError"
#define PPNotification_FinishDecodingASong     @"FinishDecoding"

// Play notifications
#define PPNotification_SongWillBePlayed      @"SongWillBePlayed"
#define PPNotification_NextSongWillBePlayed  @"NextSongWillBePlayed"
#define PPNotification_SongPlaysEnd          @"SongPlaysEnd"

// Button events notifications
#define PPNotification_NextButtonPressed     @"NextButtonPressed"
#define PPNotification_PreviousButtonPressed @"PreviousButtonPressed"
#define PPNotification_PlayerStopped         @"PlayerStopped"

// UI Events Notifications
#define PPNotification_SongsListWillShow @"SongsListWillShow"
#define PPNotification_SongsListWillHide @"SongsListWillHide"
#define PPNotification_SongsListDidSelect @"SongIsSelected"


