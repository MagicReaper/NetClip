//
//  AppDelegate.h
//  NetClip
//
//  Created by Thomas Patschinski on 25.03.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferencesController;
@class LogViewController;
@class Log;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *statusImage;
@property (nonatomic, strong) NSImage *statusHighlightImage;
@property (nonatomic, strong) PreferencesController *preferencesController;
@property (nonatomic, strong) LogViewController *logViewController;
@property (nonatomic, strong) Log *log;

-(IBAction)helloWorld:(id)sender;
-(IBAction)openPreferences:(id)sender;

@end
