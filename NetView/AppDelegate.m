//
//  AppDelegate.m
//  NetView
//
//  Created by Tyler Wright on 10/10/14.
//  Copyright (c) 2014 Wright Labs. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Queue up new menu so that there is no delay when launching application
    [self displayMenu];
    
    // Create statusbar item
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"netview_icon.png"];
    _statusItem.alternateImage = [NSImage imageNamed:@"netview_icon_alt.png"];
    _statusItem.highlightMode = YES;
    _statusItem.toolTip = @"NetView";
    [_statusItem setAction:@selector(clearMenu:)];
    [_statusItem setTarget:self];
}

// On click, clear the old menu then ---> display new menu
- (IBAction)clearMenu:(NSStatusItem*)sender{
    if(self.menu){
        [self.menu removeAllItems];
        [self displayMenu];
    }
}

// Display the menu with live data
- (void)displayMenu{
    NSMenu *menu;
    NSMenuItem *item;
    
    // Show title for hostname
    [self.menu addItemWithTitle:(@"Hostname") action:@selector(sharingPrefs:) keyEquivalent:@""];
    
    // Get hostname
    NSString *hostname = [[NSHost currentHost] name];
    item = [self.menu addItemWithTitle:(@"%@", hostname) action:nil keyEquivalent:@""];
    [item setIndentationLevel:1];
    
    // Add separator
    [self.menu addItem:[NSMenuItem separatorItem]];
    
    // Show title for local IP addresses
    [self.menu addItemWithTitle:(@"Local IP Address") action:@selector(netPrefs:) keyEquivalent:@""];
    
    // Get all IP addresses that are associated with this system
    NSArray *IP = [[NSHost currentHost] addresses];
    if(IP){
        for(NSString *address in IP){
            // Hide loopback and IPv6 addresses
            if((![address hasPrefix:@"127"]) && ([address rangeOfString:@"."].location != NSNotFound)){
                item = [self.menu addItemWithTitle:(@"%@", address) action:nil keyEquivalent:@""];
                [item setIndentationLevel:1];
            }
        }
    }
    
    // Show title for external IP addresses
    [self.menu addItemWithTitle:(@"External IP Address") action:@selector(extIP:) keyEquivalent:@""];
    
    // Get external IP address
    NSURL *results = [NSURL URLWithString:@"http://www.curlmyip.com"];
    NSURLRequest* request = [NSURLRequest requestWithURL:results cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:1.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection){
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *externalIP = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if([externalIP rangeOfString:@"."].location != NSNotFound){
            item = [self.menu addItemWithTitle:(@"%@", externalIP) action:nil keyEquivalent:@""];
            [item setIndentationLevel:1];
        }else{
            item = [self.menu addItemWithTitle:(@"None") action:nil keyEquivalent:@""];
            [item setIndentationLevel:1];
        }
        [connection cancel];
        connection = nil;
    }
    
    // Add separator, about, and quit menu items
    [self.menu addItem:[NSMenuItem separatorItem]];
    [self.menu addItemWithTitle: @"Quit" action:@selector(terminate:) keyEquivalent: @""];
    
    // Display refreshed menu
    [_statusItem popUpStatusItemMenu:self.menu];
    [_statusItem setMenu:menu];
}

- (void)netPrefs:(id)sender{
    NSString *netPrefsURL = @"x-apple.systempreferences:com.apple.preference.network";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:netPrefsURL]];
}

- (void)sharingPrefs:(id)sender{
    NSString *sharingPrefsURL = @"x-apple.systempreferences:com.apple.preferences.sharing";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:sharingPrefsURL]];
}

- (void)extIP:(id)sender{
    NSString *netPrefsURL = @"http://www.curlmyip.com";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:netPrefsURL]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end