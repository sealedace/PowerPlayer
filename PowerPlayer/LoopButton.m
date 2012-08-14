//
//  LoopButton.m
//  PowerPlayer
//
//  Created by sealedace on 12-8-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "LoopButton.h"
#import "ThemeManager.h"
#import <QuartzCore/QuartzCore.h>

#define RotateAnimation @"RotateAnimation"
#define ImageViewOneTag 1010
#define RotateAnimationDuration 3

@interface LoopButton ()
//- (void)setImage:(UIImage *)image;
- (void)buttonPressed;
- (void)startRotate;
- (void)stopRotate;
@end

@implementation LoopButton
@synthesize loopMode=m_loopMode;
@synthesize delegate=m_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        m_loopMode = LoopMode_All;
        m_delegate = nil;
        
        UIImage *image = [ThemeManager loadImageByKey:@"LoopAll"];
        CGSize sizeImage = CGSizeMake(image.size.width/2, image.size.height/2);
        CGRect rectImageView = CGRectMake(0, 0, sizeImage.width, sizeImage.height);
        m_imageView = [[UIImageView alloc] initWithFrame:rectImageView];
        [m_imageView setImage:image];
        [self addSubview:m_imageView];
        
        CGRect rectNew = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), sizeImage.width, sizeImage.height);
        [self setFrame:rectNew];
        
        [self addTarget:self
                 action:@selector(buttonPressed)
       forControlEvents:UIControlEventTouchUpInside];
        
        [self startRotate];
    }
    return self;
}
//
//- (void)setImage:(UIImage *)image
//{
//    [m_imageView setImage:image];
//}

- (void)buttonPressed
{
    switch (m_loopMode)
    {
        case LoopMode_None:
        {
            m_loopMode = LoopMode_All;
            [self startRotate];
            break;
        }
        case LoopMode_All:
        {
            m_loopMode = LoopMode_Single;
            UIImage *imageOne = [ThemeManager loadImageByKey:@"LoopSingle"];
            CGRect rect = CGRectMake(0, 0, imageOne.size.width/2, imageOne.size.height/4);
            UIImageView *imageViewOne = [[UIImageView alloc] initWithFrame:rect];
            [imageViewOne setImage:imageOne];
            [imageViewOne setCenter:m_imageView.center];
            [imageViewOne setTag:ImageViewOneTag];
            [self addSubview:imageViewOne];
            [imageViewOne release];
            break;
        }
        case LoopMode_Single:
        {
            m_loopMode = LoopMode_None;
            UIImageView *imageViewOne = (UIImageView*)[self viewWithTag:ImageViewOneTag];
            if (nil != imageViewOne)
            {
                [imageViewOne removeFromSuperview];
            }
            [self stopRotate];
            break;
        }
        default:
            break;
    }
    
    if (nil != m_delegate
        && [m_delegate respondsToSelector:@selector(loopButtonPressed:)])
    {
        [m_delegate loopButtonPressed:self];
    }
}

- (void)dealloc
{
    [m_imageView release];
    m_delegate = nil;
    [super dealloc];
}

- (void)startRotate
{
    [self stopRotate];

    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anime setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [anime setDuration:RotateAnimationDuration];
    [anime setFromValue:[NSNumber numberWithDouble:0.]];
    [anime setToValue:[NSNumber numberWithDouble:2*M_PI]];
    [anime setRepeatCount:HUGE_VALF];
    [m_imageView.layer addAnimation:anime forKey:RotateAnimation];
}

- (void)stopRotate
{
    CABasicAnimation *anime = (CABasicAnimation*)[m_imageView.layer animationForKey:RotateAnimation];
    if (nil != anime)
    {
        [m_imageView.layer removeAnimationForKey:RotateAnimation];
    }
}

@end
