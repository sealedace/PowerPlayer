//
//  StatusBar.h
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-9.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class ProgressView;
@class DynamicLabel;
@interface StatusBar : UIWindow
{
    ProgressView *m_dynamicProgress;
    DynamicLabel *m_labelTitle;
}

+ (StatusBar *)sharedStatusBar;

@end
