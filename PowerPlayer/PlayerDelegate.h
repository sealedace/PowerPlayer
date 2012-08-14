//
//  PlayerDelegate.h
//  PowerPlayer
//
//  Created by xugaoqiang on 12-6-29.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;
@protocol PlayerDelegate <NSObject>
- (void)playerDidPlayFinished:(Player *)player;
@end
