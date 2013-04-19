//
//  LogEntry.m
//  NetClip
//
//  Created by Thomas Patschinski on 19.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "LogEntry.h"

@implementation LogEntry

-(id)initWithMessage:(NSString *)message from:(LogEntrySource)source {
    self = [super init];
    if (self) {
        self.date = [NSDate date];
        self.message = message;
        self.source = source;
    }
    return self;
}

@end
