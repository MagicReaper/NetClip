//
//  NetClipClient.h
//  NetClip
//
//  Created by Thomas Patschinski on 12.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"

@interface NetClipClient : NSObject

@property (nonatomic, strong) id resultObject;
@property (nonatomic, assign) ClipboardResult result;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, assign) NSUInteger bytesTransfered;
@property (nonatomic, assign) NSUInteger dataLength;
@property (nonatomic, assign) ClipoardType type;
@property (nonatomic, assign) NSUInteger timeoutInSeconds;

-(id)initWithServer:(NSString*) server andPort:(NSUInteger) port;
-(void)requestResultForType:(ClipoardType)type;

@end
