//
//  AppDelegate.m
//  NetClip
//
//  Created by Thomas Patschinski on 25.03.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesController.h"
#import "LogViewController.h"
#import "NetClipClient.h"
#import "NetClipFileTransferClient.h"
#import "Log.h"

@interface AppDelegate ()

@property (nonatomic, strong) NetClipClient *client;
@property (nonatomic, strong) NetClipFileTransferClient *clientFileTransfer;
@property (unsafe_unretained) IBOutlet NSTextView *textViewOutlet;
@property (weak) IBOutlet NSImageView *imageViewOutlet;
@property (weak) IBOutlet NSTextField *labelOutlet;
@property (weak) IBOutlet NSProgressIndicator *progressOutlet;

@end

@implementation AppDelegate

#pragma mark -
#pragma mark Initialisation

- (void)awakeFromNib {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    self.statusImage = [NSImage imageNamed:NSImageNameQuickLookTemplate];
    self.statusHighlightImage = [NSImage imageNamed:NSImageNameActionTemplate];
    
    //Create the NSStatusBar and set its length
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

    //Sets the images in our NSStatusItem
    [self.statusItem setImage:self.statusImage];
    [self.statusItem setAlternateImage:self.statusHighlightImage];

    //Tells the NSStatusItem what menu to load
    [self.statusItem setMenu:self.statusMenu];
    
    //Sets the tooptip for our item
    [self.statusItem setToolTip:@"My Custom Menu Item"];
    
    //Enables highlighting
    [self.statusItem setHighlightMode:YES];
}

#pragma mark -
#pragma mark Application Delegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.log = [[Log alloc] init];
    
    [self.log addLogEntry:@"NetClip Startet" forSource:lesNetClip];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark -
#pragma mark Menu Methods

-(IBAction)openPreferences:(id)sender {
    if (!self.preferencesController)
    {
        self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
        [self.preferencesController showWindow:self];
    }
}

-(IBAction)openLogViewWindow:(id)sender {
    if (!self.logViewController) {
        self.logViewController = [[LogViewController alloc] initWithWindowNibName:@"LogView"];
        [self.logViewController showWindow:self];
    }
}

- (IBAction)sendFile:(id)sender {

    if (self.clientFileTransfer) {
        NSLog(@"Client läuft bereits");
        return;
    }

    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    panel.canChooseFiles = YES;
    panel.canCreateDirectories = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL *url = [panel.URLs lastObject];
            NSLog(@"url = %@, filename=%@", url, [url lastPathComponent]);

            [self.textViewOutlet setString:@"Sending File please wait."];
            [self.imageViewOutlet setImage:nil];

            NetClipFileTransferClient *client = [[NetClipFileTransferClient alloc] initWithServer:@"192.168.99.52" andPort:40000];
            
            [client sendFile:url];
            
            self.clientFileTransfer = client;
            
            [self addObserver:self forKeyPath:@"clientFileTransfer.done" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            [self addObserver:self forKeyPath:@"clientFileTransfer.bytesTransfered" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }
    }];
}

- (IBAction)requestClipboardData:(id)sender {

    if (self.client) {
        NSLog(@"Client läuft bereits");
        return;
    }

    Preferences *pref = [[Preferences alloc] init];
    
    [self.textViewOutlet setString:@"Requesting Data please wait."];
    [self.imageViewOutlet setImage:nil];
    
    NetClipClient *client = [[NetClipClient alloc] initWithServer:@"192.168.99.52" andPort:40000];
    client.timeoutInSeconds = pref.timeout;

    [self addObserver:self forKeyPath:@"client.done" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"client.bytesTransfered" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    [client requestResultForType:ctDIB];
    
    self.client = client;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:@"client.done"])
    {
        if (self.client.done)
        {
            if (self.client.result == crOK)
            {
                NSPasteboard *pboard = [NSPasteboard generalPasteboard];
                [pboard clearContents];
                
                BOOL pasteResult = NO;
                
                if (self.client.resultObject)
                    pasteResult = [pboard writeObjects:@[self.client.resultObject]];
                
                if (pasteResult)
                    NSLog(@"Paste OK");
                
                if (self.client.type == ctDIB)
                {
                    [self.imageViewOutlet setImage:self.client.resultObject];
                }
                else if (self.client.type == ctText)
                {
                    [self.textViewOutlet setString:self.client.resultObject];
                }
                else if (self.client.type == ctFile)
                {
                    self.textViewOutlet.string = @"File send OK";
                }
            }
            else
            {
                self.textViewOutlet.string = @"Error";
            }

            [self removeObserver:self forKeyPath:@"client.done"];
            [self removeObserver:self forKeyPath:@"client.bytesTransfered"];
            self.client = nil;
        }
    }
    else if ([keyPath isEqualToString:@"client.bytesTransfered"])
    {
        NSString *temp = [NSString stringWithFormat:@"%ld/%ld Transfered", self.client.bytesTransfered, self.client.dataLength];
        self.labelOutlet.stringValue = temp;
        
        if (self.client.dataLength > 0)
            self.progressOutlet.maxValue = self.client.dataLength;
        
        self.progressOutlet.doubleValue = self.client.bytesTransfered;
    }
    else if ([keyPath isEqualToString:@"clientFileTransfer.done"])
    {
        if (self.clientFileTransfer.result != crOK)
        {
            self.textViewOutlet.string = [NSString stringWithFormat:@"Filetransfer Failed. Errorcode=%d", self.clientFileTransfer.result];
        }
        else
        {
            self.textViewOutlet.string = @"File Transfer beendet";
        }
        
        [self removeObserver:self forKeyPath:@"clientFileTransfer.done"];
        self.clientFileTransfer = nil;
    }
    else if ([keyPath isEqualToString:@"clientFileTransfer.bytesTransfered"])
    {
        NSString *temp = [NSString stringWithFormat:@"%ld/%ld Transfered File", self.clientFileTransfer.bytesTransfered, self.clientFileTransfer.dataLength];
        self.labelOutlet.stringValue = temp;
        
        if (self.clientFileTransfer.dataLength > 0)
            self.progressOutlet.maxValue = self.clientFileTransfer.dataLength;
        
        self.progressOutlet.doubleValue = self.clientFileTransfer.bytesTransfered;
    }
}

-(void)helloWorld:(id)sender {
    NSLog(@"Helllo World");
}

@end
