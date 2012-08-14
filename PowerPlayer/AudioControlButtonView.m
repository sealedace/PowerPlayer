//
//  AudioControlButtonView.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-11.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "AudioControlButtonView.h"

@interface AudioControlButtonView()
- (void)pressed:(UITapGestureRecognizer *)sender;
@end

@implementation AudioControlButtonView
@synthesize target=m_target;

- (id)initWithFrame:(CGRect)frame
{
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    CGFloat line = (width<height?width:height);
    frame = CGRectMake(CGRectGetMinX(frame),
                       CGRectGetMinY(frame),
                       line,
                       line);
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        m_target = nil;
        [self setBackgroundColor:[UIColor clearColor]];
        m_gestureTapped = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(pressed:)];
        [self addGestureRecognizer:m_gestureTapped];
    }
    return self;
}

- (void)dealloc
{
    m_target = nil;
    [self removeGestureRecognizer:m_gestureTapped];
    [m_gestureTapped release];
    [super dealloc];
}

- (void)pressed:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)     
    {
        if (nil != m_target && [m_target respondsToSelector:@selector(buttonPressed:)])
        {
            [m_target buttonPressed:self];
        }
    }
}

@end
