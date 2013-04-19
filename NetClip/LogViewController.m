//
//  NSLogViewControllerWindowController.m
//  NetClip
//
//  Created by Thomas Patschinski on 19.04.13.
//  Copyright (c) 2013 Lammel & Partner GbR. All rights reserved.
//

#import "LogViewController.h"
#import "AppDelegate.h"
#import "Log.h"
#import "LogEntry.h"

@interface LogViewController () <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) Log *log;
@end

@implementation LogViewController

- (id)initWithWindow:(NSWindow *)window
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self = [super initWithWindow:window];
    if (self) {
        AppDelegate *dele = [[NSApplication sharedApplication] delegate];
        self.log = dele.log;
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super windowDidLoad];
    

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)windowWillClose:(NSNotification *)notification {
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    appDelegate.logViewController = nil;
}

#pragma mark - NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return [self.log.logArray count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    LogEntry *entry = [self.log.logArray objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"time"])
    {
        cellView.textField.stringValue = [NSDateFormatter localizedStringFromDate:entry.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    }
    else if ([tableColumn.identifier isEqualToString:@"message"])
    {
        cellView.textField.stringValue = entry.message;
    }
    else if ([tableColumn.identifier isEqualToString:@"source"])
    {
        switch (entry.source) {
            case lesNetClip:
                cellView.textField.stringValue = @"NetClip";
                break;

            case lesServer:
                cellView.textField.stringValue = @"Server";
                break;
                
            default:
                cellView.textField.stringValue = @"Unkown";
                break;
        }
        cellView.textField.stringValue = @"source";
    }
    
    return cellView;
}

#pragma mark - Dealloc
- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
