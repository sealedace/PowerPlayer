//
//  Song.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "Song.h"

@implementation Song
@synthesize file=m_file;
@synthesize track=m_track;
@synthesize catalog=m_catalog;
@synthesize performer=m_performer;
@synthesize title=m_title;

@synthesize beginMinute=m_beginMinute;
@synthesize beginSecond=m_beginSecond;
@synthesize beginFrame=m_beginFrame;

@synthesize endMinute=m_endMinute;
@synthesize endSecond=m_endSecond;
@synthesize endFrame=m_endFrame;

@synthesize pIndex=_pIndex;
@synthesize dIndex=_dIndex;

- (id)init
{
    self = [super init];
    if (self)
    {
        m_track = 0;
        m_beginMinute = 0;
        m_beginSecond = 0;
        m_beginFrame = 0;
        
        m_endMinute = 0;
        m_endSecond = 0;
        m_endFrame = 0;
        
        _pIndex = _dIndex = 0;
    }
    return self;
}

- (void)dealloc
{
    [m_file release];
    [m_catalog release];
    [m_performer release];
    [m_title release];
    [super dealloc];
}

@end
