//
//  AppDelegate.h
//  CapOneSegMac
//
//  Created by Yusuke Ito on 12/01/09.
//  Copyright (c) 2012 Yusuke Ito.
//  http://www.opensource.org/licenses/MIT
//


#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)readPipeTest:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)initDevice:(id)sender;
@property (weak) IBOutlet NSTextField *channelField;
- (IBAction)setChannel:(id)sender;

@end
