//
//  PlayStationViewController.m
//  PowerPlayer
//
//  Created by 许  on 12-7-14.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "PlayStationViewController.h"
#import "SongDetailBar.h"
#import "SongsListViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import "PublicDefinitions.h"
#import "Player.h"
#import "PlayerManager.h"
//#import "ToolBoard.h"

#define HeadHeight 60.0f

@interface PlayStationViewController ()
- (void)songWillStart;
- (void)songPlaysEnd;
- (void)updateEmitter;
- (void)detailViewTouched;
@end

@implementation PlayStationViewController
@synthesize ringEmitter=m_ringEmitter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    m_subRunLoop = NULL;
    CGRect viewBounds = self.view.layer.bounds;
	
	// Create the emitter layer
	self.ringEmitter = [CAEmitterLayer layer];
	self.ringEmitter.emitterPosition = CGPointMake(viewBounds.size.width/2.0, viewBounds.size.height/2.0);
	self.ringEmitter.emitterSize	= CGSizeMake(0, 0);
	self.ringEmitter.emitterMode	= kCAEmitterLayerOutline;
	self.ringEmitter.emitterShape	= kCAEmitterLayerCircle;
	self.ringEmitter.renderMode		= kCAEmitterLayerAdditive;
    self.ringEmitter.spin = M_PI_4;
    
    // blue
    CAEmitterCell* circle = [CAEmitterCell emitterCell];
	[circle setName:@"circle"];
	circle.birthRate		= 100;
	circle.velocity			= 80;
	circle.scale			= 0.5;
    circle.spin = M_PI_2;
	circle.scaleSpeed		=-0.2;
	circle.greenSpeed		=-0.1;
	circle.redSpeed			=-0.2;
	circle.blueSpeed		= 0.1;
	circle.alphaSpeed		=-0.2;
	circle.lifetime			= 5;
	
	circle.color = [[UIColor whiteColor] CGColor];
	circle.contents = (id) [[UIImage imageNamed:@"DazRing"] CGImage];
    
    // red
    CAEmitterCell* circle1 = [CAEmitterCell emitterCell];
	[circle1 setName:@"circle1"];
	circle1.birthRate		= 100;
	circle1.velocity		= 80;
	circle1.scale			= 0.6;
    circle1.spin = M_PI;
	circle1.scaleSpeed		=-0.2;
	circle1.greenSpeed		= 0.1;
	circle1.redSpeed		= 0.3;
	circle1.blueSpeed		= 0.1;
	circle1.alphaSpeed		=-0.2;
	circle1.lifetime		= 5;
	
	circle1.color = [[UIColor whiteColor] CGColor];
	circle1.contents = (id) [[UIImage imageNamed:@"DazRing"] CGImage];
    
    // green
    CAEmitterCell* circle2 = [CAEmitterCell emitterCell];
	[circle2 setName:@"circle2"];
	circle2.birthRate		= 100;
	circle2.velocity		= 80;
	circle2.scale			= 0.5;
    circle2.spin = M_PI_4;
	circle2.scaleSpeed		=-0.2;
	circle2.greenSpeed		= 0.2;
	circle2.redSpeed		= 0.1;
	circle2.blueSpeed		= 0.1;
	circle2.alphaSpeed		=-0.2;
	circle2.lifetime		= 5;
	
	circle2.color = [[UIColor whiteColor] CGColor];
	circle2.contents = (id) [[UIImage imageNamed:@"DazRing"] CGImage];
    
    self.ringEmitter.emitterCells = [NSArray arrayWithObjects:circle, circle1, circle2, nil];
    
    // Head
    CGRect frameSongDetailBar = CGRectMake(0, 0, CGRectGetWidth([[self view] frame]), HeadHeight);
    m_songDetailBar = [[SongDetailBar alloc] initWithFrame:frameSongDetailBar];
    [m_songDetailBar addTarget:self
                        action:@selector(detailViewTouched)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_songDetailBar];
    
