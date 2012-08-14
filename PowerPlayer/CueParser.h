//
//  CueParser.h
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CueParser : NSObject

+ (NSArray *)parse:(NSString *)filePath;

+ (NSString *)parseFileName:(NSString *)string;
+ (NSString *)parseTrack:(NSString *)string;
+ (NSString *)parseCatalog:(NSString *)string;
+ (NSString *)parsePerformer:(NSString *)string;
+ (NSString *)parseTitle:(NSString *)string;
+ (NSString *)parseIndex:(NSString *)string;
+ (uint8_t)parseBeginMinute:(NSString *)string;
+ (uint8_t)parseBeginSecond:(NSString *)string;
+ (uint8_t)parseBeginFrame:(NSString *)string;
@end
