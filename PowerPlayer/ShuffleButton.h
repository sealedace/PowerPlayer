//
//  ShuffleButton.h
//  PowerPlayer
//
//  Created by sealedace on 12-8-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShuffleButtonDelegate;

@interface ShuffleButton : UIControl
{
    UIImageView *m_imageView;
    BOOL m_bShuffle;
    id <ShuffleButtonDelegate> m_delegate;
}

@property (assign) BOOL isShuffle;
@property (nonatomic, assign) id <ShuffleButtonDelegate> delegate;


@end


@protocol ShuffleButtonDelegate<NSObject>
- (void)shuffleButtonPressed:(ShuffleButton*)button;
@end