//
//  NetClipFileTransferClient.m
//  NetClip
//
//  Created by Thomas Patschinski on 17.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "NetClipFileTransferClient.h"

typedef enum {stateBeginning, stateSendingCommand, stateSendingFile} SendState;

@interface NetClipFileTransferClient () <NSStreamDelegate>

@property (nonatomic, strong) NSString *server;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableData *inputBuffer;
@property (nonatomic, strong) NSMutableData *outputBuffer;
@property (nonatomic, strong) NSURL *urlToSend;
@property (nonatomic, assign) BOOL sendCommand;
@property (nonatomic, assign) SendState sendState;
@property (nonatomic, assign) NSUInteger fileSize;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@end

@implementation NetClipFileTransferClient

-(id)initWithServer:(NSString*) server andPort:(NSUInteger) port {
    self = [super init];
    if (self) {
        self.server = server;
        self.port = port;
        self.sendCommand = NO;
        self.done = NO;
        self.result = crPending;
        self.sendState = stateBeginning;
        self.timeoutInSeconds = 5;
        NSLog(@"%s server=%@, port=%lu", __PRETTY_FUNCTION__, self.server, self.port);
    }
    return self;
}

-(void)sendFile:(NSURL *)url {
    self.urlToSend = url;
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

-(void)sendFileCommand {
    if (!self.outputBuffer)
        return;
    
    NCCOMMAND command;
    memset(&command, 0, sizeof(command));
    command.uiCommand = ctFile;
    command.uiCommandVersion = 1;
    command.uiReserved1 = 0;
    command.uiReserved2 = 0;
    
    NSString *filename = [self.urlToSend lastPathComponent];
         
    strcpy(command.cFileName, [filename cStringUsingEncoding:NSISOLatin1StringEncoding]);
     
    NSFileManager *manager = [NSFileManager defaultManager];
     
    NSDictionary *dict = [manager attributesOfItemAtPath:[self.urlToSend path] error:nil];
     
    NSNumber *fileSize = [dict objectForKey:NSFileSize];
    command.uiFileLen = [fileSize unsignedIntValue];
    self.fileSize = [fileSize unsignedIntegerValue];

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
     if (aStream == self.inputStream)
         NSLog(@"%s INPUT eventcode=%ld", __PRETTY_FUNCTION__, eventCode);
     else
         NSLog(@"%s OUTPUT eventcode=%ld", __PRETTY_FUNCTION__, eventCode);

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

            if (self.sendState == stateBeginning)
            {
                self.sendState = stateSendingCommand;
                [self sendFileCommand];
            }
            else if (self.sendState == stateSendingCommand)
            {
                if ([self.outputBuffer length] > 0) {
                    NSInteger bytesWritten = [self.outputStream write:[self.outputBuffer bytes] maxLength:[self.outputBuffer length]];
                    if (bytesWritten > 0) {
                        [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) bytesWritten) withBytes:NULL length:0];
                    }
                    else {
                        self.result = crError;
                        self.done = YES;
                    }
                }
            }
            else if (self.sendState == stateSendingFile)
            {
                if ([self.outputBuffer length] > 0) {
                    NSInteger bytesWritten = [self.outputStream write:[self.outputBuffer bytes] maxLength:[self.outputBuffer length]];
                    //NSLog(@"outbutBufferSize=%ld, bytes Written=%ld", [self.outputBuffer length], bytesWritten);
                    if (bytesWritten > 0) {
                        [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) bytesWritten) withBytes:NULL length:0];
                        
                        self.bytesTransfered = self.fileSize - [self.outputBuffer length];
                        
                        if ([self.outputBuffer length] == 0)
                        {
                            NSLog(@"OutputBuffer empty");
                            self.result = crOK;
                            self.done = YES;
                        }
                    }
                    else {
                        self.result = crError;
                        self.done = YES;
                    }
                }
                else
                {
                    NSLog(@"OutputBuffer empty");
                    self.result = crOK;
                    self.done = YES;
                }
            }
            break;
            
        case NSStreamEventHasBytesAvailable: {
            //NSLog(@"Bytes Available. buffersize=%ld", [self.inputBuffer length]);
            
            uint8_t buffer[1024];
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
                        self.result = result.uiResult;
                        self.done = YES;
                        return;
                    }
                    else
                    {
                        self.sendState = stateSendingFile;
                        self.outputBuffer = [[NSMutableData alloc] initWithContentsOfURL:self.urlToSend];
                        self.dataLength = [self.outputBuffer length];
                        self.bytesTransfered = 0;

                        NSInteger bytesWritten = [self.outputStream write:[self.outputBuffer bytes] maxLength:[self.outputBuffer length]];
                        NSLog(@"initial bytes Written=%ld", bytesWritten);
                        if (bytesWritten > 0) {
                            [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) bytesWritten) withBytes:NULL length:0];
                            self.bytesTransfered = self.fileSize - [self.outputBuffer length];
                        }
                        else {
                            self.result = crError;
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
