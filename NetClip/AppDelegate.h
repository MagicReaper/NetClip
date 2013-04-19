//
//  AppDelegate.h
//  NetClip
//
//  Created by Thomas Patschinski on 25.03.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferencesController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *statusImage;
@property (nonatomic, strong) NSImage *statusHighlightImage;
@property (nonatomic, strong) PreferencesController *preferencesController;

-(IBAction)helloWorld:(id)sender;
-(IBAction)openPreferences:(id)sender;

@end
