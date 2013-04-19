//
//  NetClipServer.m
//  NetClip
//
//  Created by Thomas Patschinski on 12.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "NetClipServer.h"
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface NetClipServer ()
@property (nonatomic, assign) NSUInteger port;
@end

@implementation NetClipServer

-(id)initWithPort:(NSUInteger) port {
    self = [super init];
    if (self) {
        self.port = port;
    }
    return self;
}

-(void)run {
    CFSocketRef myipv4cfsock = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, /* handleConnect */ NULL, NULL);

    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET; /* Address family */
    sin.sin_port = htons(self.port); /* Or a specific port */
    sin.sin_addr.s_addr= INADDR_ANY;

    CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
    CFSocketSetAddress(myipv4cfsock, sincfd);
    CFRelease(sincfd);
    
    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, myipv4cfsock, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketsource, kCFRunLoopDefaultMode);
}

-(void)stop {
    
}

@end
