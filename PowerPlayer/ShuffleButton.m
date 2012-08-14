//
//  ShuffleButton.m
//  PowerPlayer
//
//  Created by sealedace on 12-8-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "ShuffleButton.h"
#import "ThemeManager.h"
#import <QuartzCore/QuartzCore.h>

#define FlipAnimation @"ShuffleFlipAnimation"
#define FlipAnimationDuration 1

@interface ShuffleButton ()
//- (void)setImage:(UIImage *)image;
- (void)pressed;
- (void)doShuffleAnimation;
- (void)stopShuffleAnimation;
@end

@implementation ShuffleButton
@synthesize isShuffle=m_bShuffle;
@synthesize delegate=m_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        m_bShuffle = YES;
        m_delegate = nil;
        
        UIImage *image = [ThemeManager loadImageByKey:@"Shuffle"];
        CGSize sizeImage = CGSizeMake(image.size.width/3, image.size.height/3);
        CGRect rectImageView = CGRectMake(0, 0, sizeImage.width, sizeImage.height);
        m_imageView = [[UIImageView alloc] initWithFrame:rectImageView];
        [m_imageView setImage:image];
        [self addSubview:m_imageView];
        
        CGRect rectFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), sizeImage.width, sizeImage.height);
        [self setFrame:rectFrame];
        
        [self addTarget:self
                 action:@selector(pressed)
       forControlEvents:UIControlEventTouchUpInside];
        
        [self doShuffleAnimation];
    }
    return self;
}

- (void)dealloc
{
    m_delegate = nil;
    [m_imageView release];
    [super dealloc];
}

//- (void)setImage:(UIImage *)image
//{
//    [m_imageView setImage:image];
//}

- (void)pressed
{
    m_bShuffle = !m_bShuffle;
    
    [self stopShuffleAnimation];
    if (YES == m_bShuffle)
    {
        [self doShuffleAnimation];
    }
    
    if (nil != m_delegate
        && [m_delegate respondsToSelector:@selector(shuffleButtonPressed:)])
    {
        [m_delegate shuffleButtonPressed:self];
    }
}

- (void)doShuffleAnimation
{
    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"transform"];
    [anime setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [anime setDuration:FlipAnimationDuration];
    [anime setAutoreverses:YES];
    [anime setFromValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [anime setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)]];
    [anime setCumulative:YES];
    [anime setRepeatCount:HUGE_VALF];
    [m_imageView.layer addAnimation:anime forKey:FlipAnimation];
}

- (void)stopShuffleAnimation
{
    CABasicAnimation *anime = (CABasicAnimation*)[m_imageView.layer animationForKey:FlipAnimation];
    if (nil != anime)
    {
        [m_imageView.layer removeAnimationForKey:FlipAnimation];
    }
}

@end
