//
//  LevelMeterView.h
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-11.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum LevelMeterPosition
{
    LevelMeter_Left,
    LevelMeter_Right
}LevelMeterPosition;

@interface LevelMeterView : UIView
{
    double m_level;
    CFRunLoopRef m_subRunLoop;
}

@property (nonatomic, assign) LevelMeterPosition position;

@end
