//
//  DynamicLabel.m
//  DynamicLabel
//
//  Created by xugaoqiang on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DynamicLabel.h"

#define DefaultFontSize 16
#define RollingDelay 15

@interface DynamicLabel()
- (void)update;
- (void)updateLabelFrame;

@end

@implementation DynamicLabel
@synthesize label=m_label;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
        m_runLoop = NULL;
        m_label = [[UILabel alloc] initWithFrame:CGRectZero];
        [m_label setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:m_label];
        
        m_directionRight = YES;
        m_velocity = 0.5;
        m_label.font = [UIFont systemFontOfSize:DefaultFontSize];
        m_label.text = @"";
        m_label.textColor = [UIColor blackColor];

        m_label.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
        m_runLoop = NULL;
        m_currentRect = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        m_label = [[UILabel alloc] initWithFrame:m_currentRect];
        [m_label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:m_label];
        m_gradientLayer = nil;
        
        m_directionRight = YES;
        m_velocity = 0.5;
        m_label.font = [UIFont systemFontOfSize:DefaultFontSize];
        m_label.text = @"";
        m_label.textColor = [UIColor blackColor];
        m_label.textAlignment = NSTextAlignmentLeft;
        
    }
    return self;
}

- (void)dealloc
{
    [self stopUpdate];
    [m_label release];
    [m_gradientLayer release];
    [super dealloc];
}

- (void)setText:(NSString *)text
{
    [self stopUpdate];
    CGSize sizeText = [text sizeWithFont:m_label.font];
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth([self frame]), CGRectGetHeight([self frame]));
    if (sizeText.width >= (CGRectGetWidth([self frame])-5))
    {
        if (nil != m_gradientLayer)
        {
            if ([m_gradientLayer superlayer])
            {
                [m_gradientLayer removeFromSuperlayer];
            }
            [m_gradientLayer release];
            m_gradientLayer = nil;
        }
        CGRect theBounds = [self bounds];
        CGSize sizeText = [m_label.text sizeWithFont:m_label.font];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.startPoint = CGPointMake(0.0, 0.5);
        gradient.endPoint = CGPointMake(1.0, 0.5);
        
        gradient.frame = CGRectMake(0, (CGRectGetHeight(theBounds)-sizeText.height)/2, CGRectGetWidth(theBounds), sizeText.height);
        
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.5].CGColor,
                           
                           (id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor,
                           (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, nil];
        [self.layer addSublayer:gradient];
        rect = CGRectMake(CGRectGetMinX(m_currentRect),
                          CGRectGetMinY(m_currentRect),
                          sizeText.width,
                          CGRectGetHeight(m_currentRect));
        [self performSelectorInBackground:@selector(startUpdate)
                               withObject:nil];
    }
    
    [m_label setText:text];
    [m_label setFrame:rect];
}

#pragma mark -
#pragma mark private method
- (void)update
{
    CGRect rect = [self frame];
    CGSize sizeText = m_label.frame.size;
    CGFloat diff = rect.size.width - sizeText.width;
    CGFloat fabDiff = fabsf(diff);

    if (fabDiff < 20)
    {
        m_velocity = 0.5;
    }
    else if (fabDiff >= 20 && fabDiff < 50)
    {
        m_velocity = 0.8;
    }
    else if (fabDiff >= 50)
    {
        m_velocity = 1;
    }
    
    if (diff < 0)
    {
        m_currentRect = CGRectMake(CGRectGetMinX(m_currentRect),
                                   CGRectGetMinY(m_currentRect),
                                   sizeText.width,
                                   sizeText.height);
        if (YES == m_directionRight)
        {
            if (CGRectGetMinX(m_currentRect) < RollingDelay)
            {
                m_currentRect = CGRectMake(CGRectGetMinX(m_currentRect)+m_velocity,
                                           CGRectGetMinY(m_currentRect),
                                           CGRectGetWidth(m_currentRect),
                                           CGRectGetHeight(m_currentRect));
            }
            else
            {
                m_directionRight = NO;
            }
        }
        else
        {
            if (CGRectGetMaxX(m_currentRect) > (CGRectGetWidth(rect)-RollingDelay))
            {
                m_currentRect = CGRectMake(CGRectGetMinX(m_currentRect)-m_velocity,
                                           CGRectGetMinY(m_currentRect),
                                           CGRectGetWidth(m_currentRect),
                                           CGRectGetHeight(m_currentRect));
            }
            else
            {
                m_directionRight = YES;
            }
        }
    }
    else
    {
        m_currentRect = CGRectMake(0, 0, CGRectGetWidth([self frame]), CGRectGetHeight([self frame]));
//        if (m_label.textAlignment == NSTextAlignmentLeft)
//        {
//            m_currentRect = CGRectMake(0, 0, CGRectGetWidth([self frame]), CGRectGetHeight([self frame]));
//        }
//        else if (m_label.textAlignment == NSTextAlignmentCenter)
//        {
//            m_currentRect = CGRectMake((CGRectGetWidth(rect)-sizeText.width)/2, 0, sizeText.width, CGRectGetHeight([self frame]));
//        }
//        else if (m_label.textAlignment == NSTextAlignmentRight)
//        {
//            m_currentRect = CGRectMake(CGRectGetWidth(rect)-sizeText.width, 0, sizeText.width, CGRectGetHeight([self frame]));
//        }                                                                                                                                                                                                                                                                                                                                                                                    
    }
    
    [self performSelectorOnMainThread:@selector(updateLabelFrame)
                           withObject:nil
                        waitUntilDone:YES];
}

- (void)updateLabelFrame
{
    [m_label setFrame:m_currentRect];
}

- (void)startUpdate
{
    @autoreleasepool
    {
        m_runLoop = CFRunLoopGetCurrent();
        [NSTimer scheduledTimerWithTimeInterval:(1.0/30)
                                         target:self
                                       selector:@selector(update) 
                                       userInfo:nil
                                        repeats:YES];
        CFRunLoopRun();
    }
}

- (void)stopUpdate
{
    m_currentRect = CGRectMake(0, 0, CGRectGetWidth([self frame]), CGRectGetHeight([self frame]));
    m_directionRight = YES;
    if (NULL != m_runLoop)
    {
        CFRunLoopStop(m_runLoop);
        m_runLoop = NULL;
    }
}



@end
