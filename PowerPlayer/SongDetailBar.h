//
//  SongDetailBar.h
//  PowerPlayer
//
//  Created by 许  on 12-7-5.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Song;
@class DynamicLabel;
@interface SongDetailBar : UIControl
{
    DynamicLabel *m_labelTitle;
    DynamicLabel *m_labelPerformer;
    Song *currentSong;
}

@property (nonatomic, retain) Song *currentSong;

- (void)setSongData:(Song *)data;


@end
