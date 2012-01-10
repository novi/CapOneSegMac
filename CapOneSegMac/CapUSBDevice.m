//
//  CapUSBDevice.m
//  CapOneSegMac
//
//  Created by 伊藤 祐輔 on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CapUSBDevice.h"
#import "initdata.h"


#define SEND_WAIT 10 /**< for USB hub delay. */
#define RECV_WAIT 20 /**< for USB hub delay. */
#define RECV_TIMEOUT 200
#define UOT100_PACKET_SIZE	197
#define BULKENDP (0x2)

void cap_msleep(int ms);

void cap_msleep(int ms)
{
	usleep(1000*ms);
}

@interface CapUSBDevice()

{
    int _channel;
    BOOL _stop;
}

- (void) _sendInitData;
- (void)_sendStartStop:(BOOL)start;
- (BOOL)_send5Data:(unsigned char *)p wait:(BOOL)wait;
- (BOOL)_sendControlRequest:(UInt8)request val:(UInt8)value;

@end

@implementation CapUSBDevice

- (void)setChannel:(int)ch
{
	_channel = ch;
	[self _sendInitData];
    [self _sendStartStop:YES]; // Start
}

#pragma mark -

- (void)_setChannelToSendData
{
	//unsigned int freq=channel2frequency(channel);
    
    int channel = _channel;
	
	senddata4[8]=p1_table[channel-13];
	senddata4[13]=p2_table[channel-13];
	senddata4[18]=(0x1a + ((channel - 13) / 3));
	senddata4[23]=(channel <= 20) ? 0x8c : 0x94;
	
	switch ((channel - 13) % 3) {
		case 0:
			senddata4[28]=0x18;
			senddata4[33]=0x04;
			senddata4[38]=0x05;
			break;
		case 1:
			senddata4[28]=0x6e;
			senddata4[33]=0x59;
			senddata4[38]=0x0a;
			break;
		case 2:
			senddata4[28]=0xc3;
			senddata4[33]=0xae;
			senddata4[38]=0x0f;
			break;
	}
	
	senddata5[3]=p1_table[channel-13]+1;
	senddata5[8]=p2_table[channel-13];
}

- (void)_sendStartStop:(BOOL)start
{
    if (start) {
        [self _sendControlRequest:0x02 val:0x01];
        [self _send5Data:senddata_start wait:YES];
    } else {
        [self _send5Data:senddata_stop wait:YES];
        [self _sendControlRequest:0x02 val:0x01];
    }
}

- (void) _readDummyData
{
    if ( ! [self readFromPipeAsync:BULKENDP callback:^(NSData* data) {
        
        NSLog(@"dumy data read %lu bytes", data.length);
        
    } maxPacketSize:UOT100_PACKET_SIZE noDataTimeout:RECV_TIMEOUT completionTimeout:RECV_TIMEOUT]) {
        [self clearPipeStall:BULKENDP];
        [self readFromPipeAsync:BULKENDP callback:^(NSData* data) {
            
            NSLog(@"dumy data read %lu bytes", data.length);
            
        } maxPacketSize:UOT100_PACKET_SIZE noDataTimeout:RECV_TIMEOUT completionTimeout:RECV_TIMEOUT];
    }
}

- (void) _sendInitData
{
	struct init_struct *init_struct_p = logj200_init_struct;
	[self _setChannelToSendData];
	
	while(init_struct_p->command){
		switch(init_struct_p->command){
			case 1:
				if( ! [self _sendControlRequest:init_struct_p->request val:init_struct_p->value]){
					printf ("control message error. (request = %x, value = %x)\n", init_struct_p->request, init_struct_p->value);
				}
				break;
			case 2:
				if( ! [self _send5Data:init_struct_p->senddata wait:YES]){
					printf("send5data error. (request = %x, value = %x)\n", init_struct_p->request, init_struct_p->value);
				}
				break;
			case 3:
				[self _readDummyData];
				break;
		}
		init_struct_p++;
	}
	
}


