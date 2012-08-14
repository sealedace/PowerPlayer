//
//  CueParser.m
//  PowerPlayer
//
//  Created by xugaoqiang on 12-7-2.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "CueParser.h"
#import "Song.h"
#import "PublicDefinitions.h"
#import "RegexKitLite.h"

@implementation CueParser
+ (NSArray *)parse:(NSString *)filePath
{
    // Read entire file
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *sText = nil;
    if (nil != fileData)
    {
        sText = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        if (nil == sText)
        {
            sText = [[NSString alloc] initWithData:fileData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        }
    }

    if (nil == sText)
    {
        return nil;
    }
    
    // Separate by new line
    NSArray *arrLines = [sText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    // read each line
    NSString *sFileName = nil;
    NSString *sCatalog = nil;
    NSString *sPerformer = nil;

    BOOL bTrackPartBegin = NO;
    NSMutableArray *arrSongs = [NSMutableArray arrayWithCapacity:0];
    Song *newSong = nil;
    
    for (NSString *sLine in arrLines)
    {
        if (NO == bTrackPartBegin)
        {
            // Catalog
            if (nil == sCatalog)
            {
                sCatalog = [CueParser parseCatalog:sLine];
                if (nil != sCatalog)
                {
                    continue;
                }
            }
            // File
            if (nil == sFileName)
            {
                sFileName = [CueParser parseFileName:sLine];
                if (nil != sFileName)
                {
                    NSRange pathRange = [filePath rangeOfString:[filePath lastPathComponent]];
                    NSString *songPath = [filePath substringToIndex:pathRange.location-1];
                    sFileName = [songPath stringByAppendingPathComponent:sFileName];
                    continue;
                }
            }
            // Performer
            if (nil == sPerformer)
            {
                sPerformer = [CueParser parsePerformer:sLine];
                if (nil != sPerformer)
                {
                    continue;
                }
            }
        }

        // Track
        NSString *sTrack = [CueParser parseTrack:sLine];
        if (nil != sTrack)
        {
            bTrackPartBegin = YES;
            if (nil != newSong)
            {
                [arrSongs addObject:newSong];
                [newSong release];
                newSong = nil;
            }
            
            newSong = [[Song alloc] init];
            newSong.catalog = sCatalog;
            newSong.file = sFileName;
            newSong.performer = sPerformer;
            newSong.track = [sTrack integerValue];
            continue;
        }

        if (bTrackPartBegin == YES)
        {
            // Performer
            NSString *sPerformerInside = [CueParser parsePerformer:sLine];
            if (nil != sPerformerInside)
            {
                newSong.performer = sPerformer;
                continue;
            }
            
            // Title
            if (nil == newSong.title)
            {
                NSString *sTitle = [CueParser parseTitle:sLine];
                if (nil != sTitle)
                {
                    newSong.title = sTitle;
                    continue;
                }
            }
            
            // Index
            if (0 == newSong.beginFrame)
            {
                NSString *sIndex = [CueParser parseIndex:sLine];
                if (nil != sIndex)
                {
                    newSong.beginMinute = [CueParser parseBeginMinute:sIndex];
                    newSong.beginSecond = [CueParser parseBeginSecond:sIndex];
                    newSong.beginFrame = [CueParser parseBeginFrame:sIndex];
                    if ([arrSongs count]>0)
                    {
                        Song *lastSong = [arrSongs lastObject];
                        lastSong.endMinute = newSong.beginMinute;
                        lastSong.endSecond = newSong.beginSecond;
                        lastSong.endFrame = newSong.beginFrame;
                    }
                    continue;
                }
            }
        }
    }
    
    if (nil != newSong)
    {
        [arrSongs addObject:newSong];
        [newSong release];
        newSong = nil;
    }
    
    SAFE_RELEASE(sText);
    
     return arrSongs;
}

+ (NSString *)parseFileName:(NSString *)string
{
    NSString *sRegex = [NSString stringWithFormat:@"FILE\\s+\"(.*?)\"\\s+WAVE"];
    return [string stringByMatching:sRegex capture:1];
}

+ (NSString *)parseTrack:(NSString *)string
{
    NSString *sRegex = [NSString stringWithFormat:@"TRACK\\s+([0-9]?[0-9])\\s+AUDIO"];
    return [string stringByMatching:sRegex capture:1];
}

+ (NSString *)parseCatalog:(NSString *)string
{
    NSString *sRegex = [NSString stringWithFormat:@"CATALOG\\s+([0-9]*)"];
    return [string stringByMatching:sRegex capture:1];
}

+ (NSString *)parsePerformer:(NSString *)string
{
    NSString *sRegex = [NSString stringWithFormat:@"PERFORMER\\s+\"(.*?)\""];
    return [string stringByMatching:sRegex capture:1];
}

+ (NSString *)parseTitle:(NSString *)string
{
    NSString *sRegex = [NSString stringWithFormat:@"TITLE\\s+\"(.*?)\""];
    return [string stringByMatching:sRegex capture:1];
}

+ (NSString *)parseIndex:(NSString *)string
{
    NSString *sRegex = [NSString stringWithFormat:@"INDEX\\s+[0-9]{2}\\s+([0-9]{2}:[0-9]{2}:[0-9]{2})"];
    return [string stringByMatching:sRegex capture:1];
}

+ (uint8_t)parseBeginMinute:(NSString *)string
{
    return (uint8_t)[[[string componentsSeparatedByString:@":"] objectAtIndex:0] intValue];
}

+ (uint8_t)parseBeginSecond:(NSString *)string
{
    return (uint8_t)[[[string componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
}

+ (uint8_t)parseBeginFrame:(NSString *)string
{
    return (uint8_t)[[[string componentsSeparatedByString:@":"] objectAtIndex:2] intValue];
}

@end
