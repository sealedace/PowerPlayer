//
//  FileManager.m
//  PowerPlayer
//
//  Created by 许  on 12-6-23.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "FileManager.h"
#import "CueParser.h"
#import "Song.h"
#import "libavformat/avformat.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#import <AVFoundation/AVFoundation.h>

static FileManager *instance = nil;

@interface FileManager()
- (void)parseFiles;
@end

@implementation FileManager

+ (FileManager *)sharedInstance
{
    if (nil == instance)
    {
        instance = [[FileManager alloc] init];
    }
    return instance;
}

+ (NSString *)documentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)decodeSpaceDirectory
{
    return [[self documentDirectory] stringByAppendingPathComponent:@"Decode_Space"];
}

+ (void)prepareBasicDirectories
{
    // Decode space
    [[NSFileManager defaultManager] createDirectoryAtPath:[self decodeSpaceDirectory]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

+ (NSString *)outputFile
{    
    return [[FileManager decodeSpaceDirectory] stringByAppendingPathComponent:@"out.wav"];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        m_arrFiles = [[NSMutableArray alloc] initWithCapacity:0];
        m_arrSongs = [[NSMutableArray alloc] initWithCapacity:0];
        [self synchronize];
    }
    return self;
}

- (void)dealloc
{
    [m_arrFiles release];
    [m_arrSongs release];
    [super dealloc];
}

- (void)synchronize
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *sDocumentPath = [FileManager documentDirectory];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:sDocumentPath];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (NSString *sPath in dirEnumerator)
    {
        if ([dirEnumerator level] > 1)
        {
            continue;
        }
        BOOL bIsDir;
        NSString *sFullPath = [NSString stringWithFormat:@"%@/%@", sDocumentPath, sPath];
        if (NO == [fileManager fileExistsAtPath:sFullPath isDirectory:&bIsDir] || YES == bIsDir)
        {
            continue;
        }
        
        if (NO == [sFullPath hasSuffix:@"ape"]
            && NO == [sFullPath hasSuffix:@"flac"]
            && NO == [sFullPath hasSuffix:@"wav"]
            && NO == [sFullPath hasSuffix:@"mp3"]
            && NO == [sFullPath hasSuffix:@"cue"])
        {
            continue;
        }
        
        [m_arrFiles addObject:sFullPath];
    }
    [fileManager release];
    [pool release];

    // parse cue files if exist
    if ([m_arrFiles count] > 0)
    {
        [self parseFiles];
    }
}

- (NSArray *)filesObjects
{
    return m_arrFiles;
}

- (NSArray *)allSongs
{
    return m_arrSongs;
}

- (BOOL)validateEncode:(NSString*)aStr
{   
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "] invertedSet];
    
    BOOL isValid = (NSNotFound == [aStr rangeOfCharacterFromSet:chars].location);
    return isValid;
}

- (NSString *)correctString:(NSString *)aString
{
    if (aString)
    {
        const char *ptr = [aString cStringUsingEncoding:NSISOLatin1StringEncoding];       
        
        if (ptr == 0) //Mac Chinese
        {
            return aString;
        }
        else
        {
            BOOL isValid = [self validateEncode:aString];
            if (isValid) //English
            {
                return aString;
            }    
            else //Windows Chinese
            {
                NSData *dateStr = [aString dataUsingEncoding: NSISOLatin1StringEncoding];
                // CAUTION:
                // Here convert string into a specified encoding.
                // I don't knonw why. But kCFStringEncodingBig5 does work here...
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
                return [[[NSString alloc] initWithData:dateStr encoding:enc] autorelease];
            }
        }
    }    
    
    return nil;
}

