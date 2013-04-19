//
//  NetClipFileTransferClient.h
//  NetClip
//
//  Created by Thomas Patschinski on 17.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"

@interface NetClipFileTransferClient : NSObject

@property (nonatomic, assign) ClipboardResult result;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, assign) NSUInteger bytesTransfered;
@property (nonatomic, assign) NSUInteger dataLength;
@property (nonatomic, assign) NSUInteger timeoutInSeconds;

-(id)initWithServer:(NSString*) server andPort:(NSUInteger) port;
-(void)sendFile:(NSURL*)url;

@end
