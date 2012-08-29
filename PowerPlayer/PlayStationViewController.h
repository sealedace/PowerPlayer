//
//  PlayStationViewController.h
//  PowerPlayer
//
//  Created by 许  on 12-7-14.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongDetailBar;
@class CAEmitterLayer;
@class ToolBoard;
@interface PlayStationViewController : UIViewController
{
    SongDetailBar *m_songDetailBar;
//    ToolBoard *m_toolBoard;
    CFRunLoopRef m_subRunLoop;
}

@property (strong) CAEmitterLayer *ringEmitter;

@end
