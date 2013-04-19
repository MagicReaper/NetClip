//
//  PreferencesController.m
//  NetClip
//
//  Created by Thomas Patschinski on 10.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "PreferencesController.h"
#import "AppDelegate.h"

@interface PreferencesController () <NSWindowDelegate>

@property (weak) IBOutlet NSTextField *serverPortTextField;
@property (weak) IBOutlet NSTextField *timeoutTextField;
@property (weak) IBOutlet NSButton *supportFormatText;
@property (weak) IBOutlet NSButton *supportFormatImageTIFF;
@property (weak) IBOutlet NSButton *supportFormatImageDIB;
@property (weak) IBOutlet NSButton *supportFormatAudioWave;
@property (weak) IBOutlet NSButton *serverStartOnAppStart;

@property (nonatomic, strong) Preferences *preferences;

@end

@implementation PreferencesController


-(id)initWithWindowNibName:(NSString *)windowNibName {
    NSLog(@"%s NibName=%@", __PRETTY_FUNCTION__, windowNibName);
    
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.preferences = [[Preferences alloc] init];
    }
    return self;
}

-(void)awakeFromNib {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.serverPortTextField setIntegerValue:self.preferences.port];
    [self.timeoutTextField setIntegerValue:self.preferences.timeout];
    self.supportFormatText.state = self.preferences.supportFormatText;
    self.supportFormatImageTIFF.state = self.preferences.supportFormatImageTIFF;
    self.supportFormatImageDIB.state = self.preferences.supportFormatImageDIB;
    self.supportFormatAudioWave.state = self.preferences.supportFormatAudioWave;
    self.serverStartOnAppStart.state = self.preferences.serverStartOnAppStart;
}


-(void)windowWillClose:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    self.preferences.port = [self.serverPortTextField integerValue];
    self.preferences.timeout = [self.timeoutTextField integerValue];
    self.preferences.supportFormatText = self.supportFormatText.state;
    self.preferences.supportFormatImageTIFF = self.supportFormatImageTIFF.state;
    self.preferences.supportFormatImageDIB = self.supportFormatImageDIB.state;
    self.preferences.supportFormatAudioWave = self.supportFormatAudioWave.state;
    self.preferences.serverStartOnAppStart = self.serverStartOnAppStart.state;

    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    appDelegate.preferencesController = nil;
}

- (void)dealloc
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
    self.preferences = nil;
}

@end
