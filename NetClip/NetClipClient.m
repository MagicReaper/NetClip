//
//  NetClipClient.m
//  NetClip
//
//  Created by Thomas Patschinski on 12.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "NetClipClient.h"
#include "Structs.h"

@interface NetClipClient () <NSStreamDelegate>

@property (nonatomic, strong) NSString *server;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableData *inputBuffer;
@property (nonatomic, strong) NSMutableData *outputBuffer;
@property (nonatomic, assign) BOOL sendCommand;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@end

@implementation NetClipClient

-(id)initWithServer:(NSString*) server andPort:(NSUInteger) port {
    self = [super init];
    if (self) {
        self.server = server;
        self.port = port;
        self.sendCommand = NO;
        //self.sendFile = NO;
        self.done = NO;
        self.result = crPending;
        self.timeoutInSeconds = 5;
        NSLog(@"%s server=%@, port=%lu", __PRETTY_FUNCTION__, self.server, self.port);
    }
    return self;
}

-(void)requestResultForType:(ClipoardType)type {
    self.type = type;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.server, (UInt32)self.port, &readStream, &writeStream);
    
    self.inputStream = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;

    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];

    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeoutInSeconds target:self selector:@selector(timeoutWithTimer:) userInfo:nil repeats:NO];
}

-(void)timeoutWithTimer:(NSTimer*)timer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.inputBuffer == nil || self.outputBuffer == nil)
    {
        NSLog(@"TIMEOUT");
        self.result = crTimeout;
        self.done = YES;
    }

    self.timeoutTimer = nil;
}

-(void)close {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.inputStream  setDelegate:nil];
    [self.outputStream setDelegate:nil];
    [self.inputStream  close];
    [self.outputStream close];
    [self.inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream  = nil;
    self.outputStream = nil;
    self.inputBuffer  = nil;
    self.outputBuffer = nil;
}

