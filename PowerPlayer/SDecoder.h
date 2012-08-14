//
//  SDecoder.h
//  PowerPlayer
//
//  Created by 许  on 12-6-22.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeDelegate.h"

@class Song;

@interface SDecoder : NSObject
{
    Song *m_audioObject;
    NSObject <DecodeDelegate> *delegate;
    TDecodeError m_decoderResult;
    NSCondition *m_lock;
    BOOL m_bRunning;
    int64_t m_totalTime;
}

@property (nonatomic, assign) NSObject <DecodeDelegate> *delegate;

+ (id)decoderWithAudio:(Song *)song;
- (void)start;
- (void)stop;
- (int64_t)totalTime;
- (TDecodeError)decodeResult;

@end
