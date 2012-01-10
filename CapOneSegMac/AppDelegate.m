//
//  AppDelegate.m
//  CapOneSegMac
//
//  Created by 伊藤 祐輔 on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "LTIOUSBManager.h"
#import "CapUSBDevice.h"
#import "DummyObj.h"

#define UOT100_PACKET_SIZE	197

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSMutableArray* dicts = [NSMutableArray array];
    
    //[dicts addObject:[LTIOUSBManager matchingDictionaryForAllUSBDevicesWithObjectBaseClass:[LTIOUSBDevice class]] ];
    [dicts addObject:[LTIOUSBManager matchingDictionaryForProductID:0x1312 vendorID:0x10c4 objectBaseClass:[CapUSBDevice class]] ] ;
    
    [[LTIOUSBManager sharedInstance] startWithMatchingDictionaries:dicts];
    
    [NSThread detachNewThreadSelector:@selector(_anotherThread:) toTarget:self withObject:nil];
    
    NSLog(@"%s, runloop %@", __func__, CFRunLoopGetCurrent());
}



- (IBAction)readPipeTest:(id)sender
{
    DummyObj* obj = [[DummyObj alloc] init];
    
    
    
    CapUSBDevice* device = [LTIOUSBManager sharedInstance].devices.lastObject;
    [device _readDataWithDevice:device dummyObj:obj];
    
}

- (IBAction)stop:(id)sender {
    CapUSBDevice* device = [LTIOUSBManager sharedInstance].devices.lastObject;
    [device stop];
}

- (IBAction)initDevice:(id)sender {
    CapUSBDevice* device = [LTIOUSBManager sharedInstance].devices.lastObject;
    [device startInitDevice];
}

- (void)_anotherThread:(id)obj
{
    NSLog(@"%s, runloop %@", __func__, CFRunLoopGetCurrent());
}

@end
