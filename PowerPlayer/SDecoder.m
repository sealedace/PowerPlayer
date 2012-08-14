//
//  SDecoder.m
//  PowerPlayer
//
//  Created by 许  on 12-6-22.
//  Copyright (c) 2012年 Sealed Ace. All rights reserved.
//

#import "SDecoder.h"
#import <AVFoundation/AVFoundation.h>
#import "Song.h"
#import "libavformat/avformat.h"
#import "FileManager.h"
#import "PublicDefinitions.h"

static void writeWavHeader(AVCodecContext *pCodecCtx,AVFormatContext *pFormatCtx,FILE *audioFile)
{
    int8_t *data;
    int32_t long_temp;
    int16_t short_temp;
    int16_t BlockAlign;
    int bits = 16;
    int32_t fileSize;
    int32_t audioDataSize;
    
    switch(pCodecCtx->sample_fmt)
    {
        case AV_SAMPLE_FMT_S16:
            bits=16;
            break;
        case AV_SAMPLE_FMT_S32:
            bits=32;
            break;
        case AV_SAMPLE_FMT_U8:
            bits=8;
            break;
        default:
            bits=16;
            break;
    }
    
    audioDataSize=(pFormatCtx->duration)*(bits/8)*(pCodecCtx->sample_rate)*(pCodecCtx->channels);
    fileSize = audioDataSize+36;
    data = (int8_t*)"RIFF";
    fwrite(data,sizeof(char),4,audioFile);
    fwrite(&fileSize,sizeof(int32_t),1,audioFile);
    //"WAVE"
    data = (int8_t*)"WAVE";
    fwrite(data,sizeof(char),4,audioFile);
    data = (int8_t*)"fmt ";
    fwrite(data,sizeof(char),4,audioFile);
    long_temp = 16;
    fwrite(&long_temp,sizeof(int32_t),1,audioFile);
    short_temp = 0x01;
    fwrite(&short_temp,sizeof(int16_t),1,audioFile);
    short_temp = (pCodecCtx->channels);
    fwrite(&short_temp,sizeof(int16_t),1,audioFile);
    long_temp = (pCodecCtx->sample_rate);
    fwrite(&long_temp,sizeof(int32_t),1,audioFile);
    long_temp = (bits/8)*(pCodecCtx->channels)*(pCodecCtx->sample_rate);
    fwrite(&long_temp,sizeof(int32_t),1,audioFile);
    BlockAlign = (bits/8)*(pCodecCtx->channels);
    fwrite(&BlockAlign,sizeof(int16_t),1,audioFile);
    short_temp = (bits);
    fwrite(&short_temp,sizeof(int16_t),1,audioFile);
    data = (int8_t*)"data";
    fwrite(data,sizeof(char),4,audioFile);
    fwrite(&audioDataSize,sizeof(int32_t),1,audioFile);
    
    fseek(audioFile,44,SEEK_SET);
}

@interface SDecoder()
- (id)initWithAudio:(Song *)song;
- (void)decode;
@end

@implementation SDecoder
@synthesize delegate;

- (id)initWithAudio:(Song *)song
{
    self = [super init];
    if (self)
    {
        m_audioObject = [song retain];
        delegate = nil;
        m_decoderResult = Decode_OK;
        m_lock = [[NSCondition alloc] init];
        m_bRunning = NO;
        m_totalTime = 0;
    }
    return self;
}

+ (id)decoderWithAudio:(Song *)song
{
    return [[[self alloc] initWithAudio:song] autorelease];
}

- (void)dealloc
{
    [m_lock release];
    [m_audioObject release];
    delegate = nil;
    [super dealloc];
}

- (void)start
{
    m_bRunning = YES;
    [self performSelectorInBackground:@selector(decode)
                           withObject:nil];
}

- (void)stop
{
    [m_lock lock];
    m_bRunning = NO;
    [m_lock unlock];
}

