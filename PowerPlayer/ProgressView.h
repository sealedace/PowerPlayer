//
//  ProgressView.h
//  PowerPlayer
//
//  Created by 许  on 12-7-16.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum PlayerWorkStatus
{
    PlayerWorkStatusPlaySong,
    PlayerWorkStatusDecodeSong
}PlayerWorkStatus;

@interface ProgressView : UIView
{
    double m_progress;
    CFRunLoopRef m_subRunLoop;
    PlayerWorkStatus m_TMode;
}

- (id)initWithFrame:(CGRect)frame mode:(PlayerWorkStatus)mode;
- (void)updatePlayTimeLine:(NSTimeInterval)time totalTime:(NSTimeInterval)totalTime;

@end
