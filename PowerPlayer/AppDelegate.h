//
//  AppDelegate.h
//  PowerPlayer
//
//  Created by 许  on 12-6-22.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FileManager;
@class PlayerManager;
@class StatusBar;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    FileManager *m_fileManager;
    PlayerManager *m_playerManager;
    StatusBar *m_statusBar;
}

@property (strong, nonatomic) UIWindow *window;

@end
