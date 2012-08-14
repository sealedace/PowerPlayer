//
//  DynamicLabel.h
//  DynamicLabel
//
//  Created by xugaoqiang on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DynamicLabel : UIView
{
    UILabel *m_label;
    CAGradientLayer *m_gradientLayer;
    
    BOOL m_directionRight;
    CGFloat m_velocity;
    CGRect m_currentRect;
    
    CFRunLoopRef m_runLoop;
}

@property (strong) UILabel *label;
- (void)setText:(NSString *)text;
- (void)startUpdate;
- (void)stopUpdate;

@end
