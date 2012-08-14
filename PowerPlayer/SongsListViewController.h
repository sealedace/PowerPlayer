//
//  SongsListViewController.h
//  PowerPlayer
//
//  Created by 许  on 12-6-26.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayBoard;
@interface SongsListViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    NSTimer *m_timer;
    UITapGestureRecognizer *m_tapGesture;
    PlayBoard *m_playBoard;
}

@property (nonatomic, retain) IBOutlet UITableView *m_tableView;
- (void)showList;
- (void)scrollListToCurrentSong;
@end
