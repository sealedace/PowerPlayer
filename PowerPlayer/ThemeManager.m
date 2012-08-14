//
//  ThemeManager.m
//  PowerPlayer
//
//  Created by 许  on 12-7-6.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "ThemeManager.h"
#import "Utilities.h"

@implementation ThemeManager

+ (UIImage *)loadImageByKey:(NSString *)key
{
    NSString *sPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Theme.plist"];
    NSDictionary *dicImageList = [[NSDictionary alloc] initWithContentsOfFile:sPath];
    NSString *sImagePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[dicImageList objectForKey:key]];
    [dicImageList release];
    return [UIImage imageWithContentsOfFile:sImagePath];
}

@end
