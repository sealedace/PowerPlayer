//
//  PlayPreviousButtonView.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-12.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "PlayPreviousButtonView.h"

@implementation PlayPreviousButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
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
    CGFloat verticalLineWidth = 2;
    CGRect rect1 = CGRectMake(scale, scale, CGRectGetWidth(rect)-2*scale, CGRectGetHeight(rect)-2*scale);
    CGFloat width = rect1.size.width;
    
    CGPoint upPoint = CGPointMake(((sqrt(3)/2))*width+verticalLineWidth, 0);
    CGPoint downPoint = CGPointMake(upPoint.x, width);
    CGPoint leftPoint = CGPointMake(verticalLineWidth, width/2);
    upPoint.x += scale;
    upPoint.y += scale;
    downPoint.x += scale;
    downPoint.y += scale;
    leftPoint.x += scale;
    leftPoint.y += scale;
    
    CGRect rectVerticalLine = CGRectMake(scale, scale, verticalLineWidth, CGRectGetHeight(rect1));
    
    [[UIColor colorWithWhite:0.8 alpha:1] set];
    
    CGContextBeginPath(context);    
    CGContextMoveToPoint(context, upPoint.x, upPoint.y);
    CGContextAddLineToPoint(context, leftPoint.x, leftPoint.y);
    CGContextAddLineToPoint(context, downPoint.x, downPoint.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextFillRect(context, rectVerticalLine);
}


@end