- (void)decode
{
    @autoreleasepool
    {
        AVCodec *pCodec = nil;
        AVFormatContext *pFormatCtx = nil;
        AVCodecContext *pCodecCtx = nil;
        int audioStream;
        
        const char *csPath = [m_audioObject.file cStringUsingEncoding:NSUTF8StringEncoding];
        
        // 1. Register all formats and codecs
        av_register_all();
        avcodec_register_all();
        
        // 2. Open audio file
        if(avformat_open_input(&pFormatCtx, csPath, NULL, NULL) != 0)
        {
            LOGS(@"Couldn't open file");
            m_decoderResult = Decode_OpenInputFileFailed;
            if (nil != delegate && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
            {
                [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                           withObject:self
                                        waitUntilDone:YES];
            }

            return;
        }
        
        // 3. Retrieve stream information
        if(avformat_find_stream_info(pFormatCtx, NULL) < 0)
        {
            LOGS(@"Couldn't find stream information");
            m_decoderResult = Decode_FindStreamInformationFailed;
            if (nil != delegate && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
            {
                [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                           withObject:self
                                        waitUntilDone:YES];
            }

            return;
        }
        
        // 4. Find the first audio stream
        audioStream = -1;
        for(int i=0; i<pFormatCtx->nb_streams; i++)
            if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO && audioStream < 0)
            {
                audioStream = i;
                break;
            }
        if(audioStream == -1)
        {
            LOGS(@"Didn't find a audio stream");
            m_decoderResult = Decode_NoAudioStreamFound;
            if (nil != delegate && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
            {
                [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                           withObject:self
                                        waitUntilDone:YES];
            }

            return;
        }
        
        // 5. Get a pointer to the codec context for the audio stream
        pCodecCtx = pFormatCtx->streams[audioStream]->codec;
        
        // 6. Find the decoder for the audio stream
        pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
        if(pCodec == NULL)
        {
            LOGS(@"Codec not found:%d", pCodecCtx->codec_id);
            m_decoderResult = Decode_NoCodecMatched;
            if (nil != delegate && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
            {
                [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                           withObject:self
                                        waitUntilDone:YES];
            }

            return;
        }
        
        LOGS(@"%@", [NSString stringWithUTF8String:pCodec->name]);
        
        // 7. Open codec
        if(avcodec_open2(pCodecCtx, pCodec, NULL)<0)
            if(pCodec == NULL)
            {
                LOGS(@"Could not open codec");
                m_decoderResult = Decode_OpenCodecFailed;
                if (nil != delegate && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
                {
                    [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                               withObject:self
                                            waitUntilDone:YES];
                }

                if (pCodecCtx) 
                {
                    avcodec_close(pCodecCtx);
                    av_free(pCodecCtx);
                }
                return;
            }
        
        // 8. prepare input file & output file
        FILE *infile, *outfile;
        
        infile = fopen(csPath, "rb");
        if (!infile)
        {
            LOGS(@"could not open input file.");
            m_decoderResult = Decode_OpenInputFileFailed;
            if (nil != delegate && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
            {
                [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                           withObject:self
                                        waitUntilDone:YES];
            }
            if (pCodecCtx) 
            {
                avcodec_close(pCodecCtx);
                av_free(pCodecCtx);
            }
            return;
        }
        
        NSString *sOutFile = [FileManager outputFile];
        [[NSFileManager defaultManager] removeItemAtPath:sOutFile error:NULL];
        outfile = fopen([sOutFile cStringUsingEncoding:NSUTF8StringEncoding], "wb");
        if (!outfile) 
        {
            LOGS(@"could not open output file");
            m_decoderResult = Decode_OpenOutputFileFailed;
            if (nil != delegate && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
            {
                [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                           withObject:self
                                        waitUntilDone:YES];
            }

            if (pCodecCtx) 
            {
                avcodec_close(pCodecCtx);
                av_free(pCodecCtx);
            }
            return;
        }
        
        AVPacket packet;
        uint8_t *pktData = NULL;
        int pktSize;
        int outSize = AVCODEC_MAX_AUDIO_FRAME_SIZE;
        uint8_t *inbuf = (uint8_t *)av_malloc(outSize);
        
        int32_t audioFileSize = 0;
        
        // 9. Add the file header of the output file
        writeWavHeader(pCodecCtx,pFormatCtx,outfile);

        // 10. Start decode
        /*
         How to calculate total frames:
           totalFrames=pInputVstream->duration*pInputVstream->time_base.num/pInputVstream->time_base.den*pInputVstream->r_frame_rate.num/pInputVstream->r_frame_rate.den;
         */
        AVStream *inputStream = pFormatCtx->streams[audioStream];
        m_totalTime = inputStream->duration * inputStream->time_base.num / inputStream->time_base.den;
        
        int64_t beginPTS = 0;
        int64_t endPTS = 0;
        
        int64_t beginSeconds = 60*m_audioObject.beginMinute+m_audioObject.beginSecond;
         if (beginSeconds > 0)
        {
            int64_t endSeconds = 60*m_audioObject.endMinute+m_audioObject.endSecond;
            m_totalTime = endSeconds - beginSeconds;
            
            beginPTS = beginSeconds * inputStream->time_base.den / inputStream->time_base.num;
            endPTS = endSeconds * inputStream->time_base.den / inputStream->time_base.num;
            av_seek_frame(pFormatCtx, audioStream, beginPTS, AVSEEK_FLAG_FRAME);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_WillBeginDecoding
                                                            object:nil];
        
        if (nil != delegate && [delegate respondsToSelector:@selector(decoderWillBeginDecode:)])
        {
            [delegate performSelectorOnMainThread:@selector(decoderWillBeginDecode:)
                                       withObject:self
                                    waitUntilDone:YES];
        }
        
        while (av_read_frame(pFormatCtx, &packet)>=0)
        {
            if (NO == m_bRunning)
            {
                m_decoderResult = Decode_TerminateManually;
                av_free_packet(&packet);
                break;
            }
            
            if (endPTS > 0 && packet.pts > endPTS)
            {
                av_free_packet(&packet);
                break;
            }
            
            int len = 0;
            
            pktData = packet.data;
            pktSize = packet.size;
            
            while (pktSize>0)
            {
                if (NO == m_bRunning)
                {
                    m_decoderResult = Decode_TerminateManually;
                    break;
                }
                outSize = AVCODEC_MAX_AUDIO_FRAME_SIZE;
                len = avcodec_decode_audio3(pCodecCtx, (short *)inbuf, &outSize, &packet);
                if (len < 0)
                {
                    m_decoderResult = Decode_DecodeError;
                    break;
                }
                if (outSize>0)
                {
                    audioFileSize += outSize;
                    fwrite(inbuf, 1, outSize, outfile);
                    fflush(outfile);
                }
                
                pktSize -= len;
                pktData += len;
            }
            av_free_packet(&packet);
        }

        // 11. write audio information
        fseek(outfile, 40, SEEK_SET);
        fwrite(&audioFileSize, 1, sizeof(int32_t), outfile);
        audioFileSize += 36;
        fseek(outfile, 4, SEEK_SET);
        fwrite(&audioFileSize, 1, sizeof(int32_t), outfile);
        
        // 12. cleaning
        av_free(inbuf);
        fclose(infile);
        fclose(outfile);
        // Close the codec
        if (pCodecCtx) 
        {
            avcodec_close(pCodecCtx);
            av_free(pCodecCtx);
        }
        
        if (m_decoderResult != Decode_OK)
        {
            if (m_decoderResult != Decode_TerminateManually
                && nil != delegate
                && [delegate respondsToSelector:@selector(decoderEncounteredError:)])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_DecoderEncounteredError
                                                                    object:nil];
                [delegate performSelectorOnMainThread:@selector(decoderEncounteredError:)
                                           withObject:self
                                        waitUntilDone:YES];
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PPNotification_FinishDecodingASong
                                                                object:nil];
            if (nil != delegate
                && [delegate respondsToSelector:@selector(decoderDidFinishDecoding:)])
            {
                [delegate performSelectorOnMainThread:@selector(decoderDidFinishDecoding:)
                                           withObject:self
                                        waitUntilDone:YES];
            }
        }
        [self stop];
    }
}

- (int64_t)totalTime
{
    return m_totalTime;
}

- (TDecodeError)decodeResult
{
    return m_decoderResult;
}

@end
