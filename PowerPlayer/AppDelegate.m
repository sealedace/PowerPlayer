//
//  AppDelegate.m
//  PowerPlayer
//
//  Created by 许  on 12-6-22.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayStationViewController.h"
#import "FileManager.h"
#import "PlayerManager.h"
#import "Player.h"
#import "PublicDefinitions.h"
#import "StatusBar.h"
#include <mach/mach.h>

@implementation AppDelegate
@synthesize window=_window;

- (void)dealloc
{
    [m_playerManager release];
    [m_fileManager release];
    [_window release];
    [m_statusBar release];
    
    [super dealloc];
}

BOOL memoryInfo(vm_statistics_data_t *vmStats)
{    
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)vmStats, &infoCount);
    return kernReturn == KERN_SUCCESS;
}

void logMemoryInfo() 
{    
    vm_statistics_data_t vmStats;
    if (memoryInfo(&vmStats))
    {        
        NSLog(@"free: %u\nactive: %u\ninactive: %u", vmStats.free_count * vm_page_size / 1024, vmStats.active_count * vm_page_size / 1024, vmStats.inactive_count * vm_page_size / 1024);    
    }
}

- (void)printMem
{
    logMemoryInfo();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    m_statusBar = [StatusBar sharedStatusBar];
    
    m_fileManager = [FileManager sharedInstance];
    [FileManager prepareBasicDirectories];
    
    m_playerManager = [PlayerManager sharedInstance];
    
    [NSThread sleepForTimeInterval:1];
    
    PlayStationViewController *aController = [[PlayStationViewController alloc] init];
    self.window.rootViewController = aController;
    [aController release];
    
    [application beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
//    [NSTimer scheduledTimerWithTimeInterval:1
//                                                      target:self
//                                                    selector:@selector(printMem)
//                                                    userInfo:nil
//                                                     repeats:YES];
     
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self becomeFirstResponder];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [application endReceivingRemoteControlEvents];  
}

- (BOOL)canBecomeFirstResponder  
{  
    return YES;  
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent 
{ 
    if (receivedEvent.type == UIEventTypeRemoteControl) 
    {  
        switch (receivedEvent.subtype) 
        {  
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if (Player_Paused == [[m_playerManager currentPlayer] status])
                {
                    [[m_playerManager currentPlayer] play];
                }
                else if (Player_Playing == [[m_playerManager currentPlayer] status])
                {
                    [[m_playerManager currentPlayer] pause];
                }
                break;  
            }
            case UIEventSubtypeRemoteControlPreviousTrack:  
                [m_playerManager previous];  
                break;  
            case UIEventSubtypeRemoteControlNextTrack:  
                [m_playerManager next];  
                break;  
            default:  
                break;  
        }
    }
}


@end
