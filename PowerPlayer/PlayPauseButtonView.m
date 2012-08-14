//
//  PlayPauseButtonView.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-12.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "PlayPauseButtonView.h"

@implementation PlayPauseButtonView
@synthesize isPlayShape=m_bIsPlayShape;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        m_bIsPlayShape = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [[UIColor colorWithWhite:0.8 alpha:1] set];
    CGFloat thickness = 2.;
    CGRect rectNew = CGRectMake(thickness, thickness, CGRectGetWidth(rect)-2*thickness, CGRectGetHeight(rect)-2*thickness);
    // Draw circle
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, thickness);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:1].CGColor);
    CGContextAddEllipseInRect(context, rectNew);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGFloat scale = 10.;
    CGRect rect1 = CGRectMake(scale, scale, CGRectGetWidth(rect)-2*scale, CGRectGetHeight(rect)-2*scale);
    CGFloat width = rect1.size.width;
    if (m_bIsPlayShape)
    {
        CGPoint upPoint = CGPointMake(width/4, (2-sqrt(3))/4*width);
        CGPoint downPoint = CGPointMake(upPoint.x, width-upPoint.y);
        CGPoint rightPoint = CGPointMake(width, width/2);
        upPoint.x += scale;
        upPoint.y += scale;
        downPoint.x += scale;
        downPoint.y += scale;
        rightPoint.x += scale;
        rightPoint.y += scale;

        CGContextBeginPath(context);
        CGContextMoveToPoint(context, upPoint.x, upPoint.y);
        CGContextAddLineToPoint(context, rightPoint.x, rightPoint.y);
        CGContextAddLineToPoint(context, downPoint.x, downPoint.y);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    else
    {
        CGFloat verticalLineWidth = 4;
        CGRect rectVerticalLine1 = CGRectMake(width/2-2*verticalLineWidth+scale-2,
                                              scale+2,
                                              verticalLineWidth,
                                              CGRectGetHeight(rect1)-6);

        CGRect rectVerticalLine2 = CGRectMake(CGRectGetMaxX(rectVerticalLine1)+verticalLineWidth+scale,
                                              CGRectGetMinY(rectVerticalLine1),
                                              verticalLineWidth,
                                              CGRectGetHeight(rectVerticalLine1));
        
        CGContextFillRect(context, rectVerticalLine1);
        CGContextFillRect(context, rectVerticalLine2);
    }
}

- (void)setIsPlayShape:(BOOL)isPlayShape
{
    m_bIsPlayShape = isPlayShape;
    [self setNeedsDisplay];
}

@end
