//
//  SongsListCell.h
//  PowerPlayer
//
//  Created by 许  on 12-6-26.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SongsListCellHeight 50

@class CAEmitterLayer, Song;
@class DynamicLabel;
@interface SongsListCell : UITableViewCell
{
    DynamicLabel *m_labelTitle;
    DynamicLabel *m_labelPerformer;
}

@property (nonatomic, strong) DynamicLabel *titleLabel;
@property (nonatomic, strong) DynamicLabel *performerLabel;
@property (nonatomic, readonly) BOOL isPlaying;
@property (strong) CAEmitterLayer *ringEmitter;
@property (strong) Song *song;

- (void)setPlaying:(BOOL)b;
- (void)updatePlayStatus;

@end