//    m_toolBoard = [[ToolBoard alloc] initWithFrame:frameSongDetailBar];
//    [self.view addSubview:m_toolBoard];
    
    // Body
    CGRect frameSongsListViewController = CGRectMake(0,
                                                     CGRectGetMaxY(frameSongDetailBar),
                                                     CGRectGetWidth([self.view frame]),
                                                     CGRectGetHeight([self.view frame])-CGRectGetMaxY(frameSongDetailBar));
    SongsListViewController *songsListViewController = [[SongsListViewController alloc] init];
    [songsListViewController.view setFrame:frameSongsListViewController];
    [self addChildViewController:songsListViewController];
    [self.view addSubview:songsListViewController.view];
    [songsListViewController release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songWillStart)
                                                 name:PPNotification_SongWillBePlayed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songPlaysEnd)
                                                 name:PPNotification_SongPlaysEnd
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songPlaysEnd)
                                                 name:PPNotification_PlayerStopped
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_songDetailBar release];
    [m_ringEmitter release];
//    [m_toolBoard release];
    [super dealloc];
}

- (void)createTimer
{
    @autoreleasepool 
    {
        if (NULL == m_subRunLoop)
        {
            m_subRunLoop = CFRunLoopGetCurrent();
            [NSTimer scheduledTimerWithTimeInterval:(1.0/15)
                                             target:self
                                           selector:@selector(updateEmitter) 
                                           userInfo:nil
                                            repeats:YES];
            CFRunLoopRun();
        }
    }
}

- (void)songWillStart
{
    m_ringEmitter.emitterSize = CGSizeMake(0, 0);
    for (CAEmitterCell* circle in [m_ringEmitter emitterCells])
    {
        circle.velocity = 0;
        circle.birthRate = 0;
    }

    if (![m_ringEmitter superlayer])
        [self.view.layer insertSublayer:m_ringEmitter
                                atIndex:0];
    
    [self performSelectorInBackground:@selector(createTimer)
                           withObject:nil];
}

- (void)songPlaysEnd
{
    if (NULL != m_subRunLoop)
    {
        CFRunLoopStop(m_subRunLoop);
        m_subRunLoop = NULL;
    }
    m_ringEmitter.emitterSize = CGSizeMake(0, 0);
    
    for (CAEmitterCell* circle in [m_ringEmitter emitterCells])
    {
        circle.velocity = 0;
        circle.birthRate = 0;
    }
}

- (void)updateEmitter
{
    Player *player = [[PlayerManager sharedInstance] currentPlayer];
    double level = 0.;
    if (nil == player)
    {
        level = 0.;
    }
    else if (player.status == Player_Stopped)
    {
        level = 0.;
    }
    else
    {
        AudioDB db = [player db];
        level = (db.left+db.right)/2;
    }
    
    // Rank for better effect
    if (level < 0.1)
    {
        level = 0;
    }
    else if (level >= 0.1 && level < 0.3)
    {
        level = 0.2;
    }
    else if (level >= 0.3 && level < 0.5)
    {
        level = 0.4;
    }
    else if (level >= 0.5 && level < 0.8)
    {
        level = 0.7;
    }
    else if (level >= 0.8 && level < 0.9)
    {
        level = 0.9;
    }
    
    m_ringEmitter.emitterSize = CGSizeMake(1*level, 1*level);
    CAEmitterCell* circle = [[m_ringEmitter emitterCells] objectAtIndex:0];
    
    circle.velocity = 180*level;
    circle.greenSpeed = -level;	// shifting to blue
	circle.redSpeed	= -level;
	circle.blueSpeed = level;
    circle.birthRate = 60*level;
    
    CAEmitterCell* circle1 = [[m_ringEmitter emitterCells] objectAtIndex:1];
    
    circle1.velocity = 170*level;
    circle1.greenSpeed = -level;	// shifting to blue
	circle1.redSpeed	= level;
	circle1.blueSpeed = -level;
    circle1.birthRate = 60*level;
    
    CAEmitterCell* circle2 = [[m_ringEmitter emitterCells] objectAtIndex:2];
    
    circle2.velocity = 160*level;
    circle2.greenSpeed = level;	// shifting to blue
	circle2.redSpeed	= -level;
	circle2.blueSpeed = -level;
    circle2.birthRate = 60*level;
}

- (void)detailViewTouched
{
    NSArray *arrChildViewControllers = [self childViewControllers];
    for (UIViewController *oneController in arrChildViewControllers)
    {
        if ([oneController isKindOfClass:[SongsListViewController class]])
        {
            [(SongsListViewController*)oneController scrollListToCurrentSong];
            break;
        }
    }
}
     
@end
