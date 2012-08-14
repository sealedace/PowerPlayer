//
//  LoopButton.h
//  PowerPlayer
//
//  Created by sealedace on 12-8-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum LoopMode
{
    LoopMode_None,
    LoopMode_All,
    LoopMode_Single
}LoopMode;

@protocol LoopButtonDelegate;

@interface LoopButton : UIControl
{
    LoopMode m_loopMode;
    UIImageView *m_imageView;
    id <LoopButtonDelegate> m_delegate;
}

@property (nonatomic, readonly) LoopMode loopMode;
@property (nonatomic, assign) id <LoopButtonDelegate> delegate;

@end

@protocol LoopButtonDelegate <NSObject>

- (void)loopButtonPressed:(LoopButton*)button;

@end