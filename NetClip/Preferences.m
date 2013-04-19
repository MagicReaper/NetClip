//
//  Preferences.m
//  NetClip
//
//  Created by Thomas Patschinski on 10.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "Preferences.h"

#define PREF_PORT                       @"preferences.serverPort"
#define PREF_TIMEOUT                    @"preferences.timeout"
#define PREF_FORMAT_TEXT                @"preferences.supportFormatText"
#define PREF_FORMAT_IMAGE_TIFF          @"preferences.supportFormatImageTIFF"
#define PREF_FORMAT_IMAGE_DIB           @"preferences.supportFormatImageDIB"
#define PREF_FORMAT_AUDIO_WAVE          @"preferences.supportFormatAudioWave"
#define PREF_START_SERVER               @"preferences.serverStartOnAppStart"

#define PREF_DEFAULT_PORT               @40000
#define PREF_DEFAULT_TIMEOUT            @10
#define PREF_DEFAULT_FORMAT_TEXT        @YES
#define PREF_DEFAULT_FORMAT_IMAGE_TIFF  @NO
#define PREF_DEFAULT_FORMAT_IMAGE_DIB   @NO
#define PREF_DEFAULT_FORMAT_AUDIO_WAVE  @NO
#define PREF_DEFAULT_START_SERVER       @NO

@implementation Preferences

-(void)loadFromUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{
                        PREF_PORT : PREF_DEFAULT_PORT,
                     PREF_TIMEOUT : PREF_DEFAULT_TIMEOUT,
                 PREF_FORMAT_TEXT : PREF_DEFAULT_FORMAT_TEXT,
           PREF_FORMAT_IMAGE_TIFF : PREF_DEFAULT_FORMAT_IMAGE_TIFF,
            PREF_FORMAT_IMAGE_DIB : PREF_DEFAULT_FORMAT_IMAGE_DIB,
           PREF_FORMAT_AUDIO_WAVE : PREF_DEFAULT_FORMAT_AUDIO_WAVE,
                PREF_START_SERVER : PREF_DEFAULT_START_SERVER}];
    
    NSNumber *temp = [userDefaults objectForKey:PREF_PORT];
    self.port = [temp unsignedIntegerValue];
    
    temp = [userDefaults objectForKey:PREF_TIMEOUT];
    self.timeout = [temp unsignedIntegerValue];
    
    self.supportFormatText = [userDefaults boolForKey:PREF_FORMAT_TEXT];
    self.supportFormatImageTIFF = [userDefaults boolForKey:PREF_FORMAT_IMAGE_TIFF];
    self.supportFormatImageDIB = [userDefaults boolForKey:PREF_FORMAT_IMAGE_DIB];
    self.supportFormatAudioWave = [userDefaults boolForKey:PREF_FORMAT_AUDIO_WAVE];
    self.serverStartOnAppStart = [userDefaults boolForKey:PREF_START_SERVER];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadFromUserDefaults];
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return self;
}

- (void)dealloc {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSNumber *temp = [NSNumber numberWithUnsignedInteger:self.port];
    [userDefaults setObject:temp forKey:PREF_PORT];

    temp = [NSNumber numberWithUnsignedInteger:self.timeout];
    [userDefaults setObject:temp forKey:PREF_TIMEOUT];

    [userDefaults setBool:self.supportFormatText forKey:PREF_FORMAT_TEXT];
    [userDefaults setBool:self.supportFormatImageTIFF forKey:PREF_FORMAT_IMAGE_TIFF];
    [userDefaults setBool:self.supportFormatImageDIB forKey:PREF_FORMAT_IMAGE_DIB];
    [userDefaults setBool:self.supportFormatAudioWave forKey:PREF_FORMAT_AUDIO_WAVE];
    [userDefaults setBool:self.serverStartOnAppStart forKey:PREF_START_SERVER];

    [userDefaults synchronize];
}

@end