- (void)parseFiles
{
    [m_arrSongs removeAllObjects];

    // Add all files as songs;
    for (NSString *oneFile in m_arrFiles)
    {
        if (NO == [oneFile hasSuffix:@"cue"])
        {
            Song *newSong = [[Song alloc] init];
            newSong.file = oneFile;
            NSString *sFileName = [oneFile lastPathComponent];
            NSString *suffix = [[sFileName componentsSeparatedByString:@"."] lastObject];
            NSRange suffixRange = [sFileName rangeOfString:suffix];
            newSong.title = [sFileName substringToIndex:suffixRange.location-1];
            
            // Get id3 tag info
            if ([oneFile hasSuffix:@"mp3"])
            {
                AudioFileID fileID = nil;
                OSStatus err = noErr;
                err = AudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath:oneFile],
                                       kAudioFileReadPermission, 0, &fileID);
                if (err == noErr)
                {
                    NSDictionary *dic = nil;
                    UInt32 piDataSize = sizeof(dic);
                    err = AudioFileGetProperty(fileID,
                                               kAudioFilePropertyInfoDictionary,
                                               &piDataSize,
                                               &dic);
                    if (err == noErr)
                    {
                        NSString *sArtist = [dic objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Artist]];
                        if (nil != sArtist && NO == [sArtist isEqualToString:@""])
                        {
                            newSong.performer = [self correctString:sArtist];
                        }
                        
                        NSString *sTitle = [dic objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Title]];
                        if (nil != sTitle && NO == [sTitle isEqualToString:@""])
                        {
                            newSong.title = [self correctString:sTitle];
                        }
                        
                        NSString *sDuration = [dic objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_ApproximateDurationInSeconds]];
                        if (nil != sDuration && NO == [sDuration isEqualToString:@""])
                        {
                            uint8_t TotalSeconds = [sDuration intValue];
                            uint8_t minute = TotalSeconds / 60;
                            uint8_t second = TotalSeconds % 60;
                            newSong.beginMinute = 0;
                            newSong.beginSecond = 0;
                            newSong.endMinute = minute;
                            newSong.endSecond = second;
                        }
                        [dic release];
                    }
                }
                
                AudioFileClose(fileID);
            }
            else// Use ffmpeg to get id3 tag info
            {
                AVFormatContext *pFormatCtx = nil;
                const char *csPath = [oneFile cStringUsingEncoding:NSUTF8StringEncoding];
                av_register_all();
                // 2. Open audio file
                if(avformat_open_input(&pFormatCtx, csPath, NULL, NULL) == 0)
                {
                    AVDictionary *dicMeta = pFormatCtx->metadata;
                    
                    AVDictionaryEntry *entry = NULL;
                    while (NULL != (entry = av_dict_get(dicMeta, "", entry, AV_DICT_IGNORE_SUFFIX)))
                    {
                        NSString *sKey = [NSString stringWithCString:entry->key
                                                            encoding:NSUTF8StringEncoding];
                        // Artist
                        if ([[sKey lowercaseString] isEqualToString:@"artist"])
                        {
                            NSString *sArtist = [NSString stringWithCString:entry->value encoding:NSUTF8StringEncoding];
                            if (nil != sArtist && NO == [sArtist isEqualToString:@""])
                            {
                                newSong.performer = sArtist;
                            }
                        }
                        // Title
                        else if ([[sKey lowercaseString] isEqualToString:@"title"])
                        {
                            entry = av_dict_get(dicMeta, "title", NULL, AV_DICT_IGNORE_SUFFIX);
                            NSString *sTitle = [NSString stringWithCString:entry->value encoding:NSUTF8StringEncoding];
                            if (nil != sTitle && NO == [sTitle isEqualToString:@""])
                            {
                                newSong.title = sTitle;
                            }
                        }
                    }
                    
                    avformat_close_input(&pFormatCtx);
                }
            }
            [m_arrSongs addObject:newSong];
            [newSong release];
        }
    }
    
    // parse cue files and remove corresponding music file
    for (NSString *oneFile in m_arrFiles)
    {
        if (YES == [oneFile hasSuffix:@"cue"])
        {
            NSArray *arraySongs = [CueParser parse:oneFile];
            if (nil != arraySongs 
                && 0 < [arraySongs count])
            {
                // Remove the entire file
                Song *song = [arraySongs lastObject];
                NSString *sFileToRemoveFromSongs = song.file;
                for (NSUInteger i=0; i<[m_arrSongs count]; i++)
                {
                    Song *oneSong = [m_arrSongs objectAtIndex:i];
                    if ([oneSong.file isEqualToString:sFileToRemoveFromSongs])
                    {
                        [m_arrSongs removeObjectAtIndex:i];
                        break;
                    }
                }
                
                [m_arrSongs addObjectsFromArray:arraySongs];
            }
            continue;
        }
    }
    
    // number the songs
    for (NSUInteger i=0; i<[m_arrSongs count]; i++)
    {
        Song *oneSong = [m_arrSongs objectAtIndex:i];
        oneSong.pIndex = oneSong.dIndex = i;
    }
}

@end