-(void)sendCommand:(unsigned int) commandID {
    if (!self.outputBuffer)
        return;

    NCCOMMAND command;
    memset(&command, 0, sizeof(command));
    command.uiCommand = commandID;
    command.uiCommandVersion = 1;
    command.uiReserved1 = 0;
    command.uiReserved2 = 0;

    [self.outputBuffer appendBytes:&command length:sizeof(command)];
    
    NSInteger bytesWritten = [self.outputStream write:[self.outputBuffer bytes] maxLength:[self.outputBuffer length]];
    if (bytesWritten > 0) {
        [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) bytesWritten) withBytes:NULL length:0];
    }
    else {
        self.result = crError;
        self.done = YES;
    }
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
/*
    if (aStream == self.inputStream)
        NSLog(@"%s INPUT eventcode=%ld", __PRETTY_FUNCTION__, eventCode);
    else
        NSLog(@"%s OUTPUT eventcode=%ld", __PRETTY_FUNCTION__, eventCode);
*/
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            if (aStream == self.inputStream) {
                self.inputBuffer = [[NSMutableData alloc] init];
                NSLog(@"inputBuffer:%@", self.inputBuffer);
                
                if (self.inputBuffer != nil && self.outputBuffer != nil)
                {
                    [self.timeoutTimer invalidate];
                    NSLog(@"Invalidate Timer");
                }
            } else {
                self.outputBuffer = [[NSMutableData alloc] init];
                NSLog(@"outputBuffer:%@", self.outputBuffer);

                if (self.inputBuffer != nil && self.outputBuffer != nil)
                {
                    [self.timeoutTimer invalidate];
                    NSLog(@"Invalidate Timer");
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"spaceAvailable");
            if (self.sendCommand)
            {
                if ([self.outputBuffer length] > 0) {
                    NSInteger bytesWritten = [self.outputStream write:[self.outputBuffer bytes] maxLength:[self.outputBuffer length]];
                    if (bytesWritten > 0) {
                        [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) bytesWritten) withBytes:NULL length:0];
                    }
                    else {
                        self.done = YES;
                    }
                }
            }
            else {
                self.sendCommand = YES;
                [self sendCommand:self.type];
            }
            break;
            
        case NSStreamEventHasBytesAvailable: {
            //NSLog(@"Bytes Available. buffersize=%ld", [self.inputBuffer length]);

            uint8_t buffer[1024*50];
            NSInteger actuallyRead = [self.inputStream read:buffer maxLength:sizeof(buffer)];
            if (actuallyRead > 0) {
                [self.inputBuffer appendBytes:buffer length:(NSUInteger)actuallyRead];
                
                //NSLog(@"Nach Read. buffersize:%ld, readBytes:%ld", [self.inputBuffer length], actuallyRead);
                
                if ([self.inputBuffer length] >= sizeof(NCRESULT)) {
                    NCRESULT result;
                    
                    // Result Struktur kopieren
                    NSData *temp = [[NSData alloc] initWithBytes:[self.inputBuffer bytes] length:sizeof(result)];
                    result = *(NCRESULT*)[temp bytes];
                    
                    //NSLog(@"Inputbuffer>sizeof(result). uiDataLength=%d, gelesen=%ld", result.uiDataLength, [self.inputBuffer length] - sizeof(result));
                    
                    //NSLog(@"result.uiResult=%d, result.uiDataLength=%d", result.uiResult, result.uiDataLength);
                    
                    if (result.uiResult != RESULT_OK)
                    {
                        self.resultObject = nil;
                        self.result = result.uiResult;
                        self.done = YES;
                        return;
                    }
                    
                    self.dataLength = result.uiDataLength + sizeof(result);
                    self.bytesTransfered = [self.inputBuffer length];
                    
                    if ([self.inputBuffer length] - sizeof(result) >= result.uiDataLength)
                    {
                        // wir haben alles geladen

                        if (self.type == ctDIB)
                        {
                            NSData *temp2 = [[NSData alloc] initWithBytes:[self.inputBuffer bytes] + sizeof(result) length:result.uiDataLength];
                            
                            NSLog(@"Data Length = %ld", [temp2 length]);
                            
                            BITMAPFILEHEADER header;
                            
                            header.bfType = 0x4d42;
                            header.bfSize = sizeof(header) + (unsigned int)[temp2 length];
                            header.bfReserved1 = 0;
                            header.bfReserved2 = 0;
                            header.bfOffBits = sizeof(header) + 0x28;
                            
                            NSMutableData *fileData = [[NSMutableData alloc] initWithBytes:&header length:sizeof(header)];
                            
                            [fileData appendData:temp2];
                            
                            NSImage *image2 = [[NSImage alloc] initWithData:fileData];
                            if (image2)
                            {
                                
                                NSLog(@"%@", NSStringFromSize([image2 size]));
                                
                                self.resultObject = image2;
                                self.result = crOK;
                                self.done = YES;
                            }
                            else
                            {
                                self.done = YES;
                            }
                        }
                        else if (self.type == ctText)
                        {
                            NSData *temp2 = [[NSData alloc] initWithBytes:[self.inputBuffer bytes] + sizeof(result) length:result.uiDataLength];
                            NSString *resultString = [[NSString alloc] initWithData:temp2 encoding:NSISOLatin1StringEncoding];
                            self.resultObject = resultString;
                            self.result = crOK;
                            self.done = YES;
                        }
                    }
                }
            } else {
                // A non-positive value from -read:maxLength: indicates either end of file (0) or
                // an error (-1).  In either case we just wait for the corresponding stream event
                // to come through.
            }
        } break;
            
        case NSStreamEventEndEncountered:
        case NSStreamEventErrorOccurred: {
            NSError *theError = [aStream streamError];
            
            NSLog(@"ERROR: Error=%@, localizedDescription=%@", theError, [theError localizedDescription]);

            self.result = crError;
            self.done = YES;
        } break;

        default:
            break;
    }
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self close];
    self.server = nil;
}

@end
