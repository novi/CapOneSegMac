//
//  AppDelegate.m
//  CapOneSegMac
//
//  Created by Yusuke Ito on 12/01/09.
//  Copyright (c) 2012 Yusuke Ito.
//  http://www.opensource.org/licenses/MIT
//

#import "AppDelegate.h"
#import "LTIOUSBManager.h"
#import "CapUSBDevice.h"
#import "DummyObj.h"

@implementation AppDelegate
@synthesize channelField = _channelField;

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSMutableArray* dicts = [NSMutableArray array];
    
    //[dicts addObject:[LTIOUSBManager matchingDictionaryForAllUSBDevicesWithObjectBaseClass:[LTIOUSBDevice class]] ];
    [dicts addObject:[LTIOUSBManager matchingDictionaryForProductID:0x1312 vendorID:0x10c4 objectBaseClass:[CapUSBDevice class]] ] ;
    
    [[LTIOUSBManager sharedInstance] startWithMatchingDictionaries:dicts];
    
    //[NSThread detachNewThreadSelector:@selector(_anotherThread:) toTarget:self withObject:nil];
    
    //NSLog(@"%s, runloop %@", __func__, CFRunLoopGetCurrent());
}



- (IBAction)readPipeTest:(id)sender
{
    DummyObj* obj = [[DummyObj alloc] init];
   
    CapUSBDevice* device = [LTIOUSBManager sharedInstance].devices.lastObject;
    [device startCapture:obj];
    
}

- (IBAction)stop:(id)sender {
    CapUSBDevice* device = [LTIOUSBManager sharedInstance].devices.lastObject;
    [device stopCapture];
}

- (IBAction)initDevice:(id)sender {
    CapUSBDevice* device = [LTIOUSBManager sharedInstance].devices.lastObject;
    
    DummyObj* obj = [[DummyObj alloc] initWithCName:__func__];
    
    device.callback = ^(CapUSBDevice* dev, NSData* data) {
        const UInt8* buf = data.bytes;
        NSLog(@"recv: %lu bytes, %p, %@", data.length, obj, buf[1] & 0x80 ? @"Invalid" : @"");  
    };
    
    if (![device initDevice]) {
        NSLog(@"device initialized failure");
    } 
    
    
}

- (IBAction)setChannel:(id)sender
{
    CapUSBDevice* device = [LTIOUSBManager sharedInstance].devices.lastObject;
    if ( ! device.isDeviceInitialized) {
        NSLog(@"device not initialized, now init...");
        [self initDevice:nil];
    }
    
    [device setChannel:self.channelField.intValue];
}

#pragma mark -

- (void)_anotherThread:(id)obj
{
    NSLog(@"%s, runloop %@", __func__, CFRunLoopGetCurrent());
}

@end
