//
//  DecoderCommon.h
//  PowerPlayer
//
//  Created by 许  on 12-6-23.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

typedef enum decodeErrorType
{
    Decode_OK,
    Decode_OpenInputFileFailed,
    Decode_OpenOutputFileFailed,
    Decode_FindStreamInformationFailed,
    Decode_NoAudioStreamFound,
    Decode_NoCodecMatched,
    Decode_OpenCodecFailed,
    Decode_DecodeError,
    Decode_TerminateManually
}TDecodeError;
