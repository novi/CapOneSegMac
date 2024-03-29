//
//  CapUSBDevice.h
//  CapOneSegMac
//
//  Created by Yusuke Ito on 12/01/09.
//  Copyright (c) 2012 Yusuke Ito.
//  http://www.opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import "LTIOUSBDevice.h"

@class CapUSBDevice;

typedef void (^CapUSBDeviceDataReceiveCallback)(CapUSBDevice* device,  NSData* data);

@interface CapUSBDevice : LTIOUSBDevice

@property (nonatomic, readonly, getter = isDeviceInitialized) BOOL deviceInitialized;
@property (nonatomic, readonly, getter = isStop) BOOL stop;
@property (nonatomic, copy) CapUSBDeviceDataReceiveCallback callback;

- (BOOL)setChannel:(int)ch;

- (BOOL)initDevice;
- (void)stopCapture;

- (BOOL)startCapture:(id)sender;

@end
