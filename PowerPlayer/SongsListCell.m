//
//  SongsListCell.m
//  PowerPlayer
//
//  Created by 许  on 12-6-26.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "SongsListCell.h"
#import <QuartzCore/CoreAnimation.h>
#import "PublicDefinitions.h"
#import "Player.h"
#import "DynamicLabel.h"
#import "PlayerManager.h"

#define IndentForLabel 30

@interface SongsListCell()
- (void)songWillStart;
- (void)songPlaysEnd;

@end

@implementation SongsListCell
@synthesize titleLabel=m_labelTitle;
@synthesize performerLabel=m_labelPerformer;
@synthesize isPlaying=m_bIsPlaying;
@synthesize ringEmitter=m_ringEmitter;
@synthesize song=m_song;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        // title label
        m_labelTitle = [[DynamicLabel alloc] initWithFrame:CGRectZero];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
        [m_labelTitle.label setTextAlignment:NSTextAlignmentCenter];
#else
        [m_labelTitle.label setTextAlignment:UITextAlignmentCenter];
#endif
        [m_labelTitle.label setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:m_labelTitle];
        
        // performer label
        m_labelPerformer = [[DynamicLabel alloc] initWithFrame:CGRectZero];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
        [m_labelPerformer.label setTextAlignment:NSTextAlignmentCenter];
#else
        [m_labelPerformer.label setTextAlignment:UITextAlignmentCenter];
#endif
        [m_labelPerformer.label setTextColor:[UIColor whiteColor]];
        [m_labelPerformer.label setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:m_labelPerformer];
        
        m_bIsPlaying = NO;
        m_song = nil;
        
        // Create the emitter layer
        self.ringEmitter = [CAEmitterLayer layer];
        m_ringEmitter.emitterSize	= CGSizeMake(0, 0);
        m_ringEmitter.emitterMode	= kCAEmitterLayerOutline;
        m_ringEmitter.emitterShape	= kCAEmitterLayerCircle;
        m_ringEmitter.renderMode		= kCAEmitterLayerBackToFront;
        
        CAEmitterCell* circle = [CAEmitterCell emitterCell];
        [circle setName:@"circle"];
        
        circle.birthRate	= 1;
        circle.velocity		= 0;
        circle.scale		= .8;
        circle.scaleSpeed	=-0.5;
        circle.lifetime		= 1.0;
        
        circle.color = [[UIColor colorWithRed:0.6
                                        green:.8
                                         blue:.2
                                        alpha:1] CGColor];
        circle.contents = (id) [[UIImage imageNamed:@"DazRing"] CGImage];
        
        m_ringEmitter.emitterCells = [NSArray arrayWithObject:circle];
        
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
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_labelTitle release];
    [m_ringEmitter release];
    [m_song release];
    [m_labelPerformer release];
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect fatherFrame = [self frame];
    m_ringEmitter.emitterPosition = CGPointMake(15, fatherFrame.size.height/2.0);
    
    CGRect frameTitle = CGRectMake(IndentForLabel, 
                                   0,
                                   CGRectGetWidth(fatherFrame)-2*IndentForLabel,
                                   30);
    [m_labelTitle setFrame:frameTitle];
    
    CGRect framePerformer = CGRectMake(IndentForLabel, CGRectGetMaxY(frameTitle), CGRectGetWidth(frameTitle), 15);
    [m_labelPerformer setFrame:framePerformer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
//    if (selected)
//    {
//        [self setBackgroundColor:[UIColor colorWithRed:0.6
//                                                 green:0.8
//                                                  blue:0.2
//                                                 alpha:1]];
//    }
//    else
//    {
//        [self setBackgroundColor:[UIColor clearColor]];
//    }
}

- (void)setPlaying:(BOOL)b
{
    m_bIsPlaying = b;
    if (YES == b)
    {
        if (![m_ringEmitter superlayer])
        {
            [self.layer insertSublayer:m_ringEmitter
                               atIndex:0];
        }
    }
    else
    {
        if ([m_ringEmitter superlayer])
        {
            [m_ringEmitter removeFromSuperlayer];
        }
    }
}

- (void)updatePlayStatus
{
    Song *aSong = [[[PlayerManager sharedInstance] currentPlayer] currentSong];
    
    [self setPlaying:(aSong == m_song?YES:NO)];
}

- (void)songWillStart
{
    [self updatePlayStatus];
}

- (void)songPlaysEnd
{
    [self setPlaying:NO];
}

@end
