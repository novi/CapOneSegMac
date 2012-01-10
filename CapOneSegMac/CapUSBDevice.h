//
//  CapUSBDevice.h
//  CapOneSegMac
//
//  Created by 伊藤 祐輔 on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTIOUSBDevice.h"
#import "DummyObj.h"

@interface CapUSBDevice : LTIOUSBDevice


- (void)setChannel:(int)ch;

- (void)startInitDevice;
- (void)stop;

- (void)_readDataWithDevice:(CapUSBDevice*)device dummyObj:(DummyObj*)dummyObj;

@end
