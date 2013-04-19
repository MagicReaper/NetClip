//
//  NetClipServer.h
//  NetClip
//
//  Created by Thomas Patschinski on 12.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetClipServer : NSObject

-(id)initWithPort:(NSUInteger) port;

-(void)run;
-(void)stop;

@end
