//
//  ToolBoard.h
//  PowerPlayer
//
//  Created by sealedace on 12-8-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopButton.h"
#import "ShuffleButton.h"

@interface ToolBoard : UIView
<LoopButtonDelegate, ShuffleButtonDelegate>
{
    LoopButton *m_loopButton;
    ShuffleButton *m_shuffleButton;
}

@end
