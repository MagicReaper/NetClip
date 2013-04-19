//
//  Preferences.h
//  NetClip
//
//  Created by Thomas Patschinski on 10.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, assign) NSUInteger timeout;
@property (nonatomic, assign) BOOL supportFormatText;
@property (nonatomic, assign) BOOL supportFormatImageTIFF;
@property (nonatomic, assign) BOOL supportFormatImageDIB;
@property (nonatomic, assign) BOOL supportFormatAudioWave;
@property (nonatomic, assign) BOOL serverStartOnAppStart;

@end
