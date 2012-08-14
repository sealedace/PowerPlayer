//
//  AudioControlButtonView.h
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-11.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonViewDelegate.h"

@interface AudioControlButtonView : UIView
{
    id<ButtonViewDelegate> m_target;
    UITapGestureRecognizer *m_gestureTapped;
}

@property (nonatomic, assign) id<ButtonViewDelegate> target;

@end
