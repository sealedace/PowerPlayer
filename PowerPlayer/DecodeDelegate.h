//
//  DecodeDelegate.h
//  PowerPlayer
//
//  Created by 许  on 12-6-23.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecoderCommon.h"

@class SDecoder;
@protocol DecodeDelegate <NSObject>
@optional
- (void)decoderWillBeginDecode:(SDecoder *)decoder;
- (void)decoderDidFinishDecoding:(SDecoder *)decoder;
- (void)decoderEncounteredError:(SDecoder *)decoder;
@end
