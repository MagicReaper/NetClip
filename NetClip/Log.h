//
//  Log.h
//  NetClip
//
//  Created by Thomas Patschinski on 19.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

@interface Log : NSObject
@property (nonatomic, strong) NSMutableArray *logArray;

-(void)addLogEntry:(NSString*)message forSource:(LogEntrySource)source;
-(void)clearLog;

@end
