//
//  FileManager.h
//  PowerPlayer
//
//  Created by 许  on 12-6-23.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject
{
    NSMutableArray *m_arrFiles;
    NSMutableArray *m_arrSongs;
}

+ (FileManager *)sharedInstance;

+ (NSString *)documentDirectory;
+ (NSString *)decodeSpaceDirectory;

+ (void)prepareBasicDirectories;
- (void)synchronize;

+ (NSString *)outputFile;

- (NSArray *)filesObjects;
- (NSArray *)allSongs;


@end
