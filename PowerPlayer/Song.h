//
//  Song.h
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject
{
    NSString *file;
    NSInteger track;
    NSString *catalog;
    NSString *performer;
    NSString *title;
    
    uint32_t beginMinute;
    uint32_t beginSecond;
    uint32_t beginFrame;
    
    uint32_t endMinute;
    uint32_t endSecond;
    uint32_t endFrame;
}


@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) NSInteger track;
@property (nonatomic, retain) NSString *catalog;
@property (nonatomic, retain) NSString *performer;
@property (nonatomic, retain) NSString *title;

@property (nonatomic, assign) uint32_t beginMinute;
@property (nonatomic, assign) uint32_t beginSecond;
@property (nonatomic, assign) uint32_t beginFrame;

@property (nonatomic, assign) uint32_t endMinute;
@property (nonatomic, assign) uint32_t endSecond;
@property (nonatomic, assign) uint32_t endFrame;

@property (nonatomic, assign) NSUInteger pIndex;// index for playing
@property (nonatomic, assign) NSUInteger dIndex;// index for display

@end