#pragma mark - Send and Read wrapper

- (BOOL)_send5Data:(unsigned char *)p wait:(BOOL)wait
{
	unsigned char buf[5];
	
	while((*p) != 0xff){
		memcpy(buf,p,5);
        BOOL success = [self writeToPipe:1 data:[NSData dataWithBytes:buf length:5] noDataTimeout:RECV_TIMEOUT completionTimeout:RECV_TIMEOUT];
		
		if(!success){
			fprintf(stderr, "send5data failed %02x %02x %02x %02x %02x\n", p[0], p[1], p[2], p[3], p[4]);
			return NO;
		}
		if (success) {
			//fprintf(stderr, "send5data(OK) %02x %02x %02x %02x %02x\n", p[0], p[1], p[2], p[3], p[4]);
		}
		if (wait) {
			cap_msleep(SEND_WAIT);
		}
		p+=5;
	}
	
	return YES;
}

/*
 static int cap_send5data(unsigned char *p)
 {
 return cap_send5data_wait(p, 1);
 }
 */

- (BOOL)_sendControlRequest:(UInt8)request val:(UInt8)value
{
    IOUSBDevRequestTO req;
	req.bmRequestType = USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBDevice);
	req.bRequest = request;
	req.completionTimeout = RECV_TIMEOUT;
	req.noDataTimeout = RECV_TIMEOUT;
	req.pData = NULL;
	req.wIndex = 0;
	req.wLenDone = 0;
	req.wLength = 0;
	req.wValue = value;
	
    BOOL success = [self sendControlRequestToPipe:0 request:req];
	if (!success) {
        return NO;
    }
    
    cap_msleep(10);
    
    return YES;
}

#pragma mark -

- (void)_readDataWithDevice:(CapUSBDevice*)device dummyObj:(DummyObj*)dummyObj
{
    
    if ([self readFromPipeAsync:0x2 callback:^(NSData *data) {
        UInt8* buf = data.bytes;
        if (buf) {
            NSLog(@"data recv: %lu, %@, 0x%02x, 0x%02x, 0x%02x, 0x%02x, %p", data.length, buf[1] & 0x80 ? @"Invalid" : @"OK", buf[0], buf[1], buf[2], buf[3], dummyObj);
        } else {
            NSLog(@"zero data");
        }
        
        if (!_stop && self.isConnected /*&& data*/) {
            [self _readDataWithDevice:nil dummyObj:dummyObj];
        }
        
    } maxPacketSize:UOT100_PACKET_SIZE
                    noDataTimeout:200
                completionTimeout:200]) {
        
        //NSLog(@"%s", __func__);
        
        
    }
}

-(void)stop
{
    _stop = YES;
}

-(void)startInitDevice
{
    [self closeInterfaceInterface];
    //[self closeDeviceInterface];
    
    if ([self openDevice]) {
        NSLog(@"device Opened");
        if ([self findFirstInterfaceInterface]) {
            NSLog(@"findFirstInterfaceInterface");
            if ([self openInterface] && [self addAsyncRunloopSourceToRunloop:CFRunLoopGetMain()]) {
                NSLog(@"Interface opened: %p", self.interfaceInterface);
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    cap_msleep(100);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setChannel:20];
                        NSLog(@"started !!!!");
                        _stop = NO;
                    });
                });
                
            }
            
        }
    }
    
    
}


#pragma mark - 

-(void)deviceConnected
{
    _channel = 27;
    
    if ([self createPluginInterface]) {
        NSLog(@"createPluginInterface");
        if ([self createDeviceInterface]) {
            NSLog(@"createDeviceInterface");
            
        }
    }
}

-(void)deviceDisconnected
{
    _stop = YES;
    
}

+(BOOL)removeFromDeviceListOnDisconnect
{
    return YES;
}

-(void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
