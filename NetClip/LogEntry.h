//
//  LogEntry.h
//  NetClip
//
//  Created by Thomas Patschinski on 19.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {lesServer, lesNetClip} LogEntrySource;

@interface LogEntry : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) LogEntrySource source;

-(id)initWithMessage:(NSString*)message from:(LogEntrySource)source;

@end
