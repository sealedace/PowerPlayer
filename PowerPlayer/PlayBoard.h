//
//  PlayBoard.h
//  PowerPlayer
//
//  Created by 许  on 12-7-16.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonViewDelegate.h"

@class PlayPauseButtonView, PlayNextButtonView, PlayPreviousButtonView;
@interface PlayBoard : UIView
<ButtonViewDelegate>
{
    PlayPauseButtonView *m_playPauseButton;
    PlayNextButtonView *m_playNextButton;
    PlayPreviousButtonView *m_playPreviousButton;
}

@end
