//
//  AppDelegate.h
//  CapOneSegMac
//
//  Created by 伊藤 祐輔 on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)readPipeTest:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)initDevice:(id)sender;

@end
