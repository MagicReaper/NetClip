//
//  Log.m
//  NetClip
//
//  Created by Thomas Patschinski on 19.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "Log.h"

@implementation Log

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        self.logArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Public Methods

-(void)addLogEntry:(NSString *)message forSource:(LogEntrySource)source {
    LogEntry *entry = [[LogEntry alloc] initWithMessage:message from:source];
    [self.logArray addObject:entry];
}

-(void)clearLog {
    [self.logArray removeAllObjects];
}

@end
